module sqld.db.postgre.table;

import sqld.all,
       sqld.base.column;

class PostgreTable
{
    protected
    {
        string _name;
        Database _db;
        Column[] _columns;
    }
    
    /**
     * Creates new PostgreTable instance
     */
    public this(Database db, string name)
    {
        _name = name;
        _db = db;
        
        loadInfo();
    }
    
    protected void loadInfo()
    {   
        auto res = _db.prepare("SELECT column_name, data_type, column_default FROM information_schema.columns WHERE table_name = '?' ORDER BY ordinal_position ASC;")
            .bindColumn(_name)
            .execute();
        
        foreach(row; res)
        {
            _columns ~= new Column(row["column_name"], row["data_type"], row["column_default"]);
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