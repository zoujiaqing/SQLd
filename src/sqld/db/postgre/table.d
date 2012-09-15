module sqld.db.postgre.table;

import sqld.all,
       sqld.base.column,
       sqld.base.table;
import std.string;

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
        auto res = _db.prepare("SELECT column_name, data_type, column_default FROM information_schema.columns WHERE table_name = ? ORDER BY ordinal_position ASC;")
            .bindValue(_name)
            .execute();
        
        foreach(row; res)
        {
            _columns ~= new Column(row["column_name"], parseType(row["data_type"]), parseDefault(row["column_default"]));
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
			
			case "boolean":
				return ColumnType.Bool;
			break;
			
			case "real":
				return ColumnType.Float;
			break;
            
			case "text":
				return ColumnType.Text;
			break;
				
            default:
                return ColumnType.Unknown;
        }
    }
	
	protected string parseDefault(string s)
	{
		if(s.length < 1) return s;
		if(s[$-1] == ')') return s;
		
		size_t o = s.lastIndexOf("::");
		
		if(o > 0 && o < s.length) {
			s = s[0..o];
		}
		
		if(s.length > 2)
		{
			if(s[0] == '\'' && s[$-1] == '\'') {
				s = s[1..$-1];
			}
		}
		
		return s;
	}
}