module sqld.base.error;

import std.string;


/**
 * Represents database error
 */
struct SqlError
{
    protected int _code;
    protected DatabaseErrorType _type;
    protected string _originalMessage;
    protected string _generatedMessage;
    
    
    
    /**
     * Creates new SqlError instance
     * 
     * Params:
     *  code = Numeric error code
     *  type = Error type
     *  originalMessage = Original error message.
     */
    this(int code, DatabaseErrorType type, string originalMessage)
    {
        _code = code;
        _type = type;
        _originalMessage = originalMessage;
        _generatedMessage = typeToString();
    }
    
    /**
     * SqlError as string
     * 
     * Returns:
     *  String representation of error
     */
    string toString()
    {
        return format("%s(%d): %s", 
            _generatedMessage, 
            _code, 
            _originalMessage
        );
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
    @property string originalMessage()
    {
        return _originalMessage;
    }
    
    
    /**
     * String representation of error type
     */
    @property string generatedMessage()
    {
        return _generatedMessage;
    }
    
    
    
    protected string typeToString()
    {
        switch(_type)
        {
            case DatabaseErrorType.ConnectionError:
                return "Connection Error";
            
            case DatabaseErrorType.InvalidStatement:
                return "Invalid Statement";
                
            case DatabaseErrorType.InvalidQuery:
                return "Invalid Query";
            
            case DatabaseErrorType.NoError:
                return "No Error";
                
            case DatabaseErrorType.NotImplemented:
                return "Not Implemented";
            
            case DatabaseErrorType.OutOfMemory:
                return "Out of Memory";
            
            case DatabaseErrorType.OutOfSync:
                return "Out of Sync";
                
            case DatabaseErrorType.ProtocolError:
                return "Protocol Error";
            
            case DatabaseErrorType.ResultError:
                return "Result Error";
            
            case DatabaseErrorType.ServerError:
                return "Server Error";
            
            case DatabaseErrorType.SocketError:
                return "Socket Error";
                
            default:
                return "Unknown Error";
        }
    }
}


/**
 * Database error types
 */
enum DatabaseErrorType
{
    /**
     * No error occured
     */
    NoError,
    
    /** 
     * Socket error
     */
    SocketError,
    
    /**
     * Connection issues
     */
    ConnectionError,
    
    /**
     * Protocol error
     */
    ProtocolError,
    
    /**
     * Server error
     */
    ServerError,
        
    /**
     * Out of sync
     */
    OutOfSync,
    
    /**
     * Out of memory
     */
    OutOfMemory,
    
    /**
     * Invalid statement error
     * 
     * May include not prepared statement, 
     * parameters not bound, etc.
     */
    InvalidStatement,
    
    /**
     * Invalid query 
     */
    InvalidQuery,
    
    /**
     * Error while fetching result
     */
    ResultError,
    
    /**
     * Feature not implemented
     */
    NotImplemented,
    
    
    /// Unknown error
    UnknownError = 1024
}