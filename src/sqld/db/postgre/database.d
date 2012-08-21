module sqld.db.postgre.database;

import sqld.base.database,
       sqld.base.error,
       sqld.base.result,
       sqld.base.transaction,
       sqld.uri,
       sqld.base.statement,
       sqld.c.postgre,
       sqld.db.postgre.result;
import std.string;

/**
 * Represents PostgreSQL database connection
 */
class Postgre : Database
{
    /// Postgre database handle
    protected PGconn*        _sql;
    protected string[string] _params;
    protected string[string] _aliases;
    protected int            _code;
    protected DatabaseError  _error;
    
    
    /**
     * Creates new Postgre object instance
     * 
     * Params:
     *  params = Associative array with connection details
     *
     * Throws:
     *  DatabaseException if error occured
     */
    public this(string[string] params)
    {
        _params = params;
        _aliases = ["pass": "password", "db": "dbname"];
    }
    
    /**
     * Creates new Database instance
     * 
     * Examples:
     * ---
     * auto uri = Uri("postgre://user:pass@localhost/");
     * auto db = new Postgre(uri);
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
        
        for(int i; i < params.length; i++) {
            auto param = params[i];
            _params[param.name] = param.value;
        }
    }
    
    
    /**
     * Connects to database
     *
     * Examples:
     * ---
     * auto db = new Postgre("postgre://user:pass@host/db");
     * db.open();
     * // ...
     * db.close();
     * ---
     *
     * Returns:
     *  Postgre
     *
     * Throws:
     *  DatabaseException if could not connect
     */
    public override Database open()
    {
        _sql = PQconnectdb(paramsToCString());
        
        if( (_code = PQstatus(_sql)) != CONNECTION_OK) {
            _error.msg = to!string(PQerrorMessage(_sql));
            throw new DatabaseException("Could not connect: "~_error.msg);
        }
        
        return cast(Database)this;
    }
    
    /**
     * Disconnects from database
     *
     * Examples:
     * ---
     * auto db = new Postgre("postgre://user:pass@host/db");
     * db.open();
     * // ...
     * db.close();
     * ---
     *
     * Returns:
     *  Postgre Database
     */
    public override Database close()
    {
        PQfinish(_sql);
        return cast(Database)this;
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
     *  PostgreResult
     */
    public override PostgreResult execute(string query, string file = __FILE__, uint line = __LINE__)
    {
        PGresult* _res = PQexec(_sql, query.toStringz);
        
        auto status = PQresultStatus(_res);
        
        if(status != PGRES_COMMAND_OK && status != PGRES_TUPLES_OK) {
            _error.msg = to!string(PQresultErrorMessage(_res));
            throw new DatabaseException(_error.msg, file, line);
        }
        
        return new PostgreResult(_sql, _res);
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
    /*public override ulong execute(string query, string file = __FILE__, uint line = __LINE__)
    {
        PGresult* _res = PQexec(_sql, query.toStringz);
        auto status = PQresultStatus(_res);
        
        if(status != PGRES_COMMAND_OK && status != PGRES_TUPLES_OK) {
            throw new DatabaseException(to!string(PQresultErrorMessage(_res)), file, line);
        }
            
        string res = to!string(PQcmdTuples(_res));
        if(res == "")
            return -1;
        else
            return to!ulong(res);
    }*/
    
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
        char[] buf = new char[str.length * 2 + 1];
        size_t u;
        u = PQescapeStringConn(_sql, buf.ptr, str.toStringz, str.length, null);
        buf.length = u;
        
        return to!string(buf);
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
    public override Transaction beginTransaction(TransactionIsolation level = TransactionIsolation.ReadCommited)
    {
        Transaction t = new Transaction(this);
        execute("BEGIN;");
        execute("SET TRANSACTION "~ cast(string)level);
        return t;
    }
    
    /**
     * Last error
     *
     * If no error occured, returns empty error struct
     *
     * Todo:
     *  Support error codes 
     *
     * Returns:
     *  DatabaseError Last error
     */
    public override DatabaseError error() @property
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
        return this.error.number != 0;
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

