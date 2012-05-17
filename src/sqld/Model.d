module sqld.model;

import sqld.base;
import std.stdio;
import std.array : split, join;
import std.conv : to;
import std.string : toLower;

alias string[string] ModelData;

/**
 * Represents database row
 */
abstract class Model(T)
{
    
    /**
     * Row data, as AA
     */
    protected string[string] _data;
    
    /**
     * User defined fields
     */
    protected string[] _fields;
    
    /**
     * Database connection
     */
    protected Database _db;
    
    
    /**
     * Creates new Model from data
     */
    this(ModelData d)
    {
        _data = d;
        _db = Database.instance;
    }
     
    public string opDispatch(string n)()
    {
        return _data[n]; 
    } 
    
    public void opDispatch(string n, T)(T val)
    {
        _data[n] = to!string(val);
    }
        
    /**
     * Saves changes done to model
     */
    void save()
    {
        string[] sets;
        
        foreach(field; _fields)
        {
            sets ~= "`"~field~"`='"~_data[field]~"'";
        }
        
        string query = _db.format("UPDATE `{0}` SET {1} WHERE `id`={2}", 
            tableName,
            sets.join(", "),
            _data["id"]);
        
        _db.execute(query);
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
        auto db = Database.instance;
        auto res = db.query("SELECT * FROM `{0}` WHERE `id`='{1}'", tableName, to!string(i));
        ModelData row;
        
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
        T[] ret;
        
        auto db = Database.instance;
        auto res = db.query("SELECT * FROM `{0}` WHERE `{1}`='{2}'", 
            tableName, 
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
    
    /** 
     * Returns first row
     *
     * Returns:
     *  Model with first row data
     */
    public static T first()
    {
        return first(1)[0];
    }
    
    /** 
     * Returns first rows
     *
     * Params:
     *  i = Number of rows to fetch
     *
     * Returns:
     *  Model with first row data
     */
    public static T[] first(ulong i)
    {
        T[] ret;
        
        auto db = Database.instance;
        auto res = db.query("SELECT * FROM `{0}` WHERE 1 LIMIT {1}", tableName, to!string(i));
        
        if(res.length > 0) {
           ret ~= new T(res.fetchAssoc());
        } else {
            throw new Exception("No rows in"~ tableName);
        }
        res.free();
        return ret;
    }
    
    /** 
     * Returns last row
     *
     * Returns:
     *  Model with first row data
     */
    public static T last()
    {
        return last(1)[0];
    }
    
    /** 
     * Returns first rows
     *
     * Params:
     *  i = Number of rows to fetch
     *
     * Returns:
     *  Model with first row data
     */
    public static T[] last(ulong i)
    {
        T[] ret;
        
        auto db = Database.instance;
        auto res = db.query("SELECT * FROM `{0}` ORDER BY `id` DESC LIMIT {1}", tableName, to!string(i));
        
        if(res.length > 0) {
           ret ~= new T(res.fetchAssoc());
        } else {
            throw new Exception("No rows in"~ tableName);
        }
        res.free();
        return ret;
    }
    
    static string tableName() @property
    {
        return T.stringof.toLower();
    }
    
}
