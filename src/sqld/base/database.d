module sqld.base.database;

import sqld.base.error,
       sqld.base.result,
       sqld.base.transaction,
       sqld.uri,
       sqld.statement,
       sqld.db.mysql.database,
       sqld.db.sqlite.database,
       sqld.db.postgre.database;

/**
 * Represents abstract database
 */
abstract class Database
{
    /**
     * Connects to database
     */
    abstract Database open();
    
    /**
     * Disconnects from database
     */
    abstract Database close();
    
    
    /**
     * Last error
     *
     * Returns:
     *  Error - Last error
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
     * Returns:
     *  Result
     */
    abstract Result query(string query, string file = __FILE__, uint line = __LINE__);
    
    /**
     * Begins transaction
     */
    //abstract Transaction beginTransaction(); Work In Progress
    
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
     * Begins transaction
     *
     * Returns:
     *  Transaction
     */
    abstract public Transaction beginTransaction(TransactionIsolation level = TransactionIsolation.ReadCommited);
    
    
    /**
     * Queries database with specified query
     *
     * Params:
     *   query = Query to execute
     *
     * Throws:
     *  DatabaseException
     *
     * Returns:
     *   Affected rows
     */
    abstract public ulong execute(string query, string file = __FILE__, uint line = __LINE__);
    
    /**
     * Returns last inserted row id
     */
    abstract public ulong insertedId() @property; 
    
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
     * Current database instance
     */
    static Database instance = null;
    
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
                Database.instance = new MySQL(uri);
            break;
            
            case "sqlite":
                Database.instance = new SQLite(uri);
            break;
            
            case "postgre":
                Database.instance = new Postgre(uri);
            break;
            
            default:
                assert(0, "Unsupported database type");
        }
        
        return Database.instance;
    }
}