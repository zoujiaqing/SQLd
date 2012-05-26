/**
 * This file is part of sqlD library
 *
 * Autors: Robert 'Robik' Pasiński
 * License: MIT License
 */
module sqld.core.mysql.database;

import sqld.base,
       sqld.dsn,
       sqld.statement,
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
    /**
     * Connection details
     */
    public MySQLParams params;
    
    /**
     * MySQL handle
     */
    public MYSQL* _sql;
    
    
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
        this();
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
        this();
    }
    
    /**
     * Creates new Database instance
     * 
     * Examples:
     * ---
     * auto dsn = Dsn("mysql:host=localhost;user=root;pass=...");
     * auto db = new MySQL(dsn);
     * db.open();
     * // ...
     * db.close();
     * ---
     * 
     * Params:
     *   dsn = DataSourceName
     */
    public this(Dsn dsn)
    {
        params.host = dsn["host"];
        
        if("user" in dsn) {
            params.user = dsn["user"];
        }
        
        if("pass" in dsn) {
            params.pass = dsn["pass"];
        }
        
        if("db" in dsn) {
            params.db = dsn["db"];
        }
        
        if("port" in dsn) {
            try {
                params.port = to!uint(dsn["port"]); 
            } catch(Throwable e)
            {
                throw new Exception("Port variable is not numeric");
            }
        }
    }
    
    /**
     * Creates new Database instance
     *
     * Examples:
     * ---
     * auto db = new MySQL("mysql:host=localhost;user=root;pass=...");
     * db.open();
     * // ...
     * db.close();
     * ---
     * 
     * Params:
     *   dsn = DataSourceName
     */
    public this(string dsn)
    {
        this(Dsn(dsn));
    }
    
    protected this()
    {
    }
    
    public ~this()
    {
        mysql_close(_sql);
    }
    
    
    /**
     * Connects to database
     *
     * Examples:
     * ---
     * auto db = new MySQL("mysql:host=localhost;user=root;pass=...");
     * db.open();
     * // ...
     * db.close();
     * ---
     *
     * Returns:
     *  MySQL
     *
     * Throws:
     *  DatabaseException if could not connect
     */
    public override Database open()
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
     * Examples:
     * ---
     * auto db = new MySQL("mysql:host=localhost;user=root;pass=...");
     * db.open();
     * // ...
     * db.close();
     * ---
     *
     * Returns:
     *  MySQL Database
     */
    public override Database close()
    {
        mysql_close(_sql);
        
        return this;
    }
    
    
    /**
     * Queries database with specified query
     *
     * Examples:
     * ---
     * db.execute("INSERT ...").execute("UPDATE ..."); // No result set is returned
     * ---
     *
     * ---
     * auto rows = db.execute("INSERT ...");
     * ---
     *
     * Params:
     *   query = Query to execute
     *
     * Throws:
     *  DatabaseException
     *
     * Returns:
     *   Affected rows
     */
    public override ulong execute(string query, string file = __FILE__, uint line = __LINE__)
    {
        uint res = mysql_query(_sql, query.c);
        if(res)
        {
            throw new DatabaseException("Could not execute query: "~query, file, line);
        }
        
        return mysql_affected_rows(_sql);
    }
    
    /**
     * Executes query and returns result
     *
     * Examples:
     * ---
     * auto res = db.query("SELECT ...");
     * while(res.isValid)
     * {
     *     writeln(res.fetchAssoc());
     *     res.next();
     * }
     * ---
     * ---
     * auto res = db.query("SELECT ...");
     * foreach(row; res)
     * {
     *     writeln(res["id"]);
     * }
     * ---
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
    public override MySQLResult query(string query, string file = __FILE__, uint line = __LINE__)
    {
        __gshared MYSQL_RES* result;
        int res;
        
        res = mysql_query(_sql, query.c);
        
        if(res)
        {
            throw new DatabaseException("Could not execute query: "~query, file, line);
        }
        else
        {
            result = mysql_store_result(_sql);
            if(result is null && mysql_field_count(_sql) != 0 )
            {                
                 throw new DatabaseException("Could not store result: "~query, file, line);
            }
        }
        
        return new MySQLResult(result);
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
    public override string escape(string str)
    {
        char[] tmp = new char[str.length * 2 + 1];
        uint u;
        
        u = cast(uint)mysql_real_escape_string(_sql, tmp.ptr, str.c, cast(uint)str.length);
        tmp.length = u;
        
        return to!(string)(tmp);
    }
    
    /**
     * Prepares new statement with speicified query
     *
     * Params:
     *  query = Statement query
     *
     * Returns:
     *  New statement
     */
    public override Statement prepare(string query)
    {
        return new Statement(this, query);
    }
    
    /**
     * Begins transaction
     *
     * Returns:
     *  MySQL This
     */
    public Database beginTransaction()
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
    public Database commit()
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
    public Database rollback()
    {
        execute("ROLLBACK;");
        return this;
    }
    
    /**
     * Checks if connection is estabilished
     *
     * Returns:
     *  True if connected to database, false otherwise
     */
    public bool isConnected() @property
    {
        return _sql == null;
    }
    
    /**
     * Returns MySQL client and server information
     *
     * Returns:
     *  MySqlInfo
     */
    public MySQLInfo info() @property
    {
        return MySQLInfo(_sql);
    }
    
    /**
     * Last error
     *
     * If no error occured, returns empty error struct
     *
     * Returns:
     *  DatabaseError Last error
     */
    public override DatabaseError error() @property
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
    public override bool isError() @property
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
    
    /**
     * Sets autocommit value
     *
     * Params:
     *  ac = Autocommit value
     */
    public void autoCommit(bool ac) @property
    {
        mysql_autocommit(_sql, cast(int)ac);
    }
    
}

