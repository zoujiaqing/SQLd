module sqld.db.postgre.result;

import sqld.base,
       sqld.c.postgre,
       sqld.db.postgre.database;
       
import std.conv : to;

class PostgreResult : Result
{
    protected PGresult* _res;
    protected int       _rows;
    protected int       _fieldNum;
    protected int       _index;
    protected string[]  _fields;
    protected bool      _usable;
    
    
    /**
     * Creates new PostgreResult instance
     *
     * Params:  
     *  res = Postgre result
     */
    public this(PGresult* res)
    {
        _res = res;
        
        if(PQresultStatus(res) == PGRES_TUPLES_OK)
        {
            _rows = PQntuples(_res);
            _fieldNum = PQnfields(_res);
            
            loadFields();
            _usable = true;
        }
    }
    
    public ~this()
    {
        if(_usable) {
            PQclear(_res);
        }
    }
    
    /**
     * Loads field array
     */
    protected void loadFields()
    {
        for(int i; i < _fieldNum; i++)
        {
            _fields ~= to!string(PQfname(_res, i)); 
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
     *     writeln(res.fetch());
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
        string[] row;
        
        for(int i; i < _fieldNum; i++ )
        {
            row ~= to!string(PQgetvalue(_res, _index, i));
        }
        
        
        return new Row(row, _fields);
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
     * Frees result
     *
     * After freeing instance is not usable anymore
     */
    public void free()
    {
        if(_usable)
        {
            PQclear(_res);
            _usable = false;
        }
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
