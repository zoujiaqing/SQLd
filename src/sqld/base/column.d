module sqld.base.column;

import std.conv;

class Column
{
    protected
    {
        string _name;
        string _type;
        string _default;
    }
    
    public this(string name, string type, string defaultVal)
    {
        _name = name;
        _type = type;
        _default = defaultVal;
    }
    
    /**
     * Column name
     */
    public string name() @property
    {
        return _name;
    }
    
    /**
     * Column type
     */
    public string type() @property
    {
        return _type;
    }
    
    /**
     * Column default value
     */
    public string defaultValue() @property
    {
        return _default;
    }
    
    public override string toString()
    {
        return to!string([_name, _type, _default]);
    }
}