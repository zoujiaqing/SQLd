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
        MYSQL_RES* _res;
        bool _usable;
        
        string[] _fields;
        int _fieldNum;
        
        ulong _rows;
        ulong _index;
    }
    
    
    /**
     * Creates new MySQLResult instance
     *
     * Params:  
     *  res = MySQL result
     */
    this( MYSQL_RES* res)
    {
        _res = res;
        
        if(res !is null)
        {
            _rows = mysql_num_rows(_res);
            _fieldNum = mysql_num_fields(_res);
            
            if(_fieldNum <= 0)
            { 
                throw new DatabaseException("Result set is empty");
            }
            
            loadFields();
            
            _usable = true;
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
    protected void loadFields()
    {
        MYSQL_FIELD* field;
        for (uint i = 0; i < _fieldNum; i++)
        {
            field = mysql_fetch_field(_res);
            _fields ~= to!(string)(field.name);
        }
    }
    
    
    /**
     * Frees result
     *
     * After freeing instance is not usable anymore
     */
    public void free()
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
    public Row fetch(string file = __FILE__, uint line = __LINE__)
    {
        MYSQL_ROW crow;
        string[] row;
        
        crow = mysql_fetch_row(_res);
        
        if(crow is null)
        {
            throw new DatabaseException("Could not fetch row.", file, line);
        }
        
        for(int i; i < _fieldNum; i++ )
        {
            row ~= to!string(crow[i]);
        }
        
        // Sync
        mysql_data_seek(_res, cast(uint)_index);
        
        return new Row(row, _fields);
    }
    
    /**
     * Loops through rows
     *
     * Params:
     *  Callback to call on each row occurence
     */
    public void each(bool delegate(Row) dg)
    {
        while(isValid)
        {
            if(!dg(fetch()))
                break;
                
            if(!next())
                break;
        }
    }
    
    /**
     * Proceedes to next row
     *
     * If no rows are remeaining, returns false.
     *
     * Returns:
     *  True if any rows are remaining, false otherwise
     */
    public bool next()
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
    public void reset()
    {
        _index = 0;
    }

    /**
     * Query result row count
     *
     * Returns:
     *  Row count
     */
    public ulong length() @property
    {
        return _rows;
    }
    
    /**
     * Query result fields
     *
     * Returns:
     *  Array of fields
     */
    public string[] fields() @property
    {
        return _fields;
    }
    
    /**
     * Check if there are any rows remeaining
     *
     * Returns:
     *  True if there are any remeaining rows
     */
    public bool isValid() @property
    {
        return (_index < _rows) && _usable;
    }
    
    /**
     * Current row index
     *
     * Returns:
     *  Current row offset
     */
    public ulong index() @property
    {
        return _index;
    }
    
    
    /* Range stuff */
    bool empty()
    {
        return _index >= _rows;
    }
    Row front() { return fetch(); }
    void popFront() { next(); }
}