module sqld.base.transaction;

import sqld.base.database,
       sqld.base.result;

import std.algorithm;

/**
 * Represents transaction
 */
class Transaction
{
    protected Database _db;
    protected string[] _saves;
    
    
    /**
     * Creates new transaction instance
     *
     * Params:
     *  db = Database
     */
    this(Database db)
    {
        _db = db;
    }
    
    ~this()
    {
        releaseAll();
    }
    
    /**
     * Creates savepoint with specified name
     *
     * Params:
     *  name = Savepoint name
     *
     * Returns:
     *  Transaction
     */
    public Transaction save(string name)
    {
        _saves ~= name;
        execute("SAVEPOINT "~name~";");
        return this;
    }
    
    /**
     * Commits transaction changes
     *
     * Returns:
     *  Transaction
     */
    public Transaction commit()
    {
        execute("COMMIT;");
        return this;
    }
    
    /**
     * Rollbacks transaction changes
     *
     * Returns:
     *  Transaction
     */
    public Transaction rollback()
    {
        execute("ROLLBACK;");
        return this;
    }
    
    /**
     * Rollbacks transaction to savepoint
     *
     * Params:
     *  name = Savepoint name
     *
     * Returns:
     *  Transaction
     */
    public Transaction rollbackTo(string name)
    {
        execute("ROLLBACK TO "~name~";");
        return this;
    }
    
    /**
     * Releases savepoint
     *
     * Params:
     *  name = Savepoint name
     *
     * Returns:
     *  Transaction
     */
    public Transaction release(string name)
    {
        remove(_saves, name);
        execute("RELEASE SAVEPOINT "~name~";");
        return this;
    }
    
    /**
     * Releases all savepoints created
     *
     * Returns:
     *  Transaction
     */
    public Transaction releaseAll()
    {
        foreach(save; _saves)
        {
            release(save);
        }
        return this;
    }
    
    /**
     * Returns: Array of all savepoints created
     */
    public string[] getSavepoints()
    {
        return _saves;
    }
    
    
    /**
     * Executes query and returns result
     *
     * Examples:
     * ---
     * auto trans = db.beginTransaction(); 
     * auto res = trans.execute("SELECT ...");
     * while(res.isValid)
     * {
     *     writeln(res.fetchAssoc());
     *     res.next();
     * }
     * ---
     *
     * Params:
     *  query = Query to execute
     *
     * Throws:
     *  DatabaseException
     *
     * Returns:
     *  Result
     */
    public Result execute(string query, string file = __FILE__, uint line = __LINE__)
    { 
        return _db.execute(query, file, line);
    }
     
}


/**
 * Transaction isolation
 */
enum TransactionIsolation : string
{
    ///
    Serializable    = "SERIALIZABLE",
    ///
    RepeatableRead  = "REPEATABLE READ",
    ///
    ReadCommited    = "READ COMMITTED",
    ///
    ReadUncommited  = "READ UNCOMMITTED"
}