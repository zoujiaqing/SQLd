/**
 * This file is part of sqlD library
 *
 * Autors: Robert 'Robik' Pasiński
 * License: MIT License
 */
module sqld.base;

import std.array     : replace, join;
import std.conv      : to, ConvException;
import std.algorithm : countUntil;
import std.traits;

import sqld.dsn,
       sqld.statement,       
       sqld.db.mysql.database,
       sqld.db.sqlite.database,
       sqld.db.postgre.database;

 
/**
 * Represents abstract database
 */
abstract class Database
{
    /**
     * Connects to database
     */
    abstract Database open();
    
    /**
     * Disconnects from database
     */
    abstract Database close();
    
    
    /**
     * Last error
     *
     * Returns:
     *  Error - Last error
     */
    abstract DatabaseError error() @property;
    
    /**
     * Checks if any error occured
     *
     * Returns:
     *  True if any error occured, false otherwise
     */
    abstract bool isError() @property;
    
    /**
     * Executes query and returns result
     *
     * Params:
     *  query = Query to execute
     *
     * Returns:
     *  Result
     */
    abstract Result query(string query, string file = __FILE__, uint line = __LINE__);
    
    /**
     * Begins transaction
     */
    //abstract Transaction beginTransaction(); Work In Progress
    
    /**
     * Prepares new statement with speicified query
     *
     * Params:
     *  query = Statement query
     *
     * Returns:
     *  New statement
     */
    abstract Statement prepare(string query);
    
    /**
     * Queries database with specified query
     *
     * Params:
     *   query = Query to execute
     *
     * Throws:
     *  DatabaseException
     *
     * Returns:
     *   Affected rows
     */
    abstract public ulong execute(string query, string file = __FILE__, uint line = __LINE__);
    
    /**
     * Returns last inserted row id
     */
    abstract public ulong insertedId() @property; 
    
    /**
     * Escapes string
     *
     * Params:
     *  str = String to escape
     *
     * Returns:
     *  Escaped string
     */
    abstract public string escape(string str);

    /**
     * Current database instance
     */
    static Database instance = null;
    
    /**
     * Creates new database instance
     * 
     * Params:
     *  _dsn = Data source name
     *
     * Returns:
     *  Database instance
     */
    static Database factory(string _dsn)
    {
        auto dsn = Dsn(_dsn);
        
        switch(dsn.driver)
        {
            case "mysql":
                Database.instance = new MySQL(dsn);
            break;
            
            case "sqlite":
                Database.instance = new SQLite(dsn);
            break;
            
            case "postgre":
                Database.instance = new Postgre(dsn);
            break;
            
            default:
                assert(0, "Unsupported database type");
        }
        
        return Database.instance;
    }
}


/**
 * Represents database query result
 */
interface Result
{
    bool isValid() @property;
    bool next();
    void reset();
    
    public string[] fields() @property;
    public ulong length() @property;
    
    public Row fetch(string file = __FILE__, uint line = __LINE__);
    
    public ulong index() @property;
    public void free();
    
    bool empty();
    Row front();
    void popFront();
}

/**
 * Thrown if there was any database-releated error
 */
class DatabaseException : Exception
{
    ///
    this(string txt = "", string file = __FILE__, int line = __LINE__)
    {
        super(txt, file, line);
    }
}

/**
 * Represents database error
 */
class DatabaseError
{
    /**
     * Error message
     */
    public string message;
    
    /// ditto
    alias message msg;
    
    /**
     * Error number
     */
    public int number;
    
    /// ditto
    alias number code;
    
    /**
     * Source code file name in which error occured
     */
    public string file;
    
    /**
     * Source code liine in which error occured
     */
    public int line;
    
    
    /**
     * Creates new DatabaseError instance
     *
     * Params:
     *  number  = Error number
     *  message = Error message
     *  file    = Source code file
     *  line    = Source code line
     */
    public this(int number, string message)
    {
        this.number  = number;
        this.message = message;
    }
    
    /**
     * Represents error as one string
     *
     * Returned format can be changed using second overload
     * of this function.
     *
     * Returns:
     *  Formatted error string
     */
    public override string toString()
    {
        return toString("($n):$m");
    }
    
    /**
     * Represents error as one string
     * 
     * Params:
     *  format = Returned string format, two "variables" are available:
     *    $n, which represents number and $m which represents message.
     *
     * Returns:
     *  Formatted message
     */
    public string toString(string format)
    {
        string formatted = format;
        formatted = formatted.replace("$n", to!string(number));
        formatted = formatted.replace("$m", message);
        return formatted;
    }
}

/**
 * Represents table row
 */
class Row
{
    /**
     * Row data
     */
    protected string[string] _data;
    
    
    /**
     * Creates new row instance
     *
     * Params:
     *  data = Row data
     */
    this(string[] data, string[] fields)
    {
        for(int i; i < fields.length; i++)
        {
            _data[fields[i]] = data[i];
        }
    }
    
    /**
     * Returns row value
     *
     * Params:
     *  Field name
     * 
     * Returns:
     *  Row value
     */
    public string opIndex(string name)
    {
        if(name !in _data)
        {
            throw new Exception("Index does not exists");
        }
        
        return _data[name];
    }
    
    /**
     * Returns row value
     *
     * Params:
     *  Field id
     * 
     * Returns:
     *  Row value
     */
    public string opIndex(uint i)
    {
        return _data.values[i];
    }
    
    /**
     * Fields array
     *
     * Returns:
     *  Array of field names
     */
    public string[] fields() @property
    {
        return _data.keys;
    }
    
    public int opApply( int delegate(string name, string value) dg )
    {
        int result;
        
        foreach(field, value; _data)
        {
            result = dg(field, value);
            
            if(result) break;
        }
        
        return result;
    }
    
    /**
     * Returns: associative array that represents row
     */
    public string[string] toAssocArray()
    {
        return _data;
    }
    
    /**
     * Returns: associative array that represents row
     */
    public string[] toArray()
    {
        return _data.values;
    }
    
    /**
     * Returns row, as single string
     *
     * Returns:
     *  Row representation, as string
     */
    public override string toString()
    {
        return to!string(_data);
    }
    
    /**
     * Returns row as specified struct
     *
     * If one of the fields cannot be casted to member type exception is thrown.
     *
     * Authors:
     *  dav1d
     *
     * Throws:
     *  Exception
     */
    T as(T)()
    {
        T result;   
        
        foreach(name; __traits(allMembers, T)) {
            try {
                mixin(`result.` ~ name ~` = to!(typeof(result.`~name~`))(_data["` ~ name ~ `"]);`);
            } catch(ConvException e) {
                throw new Exception("Cannot cast field '"~name~"' to " ~ mixin("typeof(result."~name~").stringof"));
            }
        }
        
        return result;
    }
}
