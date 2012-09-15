module sqld.base.row;

import sqld.base.cell;
import std.conv      : to, parse, ConvException;

/**
 * Represents table row
 */
class Row
{
    /**
     * Row columns
     */
    protected string[] _columns;
    
    /**
     * Row data
     */
    protected Cell[] _data;
    
    
    /**
     * Creates new row instance
     *
     * Params:
     *  data = Row data
     */
    this(string[] data, string[] columns)
    {
        foreach(d; data) {
			_data ~= new Cell(d);
		}
        _columns = columns;
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
    public Cell opIndex(string name)
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
    public Cell opIndex(uint i)
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
    
    /*public int opApply( int delegate(string name, string value) dg )
    {
        int result;
        
        for(int i; i < _columns.length; i++)
        {
            result = dg(_columns[i], _data[i]);
            
            if(result) break;
        }
        
        return result;
    }*/
    
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
    public Cell[] toArray()
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