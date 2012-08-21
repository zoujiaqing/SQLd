module sqld.base.error;

import std.array     : replace, join;
import std.conv      : to;

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
 * Thrown if there was error durning connecting to database, or connection was lost
 */
class ConnectionException : DatabaseException
{
    ///
    this(string txt = "", string file = __FILE__, int line = __LINE__)
    {
        super(txt, file, line);
    }
}

/**
 * Thrown if invalid connection details where specified
 */
class ConnectionDetailsException : DatabaseException
{
    ///
    this(string txt = "", string file = __FILE__, int line = __LINE__)
    {
        super(txt, file, line);
    }
}

/**
 * Thrown if error occured durning executing query
 */
class QueryException : DatabaseException
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
     * Creates new DatabaseError instance
     *
     * Params:
     *  number  = Error number
     *  message = Error message
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

class UnsupportedFeatureException : Exception {
    this(string s, string f = __FILE__, uint l = __LINE__) {
        super(s,f,l);
    }
}