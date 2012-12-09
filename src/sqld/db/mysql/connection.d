module sqld.db.mysql.connection;

import std.string;

import sqld.db.mysql.c.mysql,
       sqld.db.mysql.error,
       sqld.db.mysql.table,
       sqld.base.connection,
       sqld.base.statement;

public import
       sqld.uri,
       sqld.exception,
       sqld.base.error,
       sqld.db.mysql.params,
       sqld.db.mysql.command,
       sqld.db.mysql.result,
       sqld.db.mysql.statement;


/**
 * Represents connection to MySql database
 */
class MySqlConnection : IConnection
{
    protected MySqlConnectionParams _params;
    protected MYSQL* _conn;
    protected MySqlTableInfo _tables;
    
    
    
    /**
     * Creates new MySqlConnection instance
     * 
     * Params:
     *  params = Connection parameters
     */
	this(MySqlConnectionParams params)
	{
		_params = params;
        
        if(_params.autoConnect)
            open();
	}
    
    
    /**
     * Creates new MySqlConnection instance
     * 
     * Params:
     *  uri = Connection params as uri string
     */
    this(string uri)
    {
        _params = new MySqlConnectionParams(uri);
    }
    
    
    ~this()
    {
        close();
    }
    
    /**
     * Opens connection to MySql database
     * 
     * Throws:
     *  ConnectionException
     * 
     * Returns:
     *  MySqlConnection
     */
    MySqlConnection open()
    {
        _conn = mysql_init(null);
        
        if(_conn is null) {
            throw new ConnectionException(createError());
        }
        
        _conn = mysql_real_connect(_conn,
                    _params.host.toStringz(),
                    _params.user.toStringz(),
                    _params.password.toStringz(),
                    _params.database.toStringz(),
                    _params.port,
                    null, 0
                );
        
        mysql_set_character_set(_conn, "utf8".toStringz());
        _tables = new MySqlTableInfo(this);
        
        return this;
    }
    
    
    /**
     * Closes database connection
     * 
     * Returns:
     *  MySqlConnection
     */
    MySqlConnection close()
    {
        if(_conn != null) {
            mysql_close(_conn);
            _conn = null;
        }
        
        return this;
    }
    
    
    /**
     * Creates new command
     * 
     * Params:
     *  query = Command text
     * 
     * Returns:
     *  MySqlCommand
     */
    MySqlCommand createCommand(string query = "", string file = __FILE__, uint line = __LINE__)
    {
        return new MySqlCommand(this, query);
    }
    
    
    /**
     * Executes query and returns result
     * 
     * If result is empty, or executed query did not produce result,
     * returned value should have .valid property set to false.
     * 
     * If executing query fails, `QueryException is thrown`.
     * 
     * Returns:
     *  Query result
     */
    MySqlResult executeQuery(string query, string file = __FILE__, uint line = __LINE__)
    {
        return createCommand(query, file, line).executeQuery(file, line);
    }
    
    /// ditto
    alias executeQuery executeResult;
    
    
    /**
     * Executes query and returns affected rows
     * 
     * If query fails, QueryException is thrown.
     * 
     * Returns:
     *  Number of rows affected
     */
    ulong execute(string query, string file = __FILE__, uint line = __LINE__)
    {
        return createCommand(query, file, line).execute(file, line);
    }
    
    
    /**
     * Creates new prepared statement
     * 
     * Params:
     *  query = Statement query
     */
    MySqlStatement prepare(string query, string file = __FILE__, uint line = __LINE__)
    {
        return new MySqlStatement(this, query, file, line);
    }
    
    
    
    /**
     * Checks if connection is alive
     *
     * Returns:
     *  True if connected to database, false otherwise
     */
    @property bool alive()
    {
        return (_conn != null) && (mysql_ping(_conn) == 0);
    }
    
    
    /**
     * Underlying database connection handle
     */
    @property void* handle()
    {
        return _conn;
    }
    
    
    /**
     * Gets server version
     * 
     * Number that reperesents the version is in following format:
     * 
     *  major_version*10000 + minor_version *100 + sub_version
     */
    @property uint serverVersion()
    {
        return mysql_get_server_version(_conn);
    }
    
    
    /**
     * Gets table information
     */
    @property MySqlTableInfo tables()
    {
        return _tables;
    }
    
    
    
    /*
     * Creates database error exception from MySql error number and message
     */
    package SqlError createError()
    {
        int code = mysql_errno(_conn);
        string msg = to!string(mysql_error(_conn));
        
        return SqlError(code, translateError(code), msg);
    }
}

