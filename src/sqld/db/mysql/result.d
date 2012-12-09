module sqld.db.mysql.result;

import std.conv;

import sqld.row,
       sqld.exception,
       sqld.field,
       sqld.base.result,
       sqld.db.mysql.c.mysql,
       sqld.db.mysql.types;


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
        DataRow _row;
        ulong _rows;
        
        Field[] _fields;
        string[] _fieldNames;
        int _fieldCount;
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
        
        // Result contains data
        if(res !is null)
        {
            _rows = mysql_num_rows(_res);
            _fieldCount = mysql_num_fields(_res);
            
            loadFields();
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
    
    
    /**
     * Proceedes to next row
     */
    void popFront()
    {   
        _empty = readRow();
        ++_index;
    }
    
    
    /**
     * Returns current row
     */
    @property DataRow front()
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
        return _empty || !_usable;
    }
    
    /**
     * Gets result field infos
     */
    @property Field[] fields()
    {
        return _fields;
    }
    
    
    /**
     * Gets current row index
     */
    @property ulong index()
    {
        return _index;
    }
    
    
    /**
     * Gets number of fields
     */
    @property int fieldCount()
    {
        return _fieldCount;
    }
    
    
    /**
     * Checks if result is valid.
     * 
     * Returns false, if query executed produced no result, true otherwise.
     */
    @property bool valid()
    {
        return _usable;
    }
    
    
    /**
     * Gets result length in row count
     */
    @property ulong length()
    {
        return _rows;
    }
    
    
    /*
     * Loads field data
     */
    protected void loadFields()
    {
        MYSQL_FIELD* field;
        _fields.length = _fieldCount;
        _fieldNames.length = _fieldCount;
        
        for (uint i = 0; i < _fieldCount; i++)
        {
            field = mysql_fetch_field(_res);
            _fields[i].name = to!string(field.name);
            _fields[i].type = genericFieldTypeOf(field.type);
            _fieldNames[i] = _fields[i].name;
        }
    }
    
    
    /*
     * Fetches next row
     */
    protected bool readRow()
    {
        MYSQL_ROW crow;
        string[] _strRow;
        
        
        crow = mysql_fetch_row(_res);
        
        if(crow is null) {
            return true;
        }
        for(int i; i < _fieldCount; i++ ) {
            _strRow ~= to!string(crow[i]);
        }
        
        _row = new DataRow(_strRow, _fieldNames);
        return false;
    }
}

