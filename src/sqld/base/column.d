module sqld.base.column;

import std.conv;
import sqld.base.cell;

class Column
{
    protected
    {
        string _name;
        ColumnType _type;
        Cell _default;
    }
    
    public this(string name, ColumnType type, string defaultVal)
    {
        _name = name;
        _type = type;
        _default = new Cell(defaultVal);
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
    public ColumnType type() @property
    {
        return _type;
    }
    
    /**
     * Column default value
     */
    public Cell defaultValue() @property
    {
        return _default;
    }
    
    public override string toString()
    {
        return to!string([_name, to!string(_type), _default.value]);
    }
}

enum ColumnType
{
    Unknown,
    Varchar,
    Date,
	Bool,
	Float,
	Text,
    Integer
}