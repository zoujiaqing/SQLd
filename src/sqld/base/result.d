module sqld.base.result;

import sqld.base.row,
       sqld.base.error;

/**
 * Represents database query result
 */
class Result
{
    ///
    abstract bool isValid() @property;
    ///
    abstract bool next();
    ///
    abstract void reset();
    
    /**
     * Field names
     */
    abstract public string[] fields() @property;
    
    /**
     * Rows count
     */
    abstract public ulong length() @property;
    
    
    /**
     * Fetches row
     *
     * Returns:
     *  Row
     */
    abstract public Row fetch(string file = __FILE__, uint line = __LINE__);
    
    /**
     * Current row number proceeded
     */
    abstract public ulong index() @property;
    
    /**
     * Cleans up result
     */
    abstract public void free();
    
    /**
     * Affected rows
     */
    abstract public ulong affectedRows();
    
    
    public bool empty()
    {
        return !isValid;
    }
    
    public Row front()
    {
        return fetch();
    }
    
    public void popFront()
    {
        next();
    }
    /**
     * First field of first row and casts it to T
     */
    public T first(T = string)() @property
    {
        if(isValid) {
            auto r = fetch();
            return to!T(r[0]);
        } else {
            throw new DatabaseException("Cannot fetch invalid result");
        }
    }
    
    /**
     * Loops through rows
     *
     * Params:
     *  Callback to call on each row occurence
     */
    public void each(bool delegate(Row) dg)
    {
        while(isValid)
        {
            if(!dg(fetch()))
                break;
                
            if(!next())
                break;
        }
    }
}