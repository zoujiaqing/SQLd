module sqld.db.mysql.table;

import std.algorithm,
       std.string,
       std.conv;

import sqld.field,
       sqld.db.mysql.connection,
       sqld.db.mysql.result,
       sqld.db.mysql.field,
       sqld.db.mysql.c.mysql;


/**
 * Represents MySql database tables
 */
final class MySqlTableInfo
{
    protected MySqlConnection _conn;
    protected string[] _tables;
    
    
    /**
     * Creates new MySqlTables instance
     */
    this(MySqlConnection conn)
    {
        _conn = conn;
        
        loadTablesInfo();
    }
    
    
    /**
     * Gets table information with specified name
     * 
     * Params:
     *  Table name
     */
    MySqlTable opIndex(string name)
    {
        return new MySqlTable(_conn, name);
    }
    
    
    /**
     * Checks if specified table exists
     * 
     * Params:
     *  name = Table name
     * 
     * Returns:
     *  True if it exists, false otherwise
     */
    bool exists(string name)
    {
        return (_tables.countUntil(name) != -1);
    }
    
    
    /**
     * Iterates over database tables
     */
    int opApply(int delegate(MySqlTable) dg)
    {
        int result;
        
        for (int i; i < _tables.length; i++)
        {
            result = dg(new MySqlTable(_conn, _tables[i]));
            
            if (result)
                break;
        }
        
        return result;
    }
    
    
    /**
     * Iterates over database tables
     */
    int opApply(int delegate(uint, MySqlTable) dg)
    {
        int result;
        
        for (int i; i < _tables.length; i++)
        {
            result = dg(i, new MySqlTable(_conn, _tables[i]));
            
            if (result)
                break;
        }
        
        return result;
    }
    
    
    /*
     * Loads table names
     */
    protected void loadTablesInfo()
    {
        auto res = _conn.executeQuery("SHOW TABLES");
        _tables.length = cast(size_t)res.length;
        
        foreach(row; res)
        {
            _tables[cast(size_t)res.index] = row[0];
        }
    }
}


/**
 * Represents MySql table information
 */
final class MySqlTable
{
    protected MySqlConnection _conn;
    protected MySqlResult _res;
    protected string _tableName;
    protected MySqlField[] _fields;
    
    
    /**
     * Creates new MySqlTable info instance
     * 
     * Params:
     *  conn = Database connection
     *  table = Table name
     */
	this(MySqlConnection conn, string tableName)
	{
		_conn = conn;
        _tableName = tableName;
        loadInfo();
	}
    
    
    /**
     * Gets table name
     */
    @property string name()
    {
        return _tableName;
    }
    
    
    /**
     * Gets table fields
     */
    @property MySqlField[] fields()
    {
        return _fields;
    }
    
    /*
     * Loads table information and parses it
     */
    protected void loadInfo()
    {
        _res = _conn.executeQuery("SHOW COLUMNS FROM " ~ _tableName);
        _fields.length = cast(size_t)_res.length;
        
        foreach(row; _res)
        {
            size_t i = cast(size_t)_res.index;
            int start = row[1].countUntil("(");
            string type;
            if(start != -1)
            {
                int end = row[1][start..$].countUntil(")") + start;
                _fields[i].length = to!uint(row[1][start+1 .. end]);
                
                type = row[1][0..start];
            }
            else
                type = row[1];
            
            _fields[i].type = parseType(type);
            _fields[i].nullable = (row[2] == "YES");
            _fields[i].name = row[0];
            _fields[i].key = parseKey(row[3]);
            _fields[i].defaultValue = row[4];
        }
    }
    
    /*
     * Parses MySql type to generic field type
     */
    protected FieldType parseType(string type)
    {
        type = type.toLower();
        switch(type)
        {
            case "varchar":
            case "text":
                return FieldType.String;
                
            case "blob":
                return FieldType.Blob;
               
            case "tinyint":
            case "boolean":
            case "bit":
                return FieldType.Bool;
                
            case "smallint":
                return FieldType.Short;
                                
            case "int":
            case "mediumint":
                return FieldType.Integer;
                
            case "float":
                return FieldType.Float;
                
            case "double":
                return FieldType.Double;
                
            case "datetime":
            case "timestamp":
                return FieldType.DateTime;
                
            case "time":
                return FieldType.Time;
                
            case "date":
                return FieldType.Date;
                
            default:
                assert(0, "Unsupported type " ~type);
        }
    }
    
    /*
     * Parses table key
     */
    protected KeyType parseKey(string str)
    {
        switch(str.toLower)
        {
            case "pri":
                return KeyType.Primary;
                
            case "uni":
                return KeyType.Unique;
                
            default:
                return KeyType.None;
        }
    }
}

