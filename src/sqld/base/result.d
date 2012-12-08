module sqld.base.result;

import sqld.base.range,
       sqld.field;

/**
 * Represents abstract query result
 * 
 * Implements InputRange
 */
interface IResult : IInputRange!(string[])
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
    //@property IDataRow front();
    
    
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

