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

enum DatabaseErrorCode
{
    NoError,
    
    SocketError,
    ConnectionError,
    ServerError,
        
    OutOfSync,
    InvalidQuery,
    InvalidData,
    
    Unknown = 1024
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
     * Error code
     */
    public int internalCode;
    
    /**
     * Internal error 
     */
    public DatabaseErrorCode code;
    
    /**
     * Creates new DatabaseError instance
     *
     * Params:
     *  number  = Error code
     */
    public this(int code)
    {
        update(code);
    }
    
    /**
     * Updates error to new error code
     */
    public void update(int code)
    {
        this.internalCode = code;
        this.code = errorToCode(code);
        this.message = codeToString(this.code);
    }
    
    /**
     * Converts error code to DatabaseErrorCode
     * 
     * Params:
     *  code = Internal error code
     * 
     * Returns:
     *  Converted code
     */
    protected DatabaseErrorCode errorToCode(int code)
    {
        return DatabaseErrorCode.Unknown;
    }
    
    /**
     * Returns: Error code in string form
     */ 
    public string codeToString(DatabaseErrorCode c)
    {
        switch(c)
        {
            case DatabaseErrorCode.NoError:
                return "No Error";
            break;
                            
            case DatabaseErrorCode.ConnectionError:
                return "Connection Error";
            break;
                
            case DatabaseErrorCode.InvalidQuery:
                return "Invalid query";
            break;
                
            case DatabaseErrorCode.InvalidData:
                return "Invalid data";
            break;
                
            case DatabaseErrorCode.ServerError:
                return "Server Error";
            break;
                
            case DatabaseErrorCode.OutOfSync:
                return "Out of sync";
            break;
            
            default:
                return "Unknown Error";
        }
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
        return message;
    }
    
    /**
     * Checks if any error occured
     */
    bool opCast(T)() if (is(T == bool))
    {
        return code != DatabaseErrorCode.NoError;
    }
}

class UnsupportedFeatureException : Exception {
    this(string s, string f = __FILE__, uint l = __LINE__) {
        super(s,f,l);
    }
}