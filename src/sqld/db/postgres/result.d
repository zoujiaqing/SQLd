module sqld.db.postgres.result;

import sqld.base.database,
       sqld.base.result,
       sqld.base.row,
       sqld.c.postgres,
       sqld.db.postgres.database;
       
import std.conv : to;
import std.string : stripRight;

/**
 * Postgres query result
 */
class PostgresResult : Result
{
    protected
    {
        PGconn*   _db;
        PGresult* _res;
        
        ulong     _rows;
        int       _fieldNum;
        int       _index;
        
        string[]  _columns;
        Row       _row;
        bool      _usable;
        ulong     _affected;
    }
    
    
    /**
     * Creates new PostgresResult instance
     *
     * Params:  
     *  db = Database
     *  res = Postgre result
     */
    public this(PGconn* db, PGresult* res)
    {
        _db = db;
        _res = res;
        
        if(PQresultStatus(res) == PGRES_TUPLES_OK)
        {
            _rows = PQntuples(_res);
            _fieldNum = PQnfields(_res);
            
            loadColumns();
            _usable = true;            
            loadRow();
        }
        else if(PQresultStatus(res) == PGRES_COMMAND_OK)
        {
            string strres = to!string(PQcmdTuples(_res));
            if(strres != "") {
                _rows = to!ulong(strres);
            }
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
    protected void loadColumns()
    {
        for(int i; i < _fieldNum; i++)
        {
            _columns ~= to!string(PQfname(_res, i)); 
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
     *    DatabaseException
     *
     * Returns:
     *  Array with current row data
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
        if( ++_index < _rows  )
        {
            loadRow();
            return true;
        }
        
        return false;
    }
    
    /**
     * Resets current index
     */
    public override void reset()
    {
        _index = 0;
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
            PQclear(_res);
            _usable = false;
        }
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
    
    protected void loadRow()
    {
        string[] row;
        int size;
        
        for(int i; i < _fieldNum; i++ )
        {
            row ~= to!string(PQgetvalue(_res, _index, i)).stripRight();
        }
        
        _row = new Row(row, _columns);
    }
}
