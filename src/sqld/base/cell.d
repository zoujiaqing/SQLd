module sqld.base.cell;

import std.datetime;
import std.conv;
import std.string;

/**
 * Represents database cell
 */
class Cell
{
	/// Cell value
	public string value;
	alias value this;
	
	
	/**
	 * Creates new cell
	 * 
	 * Params:
	 *  v = Cell value
	 */
	public this(string v)
	{
		value = v;
	}
	
	
	/**
	 * Boolean value of cell
	 * 
	 * This function returns true if cell value is '1' or 't'
	 * 
	 * Returns:
	 * 	Bool value
	 */
	public bool getBool()
	{
		return (value == "1" || value == "t" || value == "y" || value == "true" || value == "yes");
	}
	
	/**
	 * Date value of cell
	 * 
	 * Throws:
	 *  DateTimeException if format is not correct
	 * 
	 * Returns:
	 *  Date object
	 */
	public Date getDate()
	{
		return Date.fromISOExtString(value);
	}
	
	/**
	 * Number value of cell
	 * 
	 * Throws:
	 *  ConvException if format is not correct
	 * 
	 * Returns:
	 *  Integer
	 */
	public int getInt()
	{
		return to!int(value);
	}
		
	/**
	 * Float value of cell
	 * 
	 * Throws:
	 *  ConvException if format is not correct
	 * 
	 * Bugs:
	 *  Does not work
	 * 
	 * Returns:
	 *  Float value
	 */
	public float getFloat()
	{
		return to!float(value);
	}
	
	/**
	 * String value of cell
	 * 
	 * Returns:
	 *  String
	 */
	public string getString()
	{
		return value;
	}
	/// ditto
	alias getString toString;
	
	mixin(CellGen!float("Float"));
	mixin(CellGen!bool("Bool"));
	mixin(CellGen!int("Int"));
	mixin(CellGen!string("String"));	
	mixin(CellGen!Date("Date"));
}

package string CellGen(T)(string name)
{
	return `
		bool opEquals(`~T.stringof~` v)
		{
			mixin("return get`~name~`() == v;");
		}

		`~T.stringof~` opCast(U)() if(is(U == `~T.stringof~`))
		{
			mixin("return get`~name~`();");
		}
	`;
}