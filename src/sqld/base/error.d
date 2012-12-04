module sqld.base.error;

/**
 * Represents database error
 */
struct SqlError
{
    protected int _code;
    protected DatabaseErrorType _type;
    protected string _message;
    
    
    
    /**
     * Creates new SqlError instance
     * 
     * Params:
     *  code = Numeric error code
     *  type = Error type
     *  message = Error message. May be localized.
     */
    this(int code, DatabaseErrorType type, string message)
    {
        _code = code;
        _type = type;
        _message = message;
    }
    
    
    /**
     * Gets numeric error code
     * 
     * The code is specific to database driver.
     */
	@property int code()
    {
        return _code;
    }
    
    
    /**
     * Gets database error type
     */
    @property DatabaseErrorType type()
    {
        return _type;
    }
    
    
    /**
     * Gets database error message.
     * 
     * Message may be localized.
     */
    @property string message()
    {
        return _message;
    }
}


/**
 * Database error types
 */
enum DatabaseErrorType
{
    /// No error occured
    NoError,
    
    /// Socket error
    SocketError,
    
    /// Connection issues
    ConnectionError,
    
    
    /// Server error
    ServerError,
        
    /// Out of sync
    OutOfSync,
    
    /// Invalid query specified
    InvalidQuery,
    
    /// Invalid query result
    InvalidData,
    
    
    /// Unknown error
    Unknown = 1024
}