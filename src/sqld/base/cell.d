module sqld.base.cell;

import std.datetime;
import std.conv;
import std.string;
import std.math;

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
	 * This function returns true value is one of following:
     *  "1", "t", "y", "true", "yes"
	 * 
	 * Returns:
	 * 	Bool value
	 */
	public bool getBool()
	{
		return sqld.util.strToBool(value);
	}
	
	/**
	 * Date value of cell
     * 
     * Uses Date.fromISOExtString to parse string into DateTime instance.
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
	 * Time value of cell
	 * 
	 * Throws:
	 *  DateTimeException if format is not correct
	 * 
	 * Returns:
	 *  Time value
	 */
	public TimeOfDay getTime()
	{
		return parseTime(value);
	}
	
	/**
	 * Date and time value of cell
	 * 
	 * Throws:
	 *  DateTimeException if format is not correct
	 * 
	 * Returns:
	 *  DateTime value
	 */
	public DateTime getDateTime()
	{
		string[] parts = value.split(" ");
		TimeOfDay time;
		Date date;
		
		if(parts.length >= 2)
		{
			date = Date.fromISOExtString(parts[0]);
			time = parseTime(parts[1]);
		}
		else
		{
			parts = value.split("-");
            if(parts.length >= 3) {
				date = Date.fromISOExtString(parts[0..3].join("-"));
			}			
		}
		
		return DateTime(date, time);
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
	
	//mixin(CellGen!float("Float"));
	mixin(CellGen!bool("Bool"));
	mixin(CellGen!int("Int"));
	mixin(CellGen!string("String"));	
	mixin(CellGen!Date("Date"));
	mixin(CellGen!TimeOfDay("Time"));
	mixin(CellGen!DateTime("DateTime"));
	
	bool opEquals(float v)
	{
		return fabs(getFloat() - v) < 0.0000001f;
	}

	float opCast(U)() if(is(U == float))
	{
		return getFloat();
	}
	
	protected TimeOfDay parseTime(string v)
	{
		string[] parts = v.split(":");
		if(parts.length <= 2)
			v ~= ":00";
		
		return TimeOfDay.fromISOExtString(v);
	}
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