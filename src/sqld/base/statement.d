module sqld.base.statement;

import sqld.base.database,
       sqld.base.result;
import std.conv : to;
import std.array : replace, replaceFirst;
import std.traits : isSomeString;

/**
 * Represents statement
 */
class Statement
{
    alias typeof(this) self;
    
    protected Database _db;
    protected string   _query;
    
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
	
	abstract public string wrapColumn(string s);
	abstract public string wrapValue(string s);
    
	/**
     * Binds column
     *
     * Params:
     *  value = Value to bind
     *
     * Returns:
     *  Self
     */
    public self bindColumn(T)(T _value)
    {
        string value = to!string(_value);
		
		static if(isSomeString!T) {
            value = wrapColumn(_db.escape(value));
        }
        
        _query = _query.replaceFirst("?", value);
        
        return this;
    }
    
    /**
     * Binds column
     *
     * Params:
     *  name = Name to replace
     *  value = Value to bind
     *
     * Returns:
     *  Self
     */
    public self bindColumn(T)(string name, T _value)
    {
		string value = to!string(_value);
		
		static if(isSomeString!T) {
            value = wrapColumn(_db.escape(value));
		}
		
        _query = _query.replace(name, value);
        
        return this;
    }
    
    /**
     * Binds value
     *
     * Params:
     *  value = Value to bind
     *
     * Returns:
     *  Self
     */
    public self bindValue(T)(T _value)
    {
        string value = to!string(_value);
		
		static if(isSomeString!T) {
            value = wrapValue(_db.escape(value));
		}
		        
        _query = _query.replaceFirst("?", value);
        
        return this;
    }
    
    /**
     * Binds value
     *
     * Params:
     *  name = Name to replace
     *  value = Value to bind
     *
     * Returns:
     *  Self
     */
    public self bindValue(T)(string name, T _value)
    {	
		string value = to!string(_value);
		
		static if(isSomeString!T) {
            value = wrapValue(_db.escape(_value));
		}
		
		_query = _query.replace(name, value);
        
        return this;
    }
    
    /**
     * Built query
     */
    public string query() @property
    {
        return _query;
    }
    
    /// ditto
    alias query toString;
    
    
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