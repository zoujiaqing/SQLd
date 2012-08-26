module sqld.db.sqlite.table;

import sqld.all,
       sqld.base.column,
       sqld.base.table;

class SqliteTable : Table 
{
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
            _columns ~= new Column(row["name"], parseType(row["type"]), row["dflt_value"]);
        }
    }
    
    protected ColumnType parseType(string type)
    {
        switch(type)
        {
            case "INTEGER":
                return ColumnType.Integer;
            break;
            
            case "VARCHAR":
                return ColumnType.Varchar;
            break;
            
            case "DATETIME":
                return ColumnType.Date;
            break;
            
            default:
                return ColumnType.Unknown;
        }
    }
}