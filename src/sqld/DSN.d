module sqld.dsn;

import sqld.base;
import std.array, std.algorithm, std.traits;

alias countUntil indexOf;

/**
 * Represents DSN
 */
struct Dsn
{
    /**
     * Driver name
     */
    public string driver;
    
    /**
     * Parameters
     */
    public string[string] params;
    
    alias params this;
    
    
    /**
     * Creates new Dsn instance
     *
     * Specified dsn is automaticly parsed.
     *
     * Params:
     *  dsn = DataSourceName
     */
    public this(string dsn)
    {
        parse(dsn);
    }
    
    /**
     * Parses DSN
     *
     * Params:
     *  dsn = DSN to parse
     *
     * Throws:
     *  DsnException If Dsn is invalid
     *
     * Returns:
     *  Dsn
     */
    public typeof(this) parse(string dsn)
    {
        size_t pos = dsn.indexOf(":");
        if(pos == -1)
        {
            throw new DsnException("No driver specified");
        }
        
        driver = dsn[0..pos];
        dsn = dsn[pos+1..$];
        
        auto parts = dsn.splitEx(";");
        foreach(part; parts)
        {
            auto kv = part.splitEx("=", 1);
            
            if(kv.length < 2)
            {
                throw new DsnException("Invalid Key-Value pair.");
            }
            
            params[kv[0]] = kv[1];
        } 
        
        return this;
    }
    
    /**
     * Returns param value
     *
     * If parameter with name was not found and def param is not
     * null, def is returned, Exception is thrown otherwise
     *
     * Params:
     *  name = Parameter name
     *  def = Default value if param does not exist
     *
     * Throws:
     *  Exception if name does not exists and def is null
     * 
     * Returns:
     *  Parameter value  
     */
    public string get(string name, string def = null)
    {
        if( name in params )
        {
            return params[name];
        }
        else
        {
            if(def !is null) return def;
            else
                throw new Exception("Unknown param '"~name~"'");
        }
    }
    
    /// ditto
    alias get opIndex;
}

/**
 * Thrown if error occured while parsing Dsn
 */
class DsnException : Exception
{
    ///
    this(string txt = "", string file = __FILE__, int line = __LINE__)
    {
        super(txt, file, line);
    }
}

/**
 * Splits string by delimeter
 *
 * Params:
 *  txt = Text to split
 *  delim   =   Delimeter
 *  limit = Limit of splits
 *  escape = Escape character
 *
 * Returns:
 *  Splitted string
 */
T[] splitEx(T, S)(T txt, S delim = " ", int limit = 0, char escape = '\\')
    if(isSomeString!T && isSomeString!S)
{
    T[] parts;
    char prev;
    int last, len = delim.length, cnt;

    for(int i = 0; i < txt.length; i++)
    {
        if( limit > 0 && cnt >= limit)
            break;
        
        if(txt[i .. min(i + len, txt.length)] == delim && prev != escape)
        {
            parts ~= txt[last .. i].replace(escape~delim, delim);
            last = min(i + 1, txt.length);
            ++cnt;
        }
        prev = txt[i];
    }

    parts ~= txt[last .. txt.length].replace(escape~delim, delim);
    return parts;
}