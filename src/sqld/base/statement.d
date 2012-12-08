module sqld.base.statement;

import sqld.field;



/**
 * Abstract statement provider
 */
interface IStatementProvider
{   
    /**
     * Creates new prepared statement
     */
    IStatement prepare(string query, string file = __FILE__, uint line = __LINE__);
}


/**
 * Represents abstract statement
 */
interface IStatement
{
    /**
     * Returns true if statement returned result
     */
    @property bool valid();
    
    
    /**
     * Returns true if no rows are remaining.
     */
    @property bool empty();
    
    
    /**
     * Result fields info, if any.
     */
    @property Field[] fields();
    
    
    
    /**
     * Prepares statement
     */
    IStatement prepare(string, string file = __FILE__, uint line = __LINE__);
    
    
    /**
     * Binds next statement parameter
     */
	IStatement bindParam(T)(T);
    
    
    /**
     * Binds specific statement parameter
     */
    IStatement bindParam(T)(uint, T);
    
    
    /**
     * Executes statement
     * 
     * To read statement result, use read function.
     */
    IStatement execute(string file = __FILE__, uint line = __LINE__);
    
    
    /**
     * Resets a prepared statement on client and server to state after prepare.
     * 
     * To re-prepare the statement with another query, use `prepare()`.
     */
    IStatement reset();
    
    /**
     * Closes statements and frees up data
     * 
     * Statement is not usable after closing.
     */
    void close();
    
    
    /**
     * Reads row from database
     * 
     * This function should be called if statement returns result set.
     */
    Tuple!(T) read(T...)(string file = __FILE__, uint line = __LINE__);
    
    
    /**
     * Reads next from from result
     */
    bool next(string file = __FILE__, uint line = __LINE__);
}

