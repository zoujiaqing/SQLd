/**
 * This file is part of sqlD library
 *
 * Autors: Robert 'Robik' Pasiński
 * License: MIT License
 */
module sqld.db.mysql.database;

import sqld.base.database,
       sqld.base.error,
       sqld.base.transaction,
       sqld.uri,
       sqld.c.mysql,
	   sqld.db.mysql.statement,
       sqld.db.mysql.info,
       sqld.db.mysql.table,
       sqld.db.mysql.result;
       
import std.string : toStringz;
import std.conv   : to;
import std.stdio;

private alias toStringz c;

/**
 * Represents MySQL database connection
 */
final class MySQL : Database
{
    protected
    {
        string _user;
        string _pass;
        string _host;
        string _db;
        int    _port;
        MYSQL* _sql;
    }
    
    
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
        _host = address;
        _user = user;
        _pass = password;
        _db   = db;
        _port = port;
        this();
    }
    
    /**
     * Creates new Database instance
     *
     * Params:
     *  params = Connection params
     */
    public this(string[string] params)
    {
        if("host" !in params) {
            throw new ConnectionDetailsException("No 'host' parameter specified");
        } else {
            _host = params["host"];
        }
        
        if("user" !in params) {
            _user = "root";
        } else {
            _user = params["user"];
        }
        
        if("pass" !in params) {
            _pass = "";
        } else {
            _pass = params["pass"];
        }
        
        if("db" !in params) {
            _db = "";
        } else {
            _db = params["db"];
        }
        
        if("port" !in params) {
            _port = 3306;
        } else {
            _port = to!uint(params["port"]);
        }
    }
    
    /**
     * Creates new Database instance
     * 
     * Examples:
     * ---
     * auto uri = Uri("mysql://user:pass@localhost/");
     * auto db = new MySQL(uri);
     * db.open();
     * // ...
     * db.close();
     * ---
     * 
     * Params:
     *   uri = Uri
     */
    public this(Uri uri)
    {
        _host = uri.host;
        
        if(uri.user != "") {
            _user = uri.user;
        } else {
            _user = "root";
        }
        
        if(uri.password != "") {
            _pass = uri.password;
        } else {
            _pass = "";
        }
        
        if(uri.path.length > 1) {
            _db = uri.path[1..$];
        }
        
        if(uri.port != 0) {
            _port = uri.port;
        }
        
        this();
    }
    
    /**
     * Creates new Database instance
     *
     * Examples:
     * ---
     * auto uri = "mysql://user:pass@localhost/";
     * auto db = new MySQL(uri);
     * db.open();
     * // ...
     * db.close();
     * ---
     * 
     * Params:
     *   uri = DataSourceName
     */
    public this(string uri)
    {
        this(new Uri(uri));
    }
    
    protected this()
    {
        Database.instance = this;
    }
    
    public ~this()
    {
        close();
    }
    
    
    /**
     * Connects to database
     *
     * Examples:
     * ---
     * auto db = new MySQL("mysql://user:pass@host/db");
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
        
        if(_sql is null) {
            throw new ConnectionException("Could not init mysql instance");
        }
        
        _sql = mysql_real_connect(_sql,
                _host.c,
                _user.c,
                _pass.c,
                _db.c,
                _port,
                null, 0);
        
        if(_sql is null)
        {
            throw new DatabaseException("Could not connect to database");
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
        if(_sql != null) {
            mysql_close(_sql);
            _sql = null;
        }
        
        return this;
    }
    
    /**
     * Executes query and returns result
     *
     * Examples:
     * ---
     * auto res = db.execute("SELECT ...");
     * while(res.isValid)
     * {
     *     writeln(res.fetchAssoc());
     *     res.next();
     * }
     * ---
     * ---
     * auto res = db.execute("SELECT ...");
     * foreach(row; res)
     * {
     *     writeln(res["id"]);
     * }
     * ---
     *
     * Params:
     *  query = Query to execute
     *
     * Throws:
     *  DatabaseException
     *
     * Returns:
     *  MySQLResult
     */
    public override MySQLResult execute(string query, string file = __FILE__, uint line = __LINE__)
    {
        if(_sql is null) {
            throw new ConnectionException("Cannot execute query without connecting to database");
        }
        
        MYSQL_RES* result;
        int res;
        
        res = mysql_query(_sql, query.c);
        
        if(res)
        {
            throw new QueryException("Could not execute query '"~query~"': " ~ this.error.msg, file, line);
        }
        else
        {
            result = mysql_store_result(_sql);
            if(result is null && mysql_field_count(_sql) != 0 )
            {                
                 throw new QueryException("Could not store result: "~query, file, line);
            }
        }
        
        return new MySQLResult(_sql, result);
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
        if(_sql is null) {
            throw new ConnectionException("Cannot escape string without connecting to database");
        }
        
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
    public override MySQLStatement prepare(string query)
    {
        if(_sql is null) {
            throw new ConnectionException("Cannot prepare statement without connecting to database");
        }
        
        return new MySQLStatement(this, query);
    }
    
    /**
     * Begins transaction
     *
     * Returns:
     *  Transaction
     */
    public override Transaction beginTransaction(TransactionIsolation level = TransactionIsolation.ReadCommited)
    {
        if(_sql is null) {
            throw new ConnectionException("Cannot begin transaction without connecting to database");
        }
        
        Transaction t = new Transaction(this);
        execute("SET TRANSACTION ISOLATION LEVEL " ~ cast(string)level~";");
        execute("BEGIN;");
        return t;
    } 
    
    
    /**
     * Checks if connection is estabilished
     *
     * Returns:
     *  True if connected to database, false otherwise
     */
    public bool connected() @property
    {
        return (_sql != null) && (mysql_ping(_sql) == 0);
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
     * Returns table info
     *
     * Params:
     *  table = Table name
     */
    public override MySqlTable tableInfo(string name)
    {
        return new MySqlTable(this, name);
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

