module sqld.db.sqlite.result;

import sqld.base.database,
       sqld.base.result,
       sqld.base.row,
       sqld.base.error,
       etc.c.sqlite3,
       sqld.db.mysql.database;
       
import std.conv : to;


/**
 * Represents query results
 *
 * This class implements ForwardRange, which allows to iterate over results.
 *
 * Examples:
 * ---
 * auto res = db.query("SELECT ...");
 * while(res.isValid)
 * {
 *     writeln(res.fetch());  
 * }
 * ---
 *
 * ---
 * auto res = db.query("SELECT ...");
 * foreach(row; res)
 * {
 *     writeln(row);
 * }
 * ---
 */
class SQLiteResult : Result
{   
    protected
    {
        sqlite3* _db;
        sqlite3_stmt* _res;
        bool _usable;
        bool _valid;
        
        Row _row;
        
        string[] _columns;
        int _fieldNum;
        
        ulong _rows;
        ulong _index;
    }
    
    
    
    /**
     * Creates new MySQLResult instance
     *
     * Params:  
     *  db = Database handle
     *  res = MySQL result
     */
    this( sqlite3* db, sqlite3_stmt* res)
    {
        _db = db;
        _res = res;
        _usable = true;
        _fieldNum = sqlite3_column_count(_res);
        
        /// to be changed
        while(next()) ++_rows;
        reset();
        
        if(_rows < 1 ) {
            _usable = false;
            _rows = sqlite3_changes(_db);
        }
        
        loadColumns();
        next();
        _index = 0;
    }
    
    ~this()
    {
        if(_usable) {
            sqlite3_finalize(_res);
        }
    }
    
    protected void loadColumns()
    {
        for ( int i = 0; i < _fieldNum; i++ )
        {
            _columns ~= to!(string)(sqlite3_column_name(_res, i));
        }
    }
    
    
    /**
     * Frees result
     *
     * After freeing instance is not usable anymore
     */
    public override void free()
    {
        if(_usable)
        {
            sqlite3_finalize(_res);
            _usable = false;
        }
    }
    
    /**
     * Fetches row
     * 
     * This function returns cached row, loaded by next() method.
     * Continuous calling will return same row until next() is called.
     *
     * Examples:
     * ---
     * auto res = db.query("SELECT ...");
     * while(res.isValid)
     * {
     *     writeln(res.fetch());
     *     res.next();
     * }
     * ---
     *
     * Throws:
     *  DatabaseException
     *
     * Returns:
     *  Row
     */
    public override Row fetch(string file = __FILE__, uint line = __LINE__)
    {
        return _row;
    }
    
    
    /**
     * Proceedes to next row
     *
     * If no rows are remeaining, returns false.
     *
     * Returns:
     *  True if any rows are remaining, false otherwise
     */
    public override bool next()
    {
        int state = sqlite3_step(_res);
        
        if(state == SQLITE_ROW) {
            loadRow();            
            _index += 1;
            _valid = true;
        } else if(state == SQLITE_DONE) {
            _valid = false;
        }
        
        return _valid;
    }
    
    
    /**
     * Resets current index
     */
    public override void reset()
    {
        sqlite3_reset(_res);
        _valid = true;
        _index = 0;
        loadRow();
    } 
    
    
    /**
     * Row count
     * 
     * If query was SELECT it returns number rows selected, 
     * if any other, it returns affected rows.
     */
    public override ulong length() @property
    {
        return _rows;
    }
    
    /**
     * Query result columns
     *
     * Returns:
     *  Array of columns
     */
    public override string[] columns() @property
    {
        return _columns;
    }
    
    /**
     * Check if there are any rows remeaining
     *
     * Returns false is result was freed or if query was not SELECT type.
     *
     * Returns:
     *  True if there are any remeaining rows
     */
    public override bool isValid() @property
    {
        return _valid && _usable;
    }
    
    /**
     * Current row index
     *
     * Returns:
     *  Current row offset
     */
    public override ulong index() @property
    {
        return _index;
    }
    
    protected void loadRow()
    {
        string[] vals;
        for(int i = 0; i < _fieldNum; i++ )
        {
            vals ~= to!(string)(sqlite3_column_text(_res, i));
        }
        _row =  new Row(vals, _columns);
    }
}