/**
 * This file is part of sqlD library
 *
 * Autors: Robert 'Robik' Pasiński
 * License: MIT License
 */
module sqld.db.sqlite.database;

import sqld.base.database,
       sqld.base.error,
       sqld.base.transaction,
       sqld.uri,
       sqld.statement,
       etc.c.sqlite3,
       sqld.db.sqlite.result;
       
import std.string : toStringz;
import std.conv   : to;

version(Windows)
{
    pragma(lib, "sqlite3.lib");
}
version(Unix)
{
    pragma(lib, "sqlite3.so")
}

private alias toStringz c;

/**
 * Represents SQLite database connection
 */
class SQLite : Database
{   
    /**
     * Database file
     */
    public string file;
    
    /**
     * MySQL handle
     */
    protected sqlite3* _sql;
    
    
    
    /**
     * Creates new SQLite object instance
     * 
     * Params:
     *  db = Database filename
     *
     * Throws:
     *  DatabaseException if there is no memory to allocate MySQL connection
     */
    public this(string db)
    {
        this.file = db;
        this();
    }
    
    /**
     * Creates new Database instance
     * 
     * Examples:
     * ---
     * auto uri = Uri("sqlite:///db.sqlite");
     * auto db = new SQLite(uri);
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
        
        this();
    }
    
    protected this()
    {   
    }
    
    public ~this()
    {
        sqlite3_close(_sql);
    } 
    
    
    /**
     * Connects to database
     *
     * Examples:
     * ---
     * auto db = new SQLite("db.sqlite");
     * db.open();
     * // ...
     * db.close();
     * ---
     *
     * Returns:
     *  SQLite
     *
     * Throws:
     *  DatabaseException if could not connect
     */
    public override Database open()
    {
        int res = sqlite3_open(file.c, &_sql);
        
        if(res != SQLITE_OK)
        {
            throw new DatabaseException("Could not open database");
        }
        
        return this;
    }
     
    /**
     * Disconnects from database
     *
     * Examples:
     * ---
     * auto db = new SQLite("db.sqlite");
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
        sqlite3_close(_sql);
        
        return this;
    }
    
    /**
     * Queries database with specified query
     *
     * Examples:
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
        int res = sqlite3_exec(_sql, query.c, null, null, null);
        
        if ( res != SQLITE_OK )
        {
            throw new DatabaseException("Could not execute query: " ~ query, file, line);
        }
        return sqlite3_changes(_sql);
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
     *  SQLiteResult
     */
    public override SQLiteResult query(string query, string file = __FILE__, uint line = __LINE__)
    {
        sqlite3_stmt* stmt;
        int res;
        
        res = sqlite3_prepare_v2(_sql, query.c, cast(int)query.length, &stmt, null);
        
        if ( res != SQLITE_OK )
        {
            throw new DatabaseException("Could not execute query: "~query, file, line );
        }
        
        return new SQLiteResult(stmt);
    }
    
    /**
     * Escapes string
     *
     * To use this function, connection to server must be estabilished.
     *
     * Params:
     *  str = String to escape
     *
     * Returns:
     *  Escaped string
     */
    public override string escape(string str)
    {
        return to!(string)(sqlite3_mprintf("%q".c, str.c));
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
     *  Transaction
     */
    public override Transaction beginTransaction(TransactionIsolation level = TransactionIsolation.ReadUncommited)
    {
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
    public bool isConnected() @property
    {
        return _sql == null;
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
        int    no  = sqlite3_errcode(_sql);
        string msg = to!string(sqlite3_errmsg(_sql));
        
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
     * SQLite connection handle
     *
     * Returns:
     *  SQLite connection handle
     */
    public sqlite3* handle() @property
    {
        return _sql;
    }
    
    /**
     * Returns: last inserted row id
     */
    public override ulong insertedId() @property
    {
        return sqlite3_last_insert_rowid(_sql);
    }
}