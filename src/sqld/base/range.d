module sqld.base.range;

/**
 * Class that is basic input range
 */
interface IInputRange(T)
{
    /**
     * Front element of range
     */
    @property T front();
    
    /**
     * Check if range is empty
     */
    @property bool empty();
    
    /**
     * Reads next element from range
     */
    void popFront();
}

