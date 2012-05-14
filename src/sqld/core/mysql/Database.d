/**
 * This file is part of sqlD library
 *
 * Autors: Robert 'Robik' Pasiński
 * License: MIT License
 */
module sqld.core.mysql.database;

import sqld.base,
       sqld.c.mysql,       
       sqld.core.mysql.params,
       sqld.core.mysql.info,
       sqld.core.mysql.result;
       
import std.string : toStringz;
import std.conv   : to;
import std.stdio;

private alias toStringz c;

/**
 * Represents MySQL database connection
 */
class MySQL : Database
{
    alias typeof(this) self;
    
    /**
     * Connection details
     */
    public MySQLParams params;
    
    /**
     * MySQL handle
     */
    protected MYSQL* _sql;
    
    
    
    /**
     * Creates new MySQL object instance
     * 
     * Params:
     *  address = Host name to connect
     *  user    = Database username
     *  pass    = Database password
     *  db        = Default database to use
     *  port     = Port to connect on
     *
     * Throws:
     *  DatabaseException if there is no memory to allocate MySQL connection
     */
    public this(string address, string user = "root", string password = "", string db = null, int port = 3306)
    {
        this.params.host = address;
        this.params.user = user;
        this.params.pass = password;
        this.params.db   = db;
        this.params.port = port;
    }
    
    /**
     * Creates new Database instance
     *
     * Params:
     *  params = Connection params
     */
    public this(MySQLParams params)
    {
        this.params = params;
    }
    
    
    public ~this()
    {
        mysql_close(_sql);
    }
    
    
    /**
     * Connects to database
     *
     * Returns:
     *  MySQL
     *
     * Throws:
     *  DatabaseException if could not connect
     */
    public self connect()
    {
        _sql = mysql_init(null);
        
        if(_sql == null)
        {
            throw new DatabaseException("Could not init");
        }
        
        _sql = mysql_real_connect(_sql,
                params.host.c,
                params.user.c,
                params.pass.c,
                params.db.c,
                params.port,
                null, 0);
        
        if(_sql == null)
        {
            throw new DatabaseException("Could not connect");
        }
        
        return this;
    }
    
    /**
     * Disconnects from database
     *
     * Returns:
     *  MySQL self
     */
    public self close()
    {
        mysql_close(_sql);
        
        return this;
    }
    
    
    
    /**
     * Queries database with specified query
     *
     * Params:
     *   query = Query to execute
     *
     * Throws:
     *  DatabaseException
     *
     * Returns:
     *   MySQL Self
     */
    public self execute(string query, string[] values...)
    {
        string q = format(query, values);
        uint res = cast(uint)mysql_real_query(_sql, query.c, query.length);
        
        if(res)
        {
            throw new DatabaseException("Could not execute query: "~q);
        }
        
        return this;
    }
    
    /**
     * Executes query and returns result
     *
     * Params:
     *  query = Query to execute
     *  values = Values to bind
     *
     * Throws:
     *  DatabaseException
     *
     * Returns:
     *  MySQLResult
     */
    public MySQLResult query(string query, string[] values...)
    {
        MYSQL_RES* result;
        int res;
        
        query = format(query, values);
        res = mysql_query(_sql, query.c);
        
        if(res)
        {
            throw new DatabaseException("Could not execute query: "~query);
        }
        else
        {
            result = mysql_store_result(_sql);
            
            if(result is null && mysql_field_count(_sql) > 0)
            {
                throw new DatabaseException("Could not store result: "~query);
            }
        }
        
        return new MySQLResult(result, this);
    }
    
    /**
     * Formats string
     *
     * Replaces occurences of `{#}` with corresponding values.
     * Inserted values are escaped. To use this function, connection
     * must be estabilished, if you want to use offline version,
     * please use static version of this function.
     *
     * Examples:
     * ---
     * auto db = new MySQL(...);
     * auto q = db.format("SELECT * FROM `db` WHERE `id`='{0}'", "i'd");
     * writeln(q); // SELECT * FROM `db` WHERE `id`='i\'d
     * ---
     * 
     * Params:
     *  query = Query to execute
     *  values = Values to bind
     * 
     * Returns:
     *  Formatted string
     */
    public string format(string query, string[] values...)
    {
        string result = query;
        
        foreach(i, value; values)
        {
            result = result.replace("{"~to!string(i)~"}", this.escape(value));
        }
        
        return result;
    }
    
    /**
     * Formats string
     *
     * Replaces occurences of `{#}` with corresponding values.
     * Inserted values are escaped. 
     *
     * Examples:
     * ---
     * auto q = MySQL.Format("SELECT * FROM `db` WHERE `id`='{0}'", "i'd");
     * writeln(q); // SELECT * FROM `db` WHERE `id`='i\'d
     * ---
     * 
     * Params:
     *  query = Query to execute
     *  values = Values to bind
     * 
     * Returns:
     *  Formatted string
     */
    public static string Format(string query, string[] values...)
    {
        string result = query;
        
        foreach(i, value; values)
        {
            result = result.replace("{"~to!string(i)~"}", Escape(value));
        }
        
        return result;
    }
    
    /**
     * Escapes string
     *
     * To use this function, connection to server must be estabilished.
     * If you want to escape string without estabilishing connection, please
     * use static version of this function.
     *
     * Params:
     *  str = String to escape
     *
     * Returns:
     *  Escaped string
     */
    public string escape(string str)
    {
        size_t length = str.length * 2 + 1;
        char[] tmp = new char[length];
        
        mysql_real_escape_string(_sql, tmp.ptr, str.c, str.length);
        
        return to!(string)(tmp);
    }
    
    /**
     * Escapes string
     *
     * Params:
     *  str = String to escape
     *
     * Returns:
     *  Escaped string
     */
    public static string Escape(string str)
    {
        size_t length = str.length * 2 + 1;
        char[] tmp = new char[length];
        
        mysql_escape_string(tmp.ptr, str.c, str.length);
        
        return to!(string)(tmp);
    }
     
    /**
     * Begins transaction
     *
     * Returns:
     *  MySQL This
     */
    public self beginTransaction()
    {
        execute("BEGIN;");
        return this;
    }
    
    /**
     * Commits transaction changes
     *
     * Returns:
     *  MySQL This
     */
    public self commit()
    {
        execute("COMMIT;");
        return this;
    }
    
    /**
     * Rollbacks transaction changes
     *
     * Returns:
     *  MySQL This
     */
    public self rollback()
    {
        execute("ROLLBACK;");
        return this;
    }
    
    /**
     * Returns MySQL client and server information
     *
     * Returns:
     *  MySqlInfo
     */
    public MySQLInfo info() @property
    {
        return MySqlInfo(_sql);
    }
    
    public ulong affectedRows() @property
    {
        return mysql_affected_rows(_sql);
    }
    
    /**
     * Last error
     *
     * If no error occured, returns empty error struct
     *
     * Returns:
     *  DatabaseError Last error
     */
    public DatabaseError error() @property
    {
        int    no  = mysql_errno(_sql);
        string msg = to!string(mysql_error(_sql));
        
        return new DatabaseError(no, msg);
    }
    
    /**
     * Checks if any error occured
     *
     * Returns:
     *  True if any error occured, false otherwise
     */
    public bool isError() @property
    {
        return this.error.number != 0;
    }
    
    /**
     * MYSQL connection handle
     *
     * Returns:
     *  MYSQL connection handle
     */
    public MYSQL* handle() @property
    {
        return _sql;
    }
    
}

