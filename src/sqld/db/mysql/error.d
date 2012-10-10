module sqld.db.mysql.error;

public import sqld.base.error;

/**
 * Represents MySQL database error
 */
final class MySQLDatabaseError : DatabaseError
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
        if(code >= 1000 && code < 2000) {
            if(code == 1149 || code == 1064 ) {
                return DatabaseErrorCode.InvalidQuery;
            } else {
                return DatabaseErrorCode.ServerError;
            }
        }
        switch(code)        
        {
            case 0:
                return DatabaseErrorCode.NoError;
            break;
            
            case 2001:
            case 2004:
            case 2010:
            case 2011:
            case 2015:
            case 2016:
            case 2017:
            case 2018:
            case 2022:
            case 2023:
            case 2024:
            case 2025:
            case 2026:
            case 2027:
                return DatabaseErrorCode.SocketError;
            break;
                
            case 2002:
            case 2003:
            case 2005:
            case 2006:
            case 2007:
            case 2009:
            case 2012:
            case 2013:
            case 2020:
            case 2021:
            case 2037:
            case 2038:
            case 2039:
            case 2040:
            case 2041:
            case 2042:
            case 2043:
            case 2044:
            case 2045:
            case 2046:
            case 2047:
            case 2048:
                return DatabaseErrorCode.ConnectionError;
            break;
                
            case 2014:
                return DatabaseErrorCode.OutOfSync;
            break;
                
            case 1064:
            case 2050:
                return DatabaseErrorCode.InvalidQuery;
            break;
                
            case 2029:
            case 2032:
            case 2035:
            case 2051:
            case 2052:
            case 2053:
                return DatabaseErrorCode.InvalidData;
            break;
            
            case 2000:
            default:
                return DatabaseErrorCode.Unknown;
        }
    }    
}

