module sqld.core.mysql.result;

import sqld.base,
       sqld.c.mysql,
       sqld.core.mysql.database;
       
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
 *     writeln(res.fetchRow());  
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
    /**
     * Self-instance
     */
    alias typeof(this) self;
    
    /**
     * MySQL query result
     */
    protected MYSQL_RES* _res;
    
    /**
     * Database instance
     */
    protected MySQL _db;
    
    /**
     * Is result usable?
     */
    protected bool _usable;
    
    /**
     * Fields
     */
    protected string[] _fields;
    
    /**
     * Number of fields
     */
    protected int _fieldNum;
    
    /**
     * Number of affected rows
     */
    protected ulong _rows;
    
    /**
     * Current row
     */
    protected ulong _index;
    
    
    /**
     * Creates new MySQLResult instance
     *
     * Params:  
     *  res = MySQL result
     */
    this( MYSQL_RES* res, MySQL db)
    {
        _res = res;
        _db  = db;
        
        if(res !is null)
        {
            _usable = true;
            _rows = mysql_num_rows(_res);
            _fieldNum = mysql_num_fields(_res);
            loadFields();
        }
    }
    
    ~this()
    {
        if(_usable)
            mysql_free_result(_res);
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
     * Returned data is array of string, with numeric indexes.
     * If error occured, exception is thrown.
     *
     * Examples:
     * ---
     * auto res = db.query("SELECT ...");
     * while(res.isValid)
     * {
     *     writeln(res.fetchRow());
     *     res.next();
     * }
     * ---
     *
     * Throws:
     *  DatabaseException
     *
     * Returns:
     *  Array with current row data
     */
    public string[] fetchRow(string file = __FILE__, uint line = __LINE__)
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
        index = _index;
        
        return row;
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
        index = _index;
        
        return new Row(row, _fields);
    }
    
    /**
     * Fetches row
     *
     * Returned data is assocative array. If error occured, 
     * exception is thrown.
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
     *  DatabaseException
     *
     * Returns:
     *  Array with current row data
     */
    public string[string] fetchAssoc(string file = __FILE__, uint line = __LINE__)
    {
        MYSQL_ROW crow;
        string[string] row;
        
        crow = mysql_fetch_row(_res);
        
        if(crow is null)
        {
            throw new DatabaseException("Could not fetch row.", file, line);
        }
        
        for(int i= 0; i < _fieldNum; i++ )
        {
            row[_fields[i]] = to!string(crow[i]);
        }
        
        // Sync
        index = _index;
        
        return row;
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
        
        mysql_data_seek(_res, _index);
        return true;
    }
    
    
    /**
     * Resets current index
     */
    public void reset()
    {
        index = 0;
    } 
    
    /**
     * Determines if this instance is usable
     *
     * Returns false, if INSERT/UPDATE and similar queries
     * that don't return data were executed and if result was freed.
     * isValid property includes it in itself.
     *
     * Returns:
     *  True if it is, false otherwise
     */
    public bool isUsable() @property
    {
        return _usable;
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
    /// ditto
    alias length rowCount;
    
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
     * Number of query result fields
     *
     * Returns:
     *  Number of fields
     */
    public int fieldCount() @property
    { 
        return _fieldNum;
    }
    
    /**
     * Check if there are any rows remeaining
     *
     * Returns:
     *  True if there are any remeaining rows
     */
    public bool isValid() @property
    {
        return (_index < _rows) && isUsable;
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
    
    /**
     * Sets new index
     *
     * Params:
     *  n = New offset
     */
    public void index(ulong n) @property
    {
        mysql_data_seek(_res, n);
        _index = n;
    } 
    
    /* Range stuff */
    bool empty()
    {
        return _index >= _rows;
    }
    alias fetchRow front;
    alias next popFront;
}