module sqld.exception;


/**
 * Inherited by any database releated exception
 */
class DatabaseException : Exception
{
    this(string msg, string file = __FILE__, uint line = __LINE__)
    {
        super(msg, file, line);
    }
}


/**
 * Thrown when connection to server is lost
 */
class ConnectionException : DatabaseException
{
    this(string msg, string file = __FILE__, uint line = __LINE__)
    {
        super(msg, file, line);
    }
}


/**
 * Thrown when required parameter was not specified
 */
class MissingParameterException : DatabaseException
{
    this(string msg, string file = __FILE__, uint line = __LINE__)
    {
        super(msg, file, line);
    }
}


/**
 * Thrown when there was problem with executing query
 */
class QueryException : DatabaseException
{
    this(string msg, string file = __FILE__, uint line = __LINE__)
    {
        super(msg, file, line);
    }
}


/**
 * Thrown when there was problem with fetching query result
 */
class ResultException : DatabaseException
{
    this(string msg, string file = __FILE__, uint line = __LINE__)
    {
        super(msg, file, line);
    }
}

