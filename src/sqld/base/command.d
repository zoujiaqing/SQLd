module sqld.base.command;

import sqld.base.connection,
       sqld.base.result;

/**
 * Represents abstract database command
 */
interface ICommand
{
    // Properties
    /**
     * Gets database connection
     */
	@property IConnection connection();
    
    
    /**
     * Sets database connection
     */
    @property void connection(IConnection);
    
    
    /**
     * Gets query text
     */
    @property string commandText();
    
    
    /**
     * Sets query text
     */
    @property void commandText(string);
    
    
    
    /**
     * Gets first cell as T
     * 
     * This function uses std.conv.to to cast string value into T.
     * If it fails, ConvException is thrown.
     * 
     * Returns:
     *  First cell value 
     */
    T executeScalar(T)(string file = __FILE__, uint line = __LINE__);
    
    
    /**
     * Executes query and returns affected rows
     * 
     * Returns:
     *  Number of rows affected
     */
    ulong execute(string file = __FILE__, uint line = __LINE__);
    
    
    /**
     * Executes query and returns result
     * 
     * If result is empty, or executed query did not produce result,
     * returned value should have .valid property set to false.
     * 
     * Returns:
     *  Query result
     */
    IResult executeQuery(string file = __FILE__, uint line = __LINE__);
    
}

