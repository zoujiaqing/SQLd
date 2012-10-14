module sqld.base.database;

import sqld.base.error,
       sqld.base.result,
       sqld.base.transaction,
       sqld.base.table,
       sqld.uri,
       sqld.base.statement,
       sqld.db.mysql.database,
       sqld.db.sqlite.database,
       sqld.db.postgres.database;

/**
 * Represents abstract database
 */
abstract class Database
{
    /**
     * Connects to database
     * 
     * Throws:
     *  ConnectionException if connection could not be estabilished
     */
    abstract Database open();
    
    /**
     * Disconnects from database
     */
    abstract Database close();
    
    
    /**
     * Last error
     * 
     * If no error occured, returned Error instance has code property 
     * set to DatabaseErrorCode.NoError.
     *
     * Returns:
     *  Error - last error occured
     */
    abstract DatabaseError error() @property;
    
    /**
     * Checks if any error occured
     *
     * Returns:
     *  True if any error occured, false otherwise
     */
    abstract bool isError() @property;
    
    /**
     * Executes query and returns result
     *
     * Params:
     *  query = Query to execute
     * 
     * Throws:
     *  QueryException when executing query failed
     *
     * Returns:
     *  Result
     */
    abstract Result execute(string query, string file = __FILE__, uint line = __LINE__);
    
    /// ditto
    alias execute query;
    
    /**
     * Prepares new statement with speicified query
     *
     * Params:
     *  query = Statement query
     *
     * Returns:
     *  New statement
     */
    abstract Statement prepare(string query);
    
    /**
     * Checks if Database connection is alive
     */
    abstract bool connected() @property;
    
    /**
     * Begins transaction
     * 
     * Params:
     *  level = Transaction isolation level
     *
     * Returns:
     *  Transaction
     */
    abstract public Transaction beginTransaction(TransactionIsolation level = TransactionIsolation.ReadCommited);
    
    /**
     * Escapes string
     *
     * Params:
     *  str = String to escape
     *
     * Returns:
     *  Escaped string
     */
    abstract public string escape(string str);
    
    /**
     * Returns table info
     *
     * Params:
     *  table = Table name
     * 
     * Returns:
     *  Table information
     */
    abstract public Table tableInfo(string table);

    /**
     * Current database instance
     */
    public static Database instance = null;
    
    /**
     * Drivers bindings
     */
    public static Database[string] drivers;
    
    /**
     * Creates new database instance
     * 
     * Params:
     *  _uri = URI
     *
     * Returns:
     *  Database instance
     */
    static Database factory(string _uri)
    {
        Uri uri = new Uri(_uri);
        
        switch(uri.rawscheme)
        {
            case "mysql":
                Database.instance = new MySQLDatabase(uri);
            break;
            
            case "sqlite":
                Database.instance = new SQLiteDatabase(uri);
            break;
            
            case "postgre":
                Database.instance = new PostgresDatabase(uri);
            break;
            
            default:
                if(uri.rawscheme !in drivers) {
                    assert(0, "Unsupported database type");
                } else {
                    return drivers[uri.rawscheme];
                }
        }
        
        return Database.instance;
    }
}
