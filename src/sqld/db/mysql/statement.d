module sqld.db.mysql.statement;

import sqld.base.statement;
import sqld.base.database;
import std.conv;

/**
 * Represents MySQL statement
 */
class MySQLStatement : Statement
{	
	/**
	 * Creates new MySQL statement
	 * 
	 * Params:
	 *  db = Database connection
     *  query = Query to execute
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
	public override string wrapColumn(string s)
	{
		return "`" ~ s ~ "`";
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
	public override string wrapValue(string s)
	{
		return "'" ~ s ~ "'";
	}
}

