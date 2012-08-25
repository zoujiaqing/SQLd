module sqld.db.mysql.table;

import sqld.all,
       sqld.base.column;

class MySqlTable
{
    protected
    {
        string _name;
        Database _db;
        Column[] _columns;
    }
    
    /**
     * Creates new MySqlTable instance
     */
    public this(Database db, string name)
    {
        _name = name;
        _db = db;
        
        loadInfo();
    }
    
    protected void loadInfo()
    {   
        auto res = _db.prepare("DESCRIBE ?;")
            .bindColumn(_name)
            .execute();
        
        foreach(row; res)
        {
            _columns ~= new Column(row["Field"], row["Type"], row["Default"]);
        }
    }
    
    
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
}