/**
 * This file is part of sqlD library
 *
 * Autors: Robert 'Robik' Pasiński
 * License: MIT License
 */
module sqld.db.sqlite.database;

import sqld.util,
       sqld.base.database,
       sqld.base.transaction,
       sqld.uri,       
       etc.c.sqlite3,
	   sqld.db.sqlite.statement,
       sqld.db.sqlite.error,
       sqld.db.sqlite.result,
       sqld.db.sqlite.table;
       
import std.string    : toStringz, replace;
import std.conv      : to;

version(SQLD_LINK_LIB)
{
	version(Windows)
	{
	    pragma(lib, "sqlite3.lib");
	}
	version(Unix)
	{
	    pragma(lib, "sqlite3.so")
	}
}

private alias toStringz c;

/**
 * Represents SQLite database connection
 */
final class SQLiteDatabase : Database
{   
    /**
     * Database file
     */
    public string file;
    protected sqlite3* _sql;
    SQLiteDatabaseError _error;
    bool _autoconnect;
    
    
    /**
     * Creates new SQLiteDatabase object instance
     * 
     * Params:
     *  db = Database filename
     *  autoconnect = Automatically connect to Database?
     */
    public this(string db, bool autoconnect)
    {
        this.file = db;
        this._autoconnect = autoconnect;
        this();
    }
    
    /**
     * Creates new Database instance
     * 
     * Examples:
     * ---
     * auto uri = Uri("sqlite:///db.sqlite");
     * auto db = new SQLiteDatabase(uri);
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
        this.file = uri.path[1..$];
        
        try {
            _autoconnect = strToBool(uri.query["autoconnect"]);            
        } catch(Exception e) {
        }
        
        this();
    }
    
    protected this()
    {
        if(_autoconnect) {
            open();
        }
        
        _error = new SQLiteDatabaseError(0);
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
     * auto db = new SQLiteDatabase("db.sqlite");
     * db.open();
     * // ...
     * db.close();
     * ---
     *
     * Returns:
     *  SQLite
     *
     * Throws:
     *  ConnectionException if could not connect
     */
    public override Database open()
    {   
        int res = sqlite3_open(file.c, &_sql);
                
        if(res != SQLITE_OK)
        {
            throw new ConnectionException("Could not connect to database");
        }
        
        return this;
    }
     
    /**
     * Disconnects from database
     *
     * Examples:
     * ---
     * auto db = new SQLiteDatabase("db.sqlite");
     * db.open();
     * // ...
     * db.close();
     * ---
     *
     * Returns:
     *  SQLite Database
     */
    public override Database close()
    {
        if(_sql !is null)
        {
            sqlite3_close(_sql);
            _sql = null;
        }
        
        return this;
    }
    
    
    /**
     * Executes query and returns result
     *
     * Examples:
     * ---
     * auto res = db.query("SELECT ...");
     * while(res.isValid)
     * {
     *     writeln(res.fetch());
     *     res.next();
     * }
     * ---
     * ---
     * auto res = db.query("SELECT ...");
     * foreach(row; res)
     * {
     *     writeln(row["id"]);
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
     *  SQLiteResult
     */
    public override SQLiteResult execute(string query, string file = __FILE__, uint line = __LINE__)
    {
        if(_sql is null) {
            throw new ConnectionException("Cannot execute query without connecting to database");
        }
        
        sqlite3_stmt* stmt;
        int res;
        
        res = sqlite3_prepare_v2(_sql, query.c, cast(int)query.length, &stmt, null);
        
        if ( res != SQLITE_OK )
        {
            throw new QueryException("Could not execute query: '"~query~"', "~ error.msg, file, line );
        }
        
        return new SQLiteResult(_sql, stmt);
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
    public override string escape(string str)
    {        
        string ret = str;
        ret = ret.replace(`'`, `''`);
        ret = ret.replace(`"`, `""`);
        return ret;
    }
    
    /**
     * Prepares new statement with specified query
     *
     * Params:
     *  query = Statement query
     *
     * Returns:
     *  New statement
     */
    public override SQLiteStatement prepare(string query)
    {
        if(_sql is null) {
            throw new ConnectionException("Cannot prepare statement without connecting to database");
        }
        
        return new SQLiteStatement(this, query);
    }
    
    /**
     * Begins transaction
     * 
     * Params:
     *  level = Transaction isolation level
     *
     * Returns:
     *  Transaction
     */
    public override Transaction beginTransaction(TransactionIsolation level = TransactionIsolation.ReadUncommited)
    {
        if(_sql is null) {
            throw new ConnectionException("Cannot begin transaction without connecting to database");
        }
        
        Transaction t = new Transaction(this);
        execute("BEGIN;");
        sqlite3_enable_shared_cache(1);
        
        if(level == TransactionIsolation.ReadUncommited) {
            execute("PRAGMA read_uncommited = true");
        } else if(level == TransactionIsolation.Serializable) {
            execute("PRAGMA read_uncommited = false");
        } else {
            throw new UnsupportedFeatureException("SQLite does not support requested isolation level");
        }
        
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
        return _sql != null;
    }
    
    /**
     * Last error
     *
     * If no error occured, returned error instance code 
     * property will be set to DatabaseErrorCode.NoError
     *
     * Returns:
     *  DatabaseError Last error
     */
    public override SQLiteDatabaseError error() @property
    {
        int    no  = sqlite3_errcode(_sql);
        
        return new SQLiteDatabaseError(no);
    }
    
    /**
     * Checks if any error occured
     *
     * Returns:
     *  True if any error occured, false otherwise
     */
    public override bool isError() @property
    {
        return this.error.code != DatabaseErrorCode.NoError;
    }
    
    /**
     * Returns table info
     *
     * Params:
     *  table = Table name
     * 
     * Returns:
     *  SqliteTable Table information
     */
    public override SQLiteTable tableInfo(string name)
    {
        return new SQLiteTable(this, name);
    }
    
    /**
     * SQLite connection handle
     *
     * Returns:
     *  SQLite connection handle
     */
    public sqlite3* handle() @property
    {
        return _sql;
    }
}