module sqld.db.postgre.statement;

import sqld.base.statement;
import sqld.base.database;
import std.conv;

/**
 * Represents Postgre statement
 */
class PostgreStatement : Statement
{	
	/**
	 * Creates new Postgre statement
	 * 
	 * Params:
	 *  db = Database connection
	 */
	public this(Database db, string query)
	{
		super(db, query);
	}
	
	/**
	 * Wraps column with database specific quote
	 * 
	 * Params:
	 *  s = Column name
	 * 
	 * Returns:
	 *  Wrapped column name
	 */
	public string wrapColumn(string s)
	{
		return `"` ~ s ~ `"`;
	}
	
	/**
	 * Wraps value with database specific quote
	 * 
	 * Params:
	 *  s = Value
	 * 
	 * Returns:
	 *  Wrapped value
	 */
	public string wrapValue(string s)
	{
		return "'" ~ s ~ "'";
	}
}

