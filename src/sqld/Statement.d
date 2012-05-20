module sqld.statement;

import sqld.base;
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
    protected string[] _bindings;
    protected string[string] _named;
    
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
    public self bind(T)(T value)
    {
        _bindings ~= to!string(value);
        
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
    public self bind(T)(string name, T value)
    {
        _named[name] = to!string(value);
        
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
        compile();
        return _db.query(_query);
    }
    
    /**
     * Compiles statement
     * 
     * All bindings are placed into query, registered bindings are removed after compilation.
     *
     * Returns:
     *  Self
     */
    protected void compile()
    {
        foreach(name, value; _named)
        {
            _query = _query.replace(name, _db.escape(value));
        }
        _named = _named.init;
        
        foreach(binding; _bindings)
        {
            _query = _query.replaceFirst("?", _db.escape(binding));
        }
        _bindings = _bindings.init;
    }
}