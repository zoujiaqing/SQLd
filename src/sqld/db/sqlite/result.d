module sqld.db.sqlite.result;

import sqld.base.database,
       sqld.base.result,
       sqld.base.row,
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
        
        string[] _fields;
        int _fieldNum;
        
        ulong _affected;
        ulong _rows;
        ulong _index;
    }
    
    
    
    /**
     * Creates new MySQLResult instance
     *
     * Params:  
     *  res = MySQL result
     */
    this( sqlite3* db, sqlite3_stmt* res)
    {
        _db = db;
        _res = res;
        _usable = true;
        _fieldNum = sqlite3_column_count(_res);
        
        while(next()) ++_rows;
        reset();
        
        if(_rows < 1 ) {
            _affected = sqlite3_changes(_db);
        } else {
            _affected = _rows;
        }
        
        loadFields();
        next();
    }
    
    ~this()
    {
        if(_usable)
            sqlite3_finalize(_res);
    }
    
    /**
     * Loads field array
     */
    protected void loadFields()
    {
        for ( int i = 0; i < _fieldNum; i++ )
        {
            _fields ~= to!(string)(sqlite3_column_name(_res, i));
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
        string[] vals;
        for(int i = 0; i < _fieldNum; i++ )
        {
            vals ~= to!(string)(sqlite3_column_text(_res, i));
        }
        return new Row(vals, _fields);
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

        if( state == 100 )
            _valid = true;
        else
            _valid = false;
        
        return _valid;
    }
    
    
    /**
     * Resets current index
     */
    public override void reset()
    {
        sqlite3_reset(_res);
        _valid = true;
    } 
    
    
    /**
     * Query result row count
     *
     * Returns:
     *  Row count
     */
    public override ulong length() @property
    {
        return _rows;
    }
    
    /**
     * Query result fields
     *
     * Returns:
     *  Array of fields
     */
    public override string[] fields() @property
    {
        return _fields;
    }
    
    /**
     * Check if there are any rows remeaining
     *
     * Returns:
     *  True if there are any remeaining rows
     */
    public override bool isValid() @property
    {
        return _valid;
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
    
    
    /**
     * Affected rows
     */
    public override ulong affectedRows() @property
    {
        return _affected;
    }
}