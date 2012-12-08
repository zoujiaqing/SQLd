module sqld.db.mysql.connection;

import std.string;

import sqld.db.mysql.c.mysql,
       sqld.db.mysql.error,
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
                null, 0);
        
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
    
    
    
    package SqlError createError()
    {
        int code = mysql_errno(_conn);
        string msg = to!string(mysql_error(_conn));
        
        return SqlError(code, translateError(code), msg);
    }
}

