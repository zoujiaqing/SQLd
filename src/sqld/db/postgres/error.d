module sqld.db.postgres.error;

public import sqld.base.error;


/**
 * Represents Postgres database error
 */
final class PostgresDatabaseError : DatabaseError
{
    /**
     * Creates new DatabaseError instance
     *
     * Params:
     *  number  = Error code
     */
    public this(string msg)
    {
        super(0);
        update(msg);
    }
    
    /**
     * Updates error
     * 
     * Params:
     *  msg = New message
     */
    public void update(string msg)
    {
        this.code = strToCode(msg);
        this.message = codeToString(this.code);
    }
    
    /**
     * Converts error message to DatabaseErrorCode
     * 
     * Params:
     *  code = Internal error message
     * 
     * Returns:
     *  Converted code
     */
    protected DatabaseErrorCode strToCode(string msg)
    {
        if(msg == "") return DatabaseErrorCode.NoError;
        if(msg.length < 2) return DatabaseErrorCode.Unknown;
        
        // custom err msg
        if(msg == "_CONN") return DatabaseErrorCode.ConnectionError;
        
        switch(msg[0..2])
        {
            case "22":
                return DatabaseErrorCode.InvalidData;
            break;
        
            case "23":
                return DatabaseErrorCode.InvalidQuery;
            break;
        
            case "25":
            case "54":
            case "55":
                return DatabaseErrorCode.ServerError;
            break;
        
            case "42":
                return DatabaseErrorCode.InvalidQuery;
            break;
                
            case "53":
                return DatabaseErrorCode.Unknown;
            break;
            
            default:
                return DatabaseErrorCode.Unknown;                    
        }
    }
}