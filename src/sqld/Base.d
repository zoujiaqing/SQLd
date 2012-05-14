/**
 * This file is part of sqlD library
 *
 * Autors: Robert 'Robik' Pasiński
 * License: MIT License
 */
module sqld.base;

import std.array     : replace;
import std.conv      : to;
import std.algorithm : countUntil;

/**
 * Represents abstract database
 */
interface Database
{
    /**
     * Connects to database
     */
    abstract typeof(this) connect();
    
    /**
     * Disconnects from database
     */
    abstract typeof(this) close();
    
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
     *  values = Values to bind
     *
     * Returns:
     *  Result
     */
    abstract Result query(string query, string[] params...);
}

interface Result
{
    bool isValid() @property;
    bool next();
    void reset();
    
    public string[] fields() @property;
    public int fieldCount() @property;
    public ulong length() @property;
    alias length rowCount;
    
    public string[] fetchRow();
    public string[string] fetchAssoc();
    
    public ulong index() @property;
    public void index(ulong n) @property;
    
    alias isValid empty;
    alias fetchRow front;
    alias next popFront;
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
    
    /**
     * Error number
     */
    public int number;
    
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
    public string toString()
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
    protected string[] _data;
    
    /**
     * Field names
     */
    protected string[] _fields;
    
    
    /**
     * Creates new row instance
     *
     * Params:
     *  data = Row data
     */
    this(string[] data, string[] fields)
    {
        _data = data;
        _fields = fields;
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
        return _data[i];
    }
    
    // ToDo: Add keyExists etc
    
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
        uint i = _fields.countUntil(name);
        
        if(i == -1)
        {
            throw new Exception("Index does not exists");
        }
        
        return _data[i];
    }
    
    /**
     * Fields array
     *
     * Returns:
     *  Array of field names
     */
    public string[] fields() @property
    {
        return _fields;
    }
    
    public int opApply( int delegate(string name, string value) dg )
    {
        int result;
        
        for(int i; i < _fields.length; i++)
        {
            result = dg(_fields[i], _data[i]);
            
            if(result) break;
        }
        
        return result;
    }
}
