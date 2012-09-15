module sqld.db.mysql.result;

import sqld.base.database,
       sqld.base.result,
       sqld.base.error,
       sqld.base.row,
       sqld.c.mysql,
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
class MySQLResult : Result
{
    protected
    {
        MYSQL* _db;
        MYSQL_RES* _res;
        bool _usable;
        
        string[] _columns;
        int _columnNum;
        
        ulong _rows;
        ulong _index;
        ulong _affected;
    }
    
    
    /**
     * Creates new MySQLResult instance
     *
     * Params:  
     *  res = MySQL result
     */
    this(MYSQL* db, MYSQL_RES* res)
    {
        _db = db;
        _res = res;
        
        if(res !is null)
        {
            _rows = mysql_num_rows(_res);
            _columnNum = mysql_num_fields(_res);
            
            loadColumns();
            
            _affected = _rows;
            _usable = true;
        }
        else
        {
            _affected = mysql_affected_rows(_db);
        }
    }
    
    ~this()
    {
        if(_usable)
        {
            mysql_free_result(_res);
        }
    }
    
    /**
     * Loads field array
     */
    protected void loadColumns()
    {
        MYSQL_FIELD* field;
        for (uint i = 0; i < _columnNum; i++)
        {
            field = mysql_fetch_field(_res);
            _columns ~= to!(string)(field.name);
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
            mysql_free_result(_res);
            _usable = false;
        }
    }
    
    
    /**
     * Fetches row
     *
     * Returned data is Row class, can be accessed like normal
     *  or associative array. If error occured, exception is thrown.
     *
     * Examples:
     * ---
     * auto res = db.query("SELECT ...");
     * while(res.isValid)
     * {
     *     writeln(res.fetchAssoc());
     *     res.next();
     * }
     * ---
     *
     * Throws:
     *    DatabaseException
     *
     * Returns:
     *  Array with current row data
     */
    public override Row fetch(string file = __FILE__, uint line = __LINE__)
    {
        MYSQL_ROW crow;
        string[] row;
        
        crow = mysql_fetch_row(_res);
        
        if(crow is null) {
            throw new DatabaseException("Could not fetch row.", file, line);
        }
        
        for(int i; i < _columnNum; i++ ) {
            row ~= to!string(crow[i]);
        }
        
        // Sync
        mysql_data_seek(_res, cast(uint)_index);
        
        return new Row(row, _columns);
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
        if( ++_index >= _rows  )
        {
            return false;
        }
        
        mysql_data_seek(_res, cast(uint)_index);
        
        return true;
    }
    
    
    /**
     * Resets current index
     */
    public override void reset()
    {
        _index = 0;
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
    public override string[] columns() @property
    {
        return _columns;
    }
    
    /**
     * Check if there are any rows remeaining
     *
     * Returns:
     *  True if there are any remeaining rows
     */
    public override bool isValid() @property
    {
        return (_index < _rows) && _usable;
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