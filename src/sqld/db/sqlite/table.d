module sqld.db.sqlite.table;

import sqld.all,
       sqld.base.column,
       sqld.base.table;


/**
 * Represents SQLite table info
 */
class SQLiteTable : Table 
{
    /**
     * Creates new SqliteTable instance
     * 
     * Params:
     *  db = Database instance
     *  name = Table name
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
            _columns ~= new Column(row["name"], parseType(row["type"]), parseDefault(row["dflt_value"]));
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
				
			case "BOOL":
				return ColumnType.Bool;
			break;
			
			case "FLOAT":
				return ColumnType.Float;
			break;
			
			case "TEXT":
				return ColumnType.Text;
			break;
				
            default:
                return ColumnType.Unknown;
        }
    }
	
	protected string parseDefault(string s)
	{
		if(s.length > 2 && s[0] == '\'' && s[$-1] == '\'') {
			return s[1..$-1];
		} else {
			return s;
		}
	}
}