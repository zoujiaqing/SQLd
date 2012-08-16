module sqld.statement;

import sqld.base.database,
       sqld.base.result;
import std.conv : to;
import std.array : replace, replaceFirst;

import std.stdio;

/**
 * Represents statement
 */
class Statement
{
    alias typeof(this) self;
    
    protected Database _db;
    protected string   _query;
    /*protected string[] _bindings;
    protected string[string] _named;*/
    
    /**
     * Creates new statement
     *
     * Params:
     *  db = Database
     *  query = Query to bind and execute 
     */
    public this(Database db, string query)
    {
        _query = query;
        _db = db;
    }
    
    /**
     * Binds value
     *
     * Binded values are keeped, and binded on compilation of statement.
     * Variables binded using this function will be replaced for `?` characters.
     * Binded values are escaped.
     *
     * Params:
     *  value = Value to bind
     *
     * Returns:
     *  Self
     */
    public self bind(T)(T _value, bool escape = true)
    {
        string value = to!string(_value);
        _query = _query.replaceFirst("?", escape ? _db.escape(value) : value);
        
        
        return this;
    }
    
    /**
     * Binds value
     *
     * Binded values are keeped, and binded on compilation of statement.
     * Variables binded using this function will be replaced for string specified
     * in name parameter. Binded values are escaped.
     *
     * Params:
     *  name = Name to replace
     *  value = Value to bind
     *
     * Returns:
     *  Self
     */
    public self bind(T)(string name, T _value, bool escape = true)
    {
        string value = to!string(_value);
        _query = _query.replace(name, escape ? _db.escape(value) : value);
        
        return this;
    }
    
    /**
     * Compiles and executes statement
     *
     * Returns:
     *  Query result
     */
    public Result execute()
    {
        return _db.query(_query);
    }
}