module sqld.base.result;

import sqld.base.row;

/**
 * Represents database query result
 */
interface Result
{
    bool isValid() @property;
    bool next();
    void reset();
    
    public string[] fields() @property;
    public ulong length() @property;
    
    public Row fetch(string file = __FILE__, uint line = __LINE__);
    
    public ulong index() @property;
    public void free();
    
    bool empty();
    Row front();
    void popFront();
}