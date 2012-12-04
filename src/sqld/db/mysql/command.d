module sqld.db.mysql.command;

import std.string,
       std.conv;

import sqld.exception,
       sqld.base.command,
       sqld.base.connection,
       sqld.db.mysql.connection,
       sqld.db.mysql.result,
       sqld.db.mysql.c.mysql;


/**
 * Represents MySql command
 */
class MySqlCommand : ICommand
{
    protected string _commandText;
    protected MySqlConnection _conn;
    
    
    /**
     * Creates new MySqlCommand instance
     * 
     * Params:
     *  conn = Database connection
     *  query = Command text
     */    
    this(MySqlConnection conn, string query = "")
    {
        _conn = conn;
        _commandText = query;
    }
    
    
    /**
     * Executes query and returns result
     * 
     * If result is empty, or executed query did not produce result,
     * returned value should have .valid property set to false.
     * 
     * If executing query fails, `QueryException is thrown`.
     * 
     * Returns:
     *  Query result
     */
    MySqlResult executeQuery(string file = __FILE__, uint line = __LINE__)
    {
        MYSQL* handle;
        MYSQL_RES* result;
        
        handle = cast(MYSQL*)_conn.handle;
        query(file, line);
        
        result = mysql_store_result(handle);
        if(result is null && mysql_field_count(handle) != 0 )
        {                
             throw new QueryException(
                "Could not store result: "~_commandText,
                file, line
             );
        }
        
        return new MySqlResult(handle, result);
    }
    
    /**
     * Executes query and returns affected rows
     * 
     * If query fails, QueryException is thrown.
     * 
     * Returns:
     *  Number of rows affected
     */
    ulong execute(string file = __FILE__, uint line = __LINE__)
    {
        query(file, line);
        
        return mysql_affected_rows(cast(MYSQL*)_conn.handle);
    }
    
    /**
     * Gets first cell as T
     * 
     * This function uses std.conv.to to cast string value into T.
     * If it fails, ConvException is thrown.
     * 
     * Returns:
     *  First cell value 
     */
    T executeScalar(T)(string file = __FILE__, uint line = __LINE__)
    {
        auto res = executeResult();
        
        return to!T(res.front[0]);
    }
    
    /**
     * Gets database connection
     */
    @property IConnection connection()
    {
        return _conn;
    }
    
    
    /**
     * Sets database connection
     */
    @property void connection(IConnection conn)
    {
        _conn = cast(MySqlConnection)conn;
    }
    
    
    /**
     * Gets command text
     */
    @property string commandText()
    {
        return _commandText;
    }
    
    
    /**
     * Sets command text
     */
    @property void commandText(string str)
    {
        _commandText = str;
    }
    
    
    protected void query(string file = __FILE__, uint line = __LINE__)
    {
        int res;
        
        res = mysql_query(cast(MYSQL*)_conn.handle, _commandText.toStringz());
        
        if(res)
        {
            throw new QueryException( 
                format("Could not execute query '%s'", _commandText),
                file, line
            );
        }
    }
}