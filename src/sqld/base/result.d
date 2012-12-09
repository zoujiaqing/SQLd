module sqld.base.result;

import sqld.row,
       sqld.base.range,
       sqld.field;

/**
 * Represents abstract query result
 * 
 * Implements InputRange
 */
interface IResult : IInputRange!(DataRow)
{
    /**
     * Gets number of fields
     */
	@property int fieldCount();
    
    
    /**
     * Gets fields info
     */
    @property Field[] fields();
    
    
    /**
     * Gets current row index
     */
    @property ulong index();
    
    
    /**
     * Gets current row data
     */
    @property DataRow front();
    
    
    /**
     * Gets first cell of result as T type.
     */
    @property T first(T)();
    
    
    /**
     * Is result valid?
     */
    @property bool valid();
    
    
    
    /**
     * Deletes result and frees up resources
     */
    void free();
}

