module sqld.base.result;

import sqld.base.range;

/**
 * Represents abstract query result
 * 
 * Implements InputRange
 */
interface IResult : IInputRange!(string[])
{
    /**
     * Gets number of columns
     */
	@property int columnCount();
    
    
    /**
     * Gets column names
     */
    @property string[] columns();
    
    
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

