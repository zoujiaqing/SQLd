module sqld.statement;

import sqld.base;
import std.conv : to;
import std.array : replace, replaceFirst;

/**
 * Represents statement
 */
class Statement
{
    alias typeof(this) self;
    
    protected Database db;
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
        
        return db.query(_query);
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
            _query = _query.replace(name, value);
        }
        _named = _named.init;
        
        foreach(binding; _bindings)
        {
            _query = _query.replaceFirst("?", binding);
        }
        _bindings = _bindings.init;
    }
}