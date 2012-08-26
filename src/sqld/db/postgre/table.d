module sqld.db.postgre.table;

import sqld.all,
       sqld.base.column,
       sqld.base.table;

class PostgreTable : Table
{   
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
            _columns ~= new Column(row["column_name"], parseType(row["data_type"]), row["column_default"]);
        }
    }
    
    protected ColumnType parseType(string type)
    {
        switch(type)
        {
            case "integer":
                return ColumnType.Integer;
            break;
            
            case "character":
                return ColumnType.Varchar;
            break;
            
            case "date":
                return ColumnType.Date;
            break;
            
            default:
                return ColumnType.Unknown;
        }
    }
}