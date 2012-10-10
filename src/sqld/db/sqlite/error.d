module sqld.db.sqlite.error;

public import sqld.base.error;


/**
 * Represents SQLite database error
 */
final class SQLiteDatabaseError : DatabaseError
{
	/**
     * Creates new DatabaseError instance
     *
     * Params:
     *  number  = Error code
     */
    public this(int code)
    {
        super(code);
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
        switch(code)        
        {
            case 0:
            case 100:
            case 101:
                return DatabaseErrorCode.NoError;
            break;
                
            case 3:
            case 15:
            case 26:
                return DatabaseErrorCode.ConnectionError;
            break;
                
            case 1:
            case 8:
            case 12:
            case 19:
            case 21:
                return DatabaseErrorCode.InvalidQuery;
            break;
                
            case 2:
            case 5:
            case 6:
            case 7:
            case 13:
            case 14:
            case 22:
            case 24:
                return DatabaseErrorCode.ServerError;
            break;
                
            case 10:
            case 11:
            case 16:
            case 17:
            case 18:
            case 20:
                return DatabaseErrorCode.InvalidData;
            break;
            
            default:
                return DatabaseErrorCode.Unknown;
        }
    }
}