module sqld.db.mysql.table;

import sqld.all,
       sqld.base.column,
       sqld.base.table;

import std.algorithm;

class MySqlTable : Table
{
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
            _columns ~= new Column(row["Field"], parseType(row["Type"]), row["Default"]);
        }
    }
    
    protected ColumnType parseType(string type)
    {
        if(type.startsWith("int"))
            return ColumnType.Integer;
        else if(type.startsWith("varchar"))
            return ColumnType.Varchar;
        else if(type.startsWith("date"))
            return ColumnType.Date;
		else if(type == "tinyint(1)")
			return ColumnType.Bool;
		else if(type == "float")
			return ColumnType.Float;
		else if(type == "text")
			return ColumnType.Text;
        else
            return ColumnType.Unknown;
    }
}