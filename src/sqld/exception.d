module sqld.exception;

import sqld.base.error;

/**
 * Inherited by any database releated exception
 */
class DatabaseException : Exception
{
    SqlError error;
    
    this(SqlError err, string file = __FILE__, uint line = __LINE__)
    {
        this.error = err;
        super(err.toString(), file, line);
    }
}


/**
 * Thrown when connection to server is lost
 */
class ConnectionException : DatabaseException
{
    this(SqlError err, string file = __FILE__, uint line = __LINE__)
    {
        super(err, file, line);
    }
}


/**
 * Thrown when there was problem with executing query
 */
class QueryException : DatabaseException
{
    this(SqlError err, string file = __FILE__, uint line = __LINE__)
    {
        super(err, file, line);
    }
}


/**
 * Thrown when there was statment releated problem
 */
class StatementException : DatabaseException
{
    this(SqlError err, string file = __FILE__, uint line = __LINE__)
    {
        super(err, file, line);
    }
}


/**
 * Thrown when there was problem with fetching query result
 */
class ResultException : DatabaseException
{
    this(SqlError err, string file = __FILE__, uint line = __LINE__)
    {
        super(err, file, line);
    }
}




/**
 * Thrown when required parameter was not specified
 */
class MissingParameterException : Exception
{
    this(string msg, string file = __FILE__, uint line = __LINE__)
    {
        super(msg, file, line);
    }
}