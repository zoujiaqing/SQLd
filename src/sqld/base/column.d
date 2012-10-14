module sqld.base.column;

import std.conv;
import sqld.base.cell;

/**
 * Represents column information
 */
class Column
{
    protected
    {
        string _name;
        ColumnType _type;
        Cell _default;
    }
    
    
    /**
     * Creates new Column instance
     * 
     * Params:
     *  name = Column name
     *  type = Column type
     *  defaultVal = Default column value
     *  
     */
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
    
    
    /**
     * Represents column as string
     * 
     * Returns:
     *  String representation as string
     */
    public override string toString()
    {
        return to!string([_name, to!string(_type), _default.value]);
    }
}


/**
 * Represents column type
 */
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