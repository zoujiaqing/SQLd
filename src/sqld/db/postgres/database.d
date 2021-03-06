module sqld.db.postgres.database;

import sqld.util,
       sqld.base.database,
       sqld.base.result,
       sqld.base.transaction,
       sqld.uri,
       sqld.c.postgres,
	   sqld.db.postgres.statement,
       sqld.db.postgres.error,
       sqld.db.postgres.result,
       sqld.db.postgres.table;
import std.string;

/**
 * Represents PostgreSQL database connection
 */
final class PostgresDatabase : Database
{
    protected
    {
        PGconn*        _sql;
        string[string] _params;
        string[string] _aliases;
        int            _code;
        bool           _autoconnect;
        PostgresDatabaseError  _error;
    }
    
    
    /**
     * Creates new PostgresDatabase object instance
     * 
     * Autoconnect parameter takes "1", "t", "true", "y", "yes" as positive values, 
     * all others are taken as nonpositive.
     * 
     * Examples:
     * -------
     *  auto db = new PostgresDatabase([
     *  "host": "localhost",
     *  "user": "root",
     *  "pass": "foobar",
     *  "db":   "test",
     *  "port": "3306"
     *  "autoconnect": "true"
     * ]);
     * -------
     *
     * Throws:
     *  DatabaseException if error occured
     */
    public this(string[string] params)
    {
        _params = params;
        _aliases = ["pass": "password", "db": "dbname"];
        
        if("autoconnect" in params) {
            _autoconnect = strToBool(params["autoconnect"]);
            params.remove("autoconnect");
        }
        
        this();
    }
    
    /**
     * Creates new Database instance
     * 
     * Examples:
     * ---
     * auto uri = Uri("postgre://user:pass@localhost/");
     * auto db = new PostgresDatabase(uri);
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
        _params["host"] = uri.host;
        
        if(uri.user != "") {
            _params["user"] = uri.user;
        } else {
            _params["user"] = "postgres";
        }
        
        if(uri.password != "") {
            _params["password"] = uri.password;
        }
        
        if(uri.path.length > 1) {
            _params["dbname"] = uri.path[1..$];
        }
        
        if(uri.port != 0) {
            _params["port"] = to!string(uri.port);
        }
        
        auto params = uri.query;
        
        try {
            _autoconnect = strToBool(uri.query["autoconnect"]);            
        } catch(Exception e) {
        }
        
        foreach(k, v; params.params) {
            _params[k] = v;
        }
        
        this();
    }
    
    protected this()
    {
        if(_autoconnect) {
            open();
        }
        
        _error = new PostgresDatabaseError("");
        Database.instance = this;   
    }
    
    protected ~this()
    {
        close();
    }
    
    
    /**
     * Connects to database
     *
     * Examples:
     * ---
     * auto db = new PostgresDatabase("postgre://user:pass@host/db");
     * db.open();
     * // ...
     * db.close();
     * ---
     *
     * Returns:
     *  Postgre
     *
     * Throws:
     *  ConnectionException if could not connect
     */
    public override PostgresDatabase open()
    {
        _sql = PQconnectdb(paramsToCString());
        
        if( (_code = PQstatus(_sql)) != CONNECTION_OK) {
            _error.update("_CONN");
            throw new ConnectionException("Could not connect to database");
        }
        
        return this;
    }
    
    /**
     * Disconnects from database
     *
     * Examples:
     * ---
     * auto db = new PostgresDatabase("postgre://user:pass@host/db");
     * db.open();
     * // ...
     * db.close();
     * ---
     *
     * Returns:
     *  Postgres Database
     */
    public override PostgresDatabase close()
    {
        if(_sql !is null)
        {
            PQfinish(_sql);
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
     *  QueryException
     *
     * Returns:
     *  PostgresResult
     */
    public override PostgresResult execute(string query, string file = __FILE__, uint line = __LINE__)
    {
        if(_sql is null) {
            throw new ConnectionException("Cannot execute string without connecting to database");
        }
        
        PGresult* _res = PQexec(_sql, query.toStringz);
        auto status = PQresultStatus(_res);
        
        if(status != PGRES_COMMAND_OK && status != PGRES_TUPLES_OK)
        {
            _error.update(to!string(PQresultErrorField(_res, 'C')));
            throw new QueryException(_error.msg, file, line);
        }
        return new PostgresResult(_sql, _res);
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
        if(_sql is null) {
            throw new ConnectionException("Cannot execute query without connecting to database");
        }
        
        char[] buf = new char[str.length * 2 + 1];
        size_t u;
        
        u = PQescapeStringConn(_sql, buf.ptr, str.toStringz, str.length, null);
        buf.length = u;
        
        return to!string(buf);
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
    public override PostgresStatement prepare(string query)
    {
        if(_sql is null) {
            throw new ConnectionException("Cannot prepare statement without connecting to database");
        }
        
        return new PostgresStatement(this, query);
    }
    
    /**
     * Checks if connection is estabilished
     *
     * Returns:
     *  True if connected to database, false otherwise
     */
    public bool connected() @property
    {
        if(_sql is null)
            return false;
        
        try {
            query("SELECT 1+1;");
            return true;
        } catch(Exception e) {
            return false;
        }
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
    public override Transaction beginTransaction(TransactionIsolation level = TransactionIsolation.ReadCommited)
    {
        if(_sql is null) {
            throw new ConnectionException("Cannot begin transaction without connecting to database");
        }
            
        Transaction t = new Transaction(this);
        execute("BEGIN;");
        execute("SET TRANSACTION "~ cast(string)level);
        return t;
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
    public override PostgresDatabaseError error() @property
    {
        return _error;
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
     *  PostgresTable Table information
     */
    public override PostgresTable tableInfo(string name)
    {
        return new PostgresTable(this, name);
    }
    
    /**
     * Postgre connection handle
     *
     * Returns:
     *  Postgre connection handle
     */
    public PGconn* handle() @property
    {
        return _sql;
    }
    
    protected const(char)* paramsToCString()
    {
        string[] parts;
        
        foreach(k, v; _params)
        {
            if(k in _aliases)
                k = _aliases[k];
                
            parts ~= k~"="~v;
        }
        
        return parts.join(" ").toStringz();
    }
}

