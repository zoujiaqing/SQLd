module sqld.db.mysql.error;

import sqld.base.error;


/**
 * Translates MySQL error code into generic error reason
 * 
 * Params:
 *  errorCode = MySQL error code
 * 
 * Returns:
 *  Generic database error reason
 */
DatabaseErrorType translateError(int errorCode)
{
    switch(errorCode)
    {
        case 0:
            return DatabaseErrorType.NoError;
         
        case 1063:
            return DatabaseErrorType.InvalidQuery;
            
        case 1064:
            return DatabaseErrorType.InvalidQuery;
        
        case 1065:
            return DatabaseErrorType.InvalidQuery;
        
            
        case 2000:
            return DatabaseErrorType.UnknownError;
            
        case 2001:
            return DatabaseErrorType.SocketError;
            
        case 2002:
            return DatabaseErrorType.ConnectionError;
            
        case 2003:
            return DatabaseErrorType.ConnectionError;
            
        case 2004:
            return DatabaseErrorType.SocketError;
            
        case 2005:
            return DatabaseErrorType.ConnectionError;
        
        case 2006:
            return DatabaseErrorType.ConnectionError;
        
        case 2007:
            return DatabaseErrorType.ProtocolError;
        
        case 2008:
            return DatabaseErrorType.OutOfMemory;
        
        case 2009:
            return DatabaseErrorType.ConnectionError;
        
        case 2010:
            return DatabaseErrorType.SocketError;
        
        case 2011:
            return DatabaseErrorType.SocketError;
        
        case 2012:
            return DatabaseErrorType.ServerError;
        
        case 2013:
            return DatabaseErrorType.ConnectionError;
        
        case 2014:
            return DatabaseErrorType.OutOfSync;
        
        case 2015:
            return DatabaseErrorType.SocketError;
            
        case 2016:
            return DatabaseErrorType.SocketError;
        
        case 2017:
            return DatabaseErrorType.SocketError;
        
        case 2018:
            return DatabaseErrorType.SocketError;
        
        case 2019:
            return DatabaseErrorType.UnknownError;
        
        case 2020:
            return DatabaseErrorType.ServerError;
        
        case 2021:
            return DatabaseErrorType.ConnectionError;
        
        case 2022:
            return DatabaseErrorType.ServerError;
        
        case 2023:
            return DatabaseErrorType.ServerError;
        
        case 2024:
            return DatabaseErrorType.ConnectionError;
        
        case 2025:
            return DatabaseErrorType.ConnectionError;
        
        case 2026:
            return DatabaseErrorType.ConnectionError;
        
        case 2027:
            return DatabaseErrorType.SocketError;
        
        case 2028:
            return DatabaseErrorType.UnknownError;
        
        case 2029:
            return DatabaseErrorType.UnknownError;
        
        case 2030:
            return DatabaseErrorType.InvalidStatement;
        
        case 2031:
            return DatabaseErrorType.InvalidStatement;
        
        case 2032:
            return DatabaseErrorType.UnknownError;
        
        case 2033:
            return DatabaseErrorType.InvalidStatement;
        
        case 2034:
            return DatabaseErrorType.InvalidStatement;
        
        case 2035:
            return DatabaseErrorType.UnknownError;
        
        case 2036:
            return DatabaseErrorType.UnknownError;
        
        case 2037:
            return DatabaseErrorType.ConnectionError;
        
        case 2038:
            return DatabaseErrorType.ConnectionError;
        
        case 2039:
            return DatabaseErrorType.ConnectionError;
       
        case 2040:
            return DatabaseErrorType.ServerError;
        
        case 2041:
            return DatabaseErrorType.ServerError;
        
        case 2042:
            return DatabaseErrorType.UnknownError;
        
        case 2043:
            return DatabaseErrorType.UnknownError;
        
        case 2044:
            return DatabaseErrorType.UnknownError;
        
        case 2045:
            return DatabaseErrorType.ConnectionError;
        
        case 2046:
            return DatabaseErrorType.ConnectionError;
        
        case 2047:
            return DatabaseErrorType.ProtocolError;
        
        case 2048:
            return DatabaseErrorType.ConnectionError;
        
        case 2049:
            return DatabaseErrorType.ProtocolError;
        
        case 2050:
            return DatabaseErrorType.ResultError;
        
        case 2051:
            return DatabaseErrorType.ResultError;
        
        case 2052:
            return DatabaseErrorType.ResultError;
        
        case 2053:
            return DatabaseErrorType.ResultError;
        
        case 2054:
            return DatabaseErrorType.NotImplemented;
        
        case 2055:
            return DatabaseErrorType.ConnectionError;
        
        case 2056:
            return DatabaseErrorType.InvalidStatement;
        
        case 2057:
            return DatabaseErrorType.InvalidStatement;
        
        case 2058:
            return DatabaseErrorType.ConnectionError;
        
        case 2059:
            return DatabaseErrorType.UnknownError;
        
        case 2060:
            return DatabaseErrorType.ConnectionError;
                
        default:
            return DatabaseErrorType.UnknownError;
    }
}

