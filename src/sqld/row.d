module sqld.row;

import std.conv;

/**
 * Represents result row
 */
class DataRow
{
    protected string[] _columns;
    protected string[] _data;
    
    
    /**
     * Creates new row instance
     *
     * Params:
     *  data = Row data
     *  columns = Column names
     */
    this(string[] data, string[] columns)
    {
        _columns = columns;
        _data = data;
    }
    
    /**
     * Returns row value
     *
     * Params:
     *  Field name
     * 
     * Returns:
     *  Cell value
     */
    public string opIndex(string name)
    {
        for(int i; i < _columns.length; i++)
        {
            if(_columns[i] == name)
                return _data[i];
        }
        throw new Exception("Index does not exists");
    }
    
    /**
     * Returns row value
     *
     * Params:
     *  Field id
     * 
     * Returns:
     *  Cell value
     */
    public string opIndex(uint i)
    {
        return _data[i];
    }
    
    /**
     * Gets rows value as specified type
     *
     * If value cannot be casted to T, exception is thrown
     *
     * Params:
     *  name = Field name
     *
     * Throws:
     *  ConvException
     *
     * Returns:
     *  Row value
     */
    public T get(T)(string name)
    {
        auto val = this[name];
        return to!T(val);
    }
    
    /**
     * Fields array
     *
     * Returns:
     *  Array of field names
     */
    public string[] columns() @property
    {
        return _columns;
    }
    
    /// ditto
    alias columns fields;
    
    public int opApply( int delegate(string name, string value) dg )
    {
        int result;
        
        for(int i; i < _columns.length; i++)
        {
            result = dg(_columns[i], _data[i]);
            
            if(result) break;
        }
        
        return result;
    }
    
    /**
     * Returns: Associative array that represents row
     */
    public string[string] toAssocArray()
    {
        string[string] aa;
        
        for(int i; i < _columns.length; i++)
            aa[_columns[i]] = _data[i];
            
        return aa;
    }
    
    /**
     * Returns: Array that represents row
     */
    public string[] toArray()
    {
        return _data;
    }
    
    /**
     * Returns row, as single string
     *
     * Returns:
     *  Row representation, as string
     */
    public override string toString()
    {
        return to!string(toAssocArray());
    }
    
    /**
     * Returns row as specified struct
     *
     * If one of the fields cannot be casted to member type exception is thrown.
     *
     * Authors:
     *  dav1d
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