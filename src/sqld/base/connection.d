module sqld.base.connection;

import sqld.base.command,
       sqld.base.statement;

/**
 * Represents abstract connection to Database
 */
interface IConnection : IStatementProvider
{
    /**
     * Underlying database connection handle
     */
    @property void* handle();
    
    
    /**
     * Checks if connection is alive
     *
     * Returns:
     *  True if connected to database, false otherwise
     */
    @property bool alive();
    
    
    
    /**
     * Opens connection to database
     * 
     * If connection failed, connection `alive` will be set to false.
     * Optionally, exception may be thrown.
     */
    IConnection open();
    
    
    /**
     * Closes connection
     */
    IConnection close();
    
    
    /**
     * Creates new command
     * 
     * Returned command instance can be reused for diffrent queries.
     * 
     * Params:
     *  query = Command Text
     * 
     * Returns:
     *  ICommand instance
     */
    ICommand createCommand(string query = "", string file = __FILE__, uint line = __LINE__);
}