module sqld.base.table;

import sqld.all,
       sqld.base.column;

abstract class Table
{
    protected
    {
        string _name;
        Database _db;
        Column[] _columns;
    }
    
    this(){}
    
    /**
     * Table columns
     */
    public Column[] columns() @property
    {
        return _columns;
    }
    
    /**
     * Returns: Column with specified index
     */
    public Column opIndex(int i)
    {
        if(i >= _columns.length) {
            throw new Exception("No column at offset "~to!string(i));
        }
        return _columns[i];
    }
    
    /**
     * Returns: Column with specified index
     */
    public Column opIndex(string n)
    {
        foreach(c; _columns)
        {
            if(c.name == n) {
                return c;
            } 
        }
        throw new Exception("No column with name '"~n~"'");
    }
    
    /**
     * Returns table name
     */
    public string name() @property
    {
        return _name;
    }
    
    /**
     * Table as string
     */
    public override string toString()
    {
        return to!string(_columns);
    }
}