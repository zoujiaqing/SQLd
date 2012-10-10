module sqld.base.statement;

import sqld.base.database,
       sqld.base.result;
import std.conv : to;
import std.array : replace, replaceFirst;
import std.traits : isSomeString;
import std.datetime;
import std.regex;

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
        _query = _query.replaceFirst("?", serialize(_value, &wrapColumn));
        
        return this;
    }
    
    /**
     * Binds column
     * 
     * This function uses simple string replacement, it may cause replacing prefixes
     * of other values.
     * 
     * Example:
     * ---
     * auto stmt = db.prepare("SELECT :columns WHERE :column = 1")
     *   .bindColumn(":column", "TEST");
     * 
     * // qoutes around TEST depends on database
     * assert(stmt.query == "SELECT `TEST`s WHERE `TEST` = 1");
     * // :columns got replaced too
     * ---
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
	    _query = _query.replace(name, serialize(_value, &wrapColumn));
        
        return this;
    }
    
    /**
     * Binds column
     * 
     * This function uses regex for replacing, to avoid replacing prefixes
     * of other values.
     * 
     * Example:
     * ---
     * auto stmt = db.prepare("SELECT :columns WHERE :column = 1")
     *   .bindColumnEx(":column", "TEST");
     * 
     * // qoutes around TEST depends on database
     * assert(stmt.query == "SELECT :columns WHERE `TEST` = 1");
     * ---
     *
     * Params:
     *  name = Name to replace
     *  value = Value to bind
     *
     * Returns:
     *  Self
     */
    public self bindColumnEx(T)(string name, T _value)
    {
        auto r = regex(name~`(?=\W)`);
        _query = std.regex.replace(_query, r, serialize(_value, &wrapColumn));
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
        _query = _query.replaceFirst("?", serialize(_value, &wrapValue));
        
        return this;
    }
    
    /**
     * Binds value
     * 
     * This function uses simple string replacement, it may cause replacing prefixes
     * of other values. See `bindColumn` example for more details.
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
		_query = _query.replace(name, serialize(_value, &wrapValue));
        
        return this;
    }
    
    /**
     * Binds value
     * 
     * This function uses regex for replacing, to avoid replacing prefixes
     * of other values.
     * 
     * Params:
     *  name = Name to replace
     *  value = Value to bind
     *
     * Returns:
     *  Self
     */
    public self bindValueEx(T)(string name, T _value)
    {
        auto r = regex(name~`(?=\W)`);
        _query = std.regex.replace(_query, r, serialize(_value, &wrapValue));
        
        return this;
    }
	
	protected string serialize(T)(T _value, string delegate(string) wrap)
	{
		string value = to!string(_value);
        
		static if(isSomeString!T) {
            value = wrap(_db.escape(value));
		}        
        else static if(is(T == bool)) {
            value = wrap(_value ? "1" : "0");
        }
		else static if(is(T : char)) {
			value = _db.escape((&_value)[0..1].idup)[0..$];
		}
		else static if(is(T == Date) || is(T == TimeOfDay)) {
			value = wrap(_value.toISOExtString());
		}
		else static if(is(T == DateTime)) {
			value = wrap(
				_value.date.toISOExtString() ~ " " ~
				_value.timeOfDay.toISOExtString()
			);
		}
		
		return value;
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
        return _db.execute(_query);
    }
}