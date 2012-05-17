module sqld.model;

import sqld.base;
import std.stdio;
import std.array : split, join;
import std.conv : to;

/**
 * Represents database row
 */
abstract class Model(T)
{
    /**
     * Row data, as AA
     */
    protected string[string] data;
    
    /**
     * User defined fields
     */
    protected string[] fields;
    
    /**
     * Database connection
     */
    protected Database db;
    
    
    
    /**
     * Creates new Model from data
     */
    this(string[string] d)
    {
        data = d;
        db = Database.instance;
    }
     
    public string opDispatch(string n)()
    {
        return data[n]; 
    } 
    
    public void opDispatch(string n, T)(T val)
    {
        data[n] = to!string(val);
    }
    
    /**
     * Saves changes done to model
     */
    void save()
    {
        string[] sets;
        
        foreach(field; fields)
        {
            sets ~= "`"~field~"`='"~data[field]~"'";
        }
        
        string query = db.format("UPDATE `{0}` SET {1} WHERE `id`={2}", 
            T.stringof,
            sets.join(", "),
            data["id"]);
        
        db.execute(query);
    }
    
    //-------------- STATIC
    /**
     * Finds row with specified ID
     *
     * Params:
     *  i = Row ID
     * 
     * Returns:
     *  Model with row data
     */
    public static T findId(int i)
    {
        string table = T.stringof;
        
        auto db = Database.instance;
        auto res = db.query("SELECT * FROM `{0}` WHERE `id`='{1}'", table, to!string(i));
        string[string] row;
        
        if(res.length > 0) {
           row = res.fetchAssoc();
        } else {
            throw new Exception("No row with id "~ to!string(i));
        }
        res.free();
        
        return new T(row);
    }
    
    /**
     * Finds row swith specified row equal to value
     *
     * Params:
     *  field = Field name
     *  value = Field value
     * 
     * Returns:
     *  Models with row data
     */
    public static T[] findBy(V)(string name, V value)
    {
        string table = T.stringof;
        T[] ret;
        
        auto db = Database.instance;
        auto res = db.query("SELECT * FROM `{0}` WHERE `{1}`='{2}'", 
            table, 
            name,
            to!string(value));
        
        while(res.isValid)
        {
            ret ~= new T(res.fetchAssoc());
            res.next();
        }
        
        res.free();
        return ret;
    }
}

string nameOf(Object o)
{
    return (typeid(o).name.split(".")[$-1]);
}
