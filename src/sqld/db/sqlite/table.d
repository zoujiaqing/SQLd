module sqld.db.sqlite.table;

import sqld.all,
       sqld.base.column;

class SqliteTable
{
    protected
    {
        string _name;
        Database _db;
        Column[] _columns;
    }
    
    /**
     * Creates new SqliteTable instance
     */
    public this(Database db, string name)
    {
        _name = name;
        _db = db;
        
        loadInfo();
    }
    
    protected void loadInfo()
    {   
        auto res = _db.prepare("PRAGMA table_info(?);")
            .bindColumn(_name)
            .execute();
        
        foreach(row; res)
        {
            _columns ~= new Column(row["name"], row["type"], row["dflt_value"]);
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