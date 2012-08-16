/**
 * Used to test stuff, don't use it now
 */
module sqld.model;

import sqld.base.database;
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
    protected ModelData _data;
    
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
        if(n !in _data)
        {
            throw new Exception("Field '"~n~"' does not exists");
        }
        
        return _data[n]; 
    } 
    
    public void opDispatch(string n, T)(T val)
    {
        _data[n] = to!string(val);
    }
    
    public override string toString()
    {
        return to!string(_data);
    }
        
    /**
     * Saves changes done to model
     */
    void save()
    {
        string[] sets;
        
        writeln(_fields, _data);
        
        foreach(field; _fields)
        {
            if(field in _data) {
                sets ~= "`"~field~"`='"~_data[field]~"'";
            } else {
                throw new Exception("Field '"~field~"' has been defined, but it's not set");
            }
        }
        _db.prepare("UPDATE `:table` SET :sets WHERE `id`=:data") 
           .bind(":table", tableName)
           .bind(":sets", sets.join(", "), false)
           .bind(":data", _data["id"])
           .execute();
    }
    
    /**
     * Removes current row
     */
    void remove()
    {
        _db.prepare("DELETE FROM `?` WHERE `id`=?") 
           .bind(tableName)
           .bind(_data["id"])
           .execute();
    }
    
    /**
     * Sets row that should be updated
     */
    protected void __fields(string[] fields) @property
    {
        _fields = ["id"] ~ fields;
    } 
    
    //-------------- STATIC
    
    public static T create(ModelData data)
    {
        string[] vals;
        
        foreach(val; data.values)
        {
            vals ~= "'"~val~"'";
        }
        
        Database.instance
           .prepare("INSERT INTO `?` VALUES(:vals)")
           .bind(tableName)
           .bind(":vals", vals.join(", "), false)
           .execute();
            
        return T.findById(Database.instance.insertedId);
    }
    
    /**
     * Finds row with specified ID
     *
     * Params:
     *  i = Row ID
     * 
     * Returns:
     *  Model with row data
     */
    public static T findById(ulong i)
    {
        auto db = Database.instance;
        auto res = db.prepare("SELECT * FROM `?` WHERE `id`='?'")
                     .bind(tableName)
                     .bind(i)
                     .execute();
                     
        ModelData row;
        
        if(res.isValid) {
           row = res.fetch().toAssocArray();
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
        auto res = 
                db.prepare("SELECT * FROM `?` WHERE `?`='?'")
                  .bind(tableName) 
                  .bind(name)
                  .bind(value)
                  .execute();
        
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
        
        auto res = db.prepare("SELECT * FROM `?` LIMIT ?")
                  .bind(tableName)
                  .bind(i)
                  .execute();
        
        while(res.isValid)
        {
            ret ~= new T(res.fetch().toAssocArray());
            res.next();
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
        auto res = 
                  db.prepare("SELECT * FROM `?` ORDER BY `id` DESC LIMIT :limit")
                    .bind(tableName)
                    .bind(":limit", i)
                    .execute();
        
        
        while(res.isValid)
        {
            ret ~= new T(res.fetch().toAssocArray());
            res.next();
        }
        res.free();
        return ret;
    }
    
    /** 
     * Returns all rows
     *
     * Returns:
     *  Models
     */
    public static T[] all()
    {
        T[] ret;
        
        auto db = Database.instance;
        auto res = 
                  db.prepare("SELECT * FROM `?`")
                    .bind(tableName)
                    .execute();
        
        while(res.isValid)
        {
            ret ~= new T(res.fetch().toAssocArray());
            res.next();
        }
        
        res.free();
        return ret;
    }
    
    
    static string tableName() @property
    {
        return T.stringof.toLower();
    }
    
}