module sqld.base.row;

import std.conv      : to, ConvException;

/**
 * Represents table row
 */
class Row
{
    /**
     * Row data
     */
    protected string[string] _data;
    
    
    /**
     * Creates new row instance
     *
     * Params:
     *  data = Row data
     */
    this(string[] data, string[] fields)
    {
        for(int i; i < fields.length; i++)
        {
            _data[fields[i]] = data[i];
        }
    }
    
    /**
     * Returns row value
     *
     * Params:
     *  Field name
     * 
     * Returns:
     *  Row value
     */
    public string opIndex(string name)
    {
        if(name !in _data)
        {
            throw new Exception("Index does not exists");
        }
        
        return _data[name];
    }
    
    /**
     * Returns row value
     *
     * Params:
     *  Field id
     * 
     * Returns:
     *  Row value
     */
    public string opIndex(uint i)
    {
        return _data.values[i];
    }
    
    /**
     * Fields array
     *
     * Returns:
     *  Array of field names
     */
    public string[] fields() @property
    {
        return _data.keys;
    }
    
    public int opApply( int delegate(string name, string value) dg )
    {
        int result;
        
        foreach(field, value; _data)
        {
            result = dg(field, value);
            
            if(result) break;
        }
        
        return result;
    }
    
    /**
     * Returns: associative array that represents row
     */
    public string[string] toAssocArray()
    {
        return _data;
    }
    
    /**
     * Returns: associative array that represents row
     */
    public string[] toArray()
    {
        return _data.values;
    }
    
    /**
     * Returns row, as single string
     *
     * Returns:
     *  Row representation, as string
     */
    public override string toString()
    {
        return to!string(_data);
    }
    
    /**
     * Returns row as specified struct
     *
     * If one of the fields cannot be casted to member type exception is thrown.
     *
     * Authors:
     *  dav1d, Robik
     *
     * Throws:
     *  Exception
     */
    T as(T)()
    {
        T result;   
        
        foreach(name; __traits(allMembers, T)) {
            try {
                mixin(`result.` ~ name ~` = to!(typeof(result.`~name~`))(_data["` ~ name ~ `"]);`);
            } catch(ConvException e) {
                throw new Exception("Cannot cast field '"~name~"' to " ~ mixin("typeof(result."~name~").stringof"));
            }
        }
        
        return result;
    }
}
