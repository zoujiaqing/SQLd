module sqld.db.mysql.result;

import std.conv;

import 
       sqld.exception,
       sqld.base.result,
       sqld.db.mysql.c.mysql;


/**
 * Represents MySql query result
 */
class MySqlResult : IResult
{
    protected
    {
        MYSQL* _db;
        MYSQL_RES* _res;
        bool _usable;
        bool _empty;
        string[] _row;
        
        string[] _columns;
        int _columnNum;
        ulong _index;
    }
    
    
    /**
     * Creates new MySqlResult instance
     * 
     * Params:
     *  sql = MySql connection handle
     *  res = MySql query result handle
     */
	this(MYSQL* sql, MYSQL_RES* res)
	{
        _db = sql;
        _res = res;
        
        if(res !is null)
        {
            // Result has data
            //_rows = mysql_num_rows(_res);
            _columnNum = mysql_num_fields(_res);
            
            loadColumns();
            _usable = true;
            _empty = readRow();
        }
        else
            _usable = false;
	}
    
    
    ~this()
    {
        free();
    }
    
    protected void loadColumns()
    {
        MYSQL_FIELD* field;
        for (uint i = 0; i < _columnNum; i++)
        {
            field = mysql_fetch_field(_res);
            _columns ~= to!(string)(field.name);
        }
    }
    
    
    protected bool readRow()
    {        
        MYSQL_ROW crow;
        _row = [];
        
        crow = mysql_fetch_row(_res);
        
        if(crow is null) {
            return true;
        }
        
        for(int i; i < _columnNum; i++ ) {
            _row ~= to!string(crow[i]);
        }
        
        return false;
    }
    
    
    /**
     * Proceedes to next row
     */
    void popFront()
    {   
        _empty = readRow();
    }
    
    
    /**
     * Returns current row
     */
    @property string[] front()
    {
        return _row;
    }
    
    
    /**
     * Frees result
     *
     * After freeing instance is not usable anymore
     */
    void free()
    {
        if(_usable)
        {
            mysql_free_result(_res);
            _usable = false;
        }
    }
    
    
    /**
     * Checks if there are more rows remaining
     */
    @property bool empty()
    {
        return _empty;
    }
    
    /**
     * Result column names
     *
     * Returns:
     *  Array of column names
     */
    @property string[] columns()
    {
        return _columns;
    }
    
    
    /**
     * Current row index
     *
     * Returns:
     *  Current row offset
     */
    @property ulong index()
    {
        return _index;
    }
    
    
    /**
     * Number of columns
     */
    @property int columnCount()
    {
        return _columnNum;
    }
}

