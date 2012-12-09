module sqld.db.mysql.params;

import sqld.uri,
       sqld.exception,
       sqld.util;

/**
 * Represents MySql connection parameters
 */
final class MySqlConnectionParams
{
    /**
     * Host to connect to
     * 
     * Required.
     */
    string host;
    
    /**
     * User name
     */
    string user = "root";
    
    /**
     * Password
     */
    string password = "";
    
    /**
     * Database name
     */
    string database;
    
    /**
     * Port
     */
    ushort port = 3306;
        
    /**
     * Autoconnect to db?
     */
    bool autoConnect = true;
    
    
    /**
     * Creates new MySqlConnectionParams
     * 
     * Note that hostname must be specified before using.
     */
    this()
    {
    }
    
    
    /**
     * Creates new MySqlConnectionParams
     * 
     * Params:
     *  uri = Connection Uri as string
     */
	this(string uri)
	{
        this(new Uri(uri));
	}
    
    
    /**
     * Creates new MySqlConnectionParams
     * 
     * Params:
     *  uri = Connection Uri
     */
    this(Uri uri)
    {
        loadUri(uri);
    }
    
    
    /**
     * Creates new MySqlConnectionParams
     * 
     * Array keys used:
     * 
     *  host - Required, host name
     *  user - User name. "root" by default
     *  pass, password - Password. Empty by default.
     *  db, dbname - Database name.
     *  port - Port to connect to
     *  autoconnect - Autoconnect to database?
     * 
     * Params:
     *  params = Associative array with options
     */
    this(string[string] params)
    {
        loadAssocArray(params);
    }
    
    
    /**
     * Creates new MySqlConnectionParams
     * 
     * Params:
     *  host = Host to connect to
     *  user = User name
     *  pass = User password
     *  db = Database name
     *  port = Port to connect to
     */
    this(string host, string user = "root", string pass = "", string db = "", ushort port = 3306)
    {
        loadParams(host, user, pass, db, port);
    }
    
    
    /**
     * Loads connection parameters from URI
     * 
     * Examples:
     * ---
     *  auto params = new MySqlConnectionParams();
     *  params.loadUri(new Uri("user:password@host/database?autoconnect=true"));
     * ---
     * 
     * ---
     *  auto params = new MySqlConnectionParams(new Uri("user:password@host/database?autoconnect=true"));
     * ---
     * 
     * Params:
     *  params = Associative array with options
     */
    MySqlConnectionParams loadUri(Uri uri)
    {
        this.host = uri.host;
        
        if(uri.user != "") {
            user = uri.user;
        }
        
        if(uri.password != "") {
            password = uri.password;
        }
        
        if(uri.path.length > 1) {
            database = uri.path[1..$];
        }
        
        if(uri.port != 0) {
            port = uri.port;
        }
        
        try {
            autoConnect = uri.query["autoconnect"].strToBool();
        } catch(Exception e) {
        }
        
        return this;
    }
    
    
    /**
     * Loads parameters from associative array
     * 
     * Array keys used:
     * 
     *  host - Required, host name
     *  user - User name. "root" by default
     *  pass, password - Password. Empty by default.
     *  db, dbname - Database name.
     *  port - Port to connect to
     *  autoconnect - Autoconnect to database?
     * 
     * Params:
     *  params = Associative array with options
     */
    MySqlConnectionParams loadAssocArray(string[string] params)
    {
        if("host" !in params) {
            throw new MissingParameterException("No 'host' parameter specified");
        } else {
            host = params["host"];
        }
        
        if("user" in params) {
            user = params["user"];
        }
        
        if("pass" in params) {
            password = params["pass"];
        }
        else if("password" in params) {
            password = params["password"];
        }
        
        if("db" in params) {
            database = params["db"];
        }
        else if("dbname" in params) {
            database = params["dbname"];
        }
        
        if("port" in params) {
            port = to!ushort(params["port"]);
        }
        
        if("autoconnect" !in params) {
            autoConnect = false;
        } else {
            autoConnect = params["autoconnect"].strToBool();
        }
        
        return this;
    }
    
    /**
     * Loads parameters
     * 
     * Params:
     *  host = Host to connect to
     *  user = User name
     *  pass = User password
     *  db = Database name
     *  port = Port to connect to
     */
    MySqlConnectionParams loadParams(string host, string user = "root", string pass = "", string db = "", ushort port = 3306)
    {
        this.host = host;
        this.user = user;
        this.password = pass;
        this.database = db;
        this.port = port;
        
        return this;
    }
}

unittest
{
    auto p = new MySqlConnectionParams();
    p.loadAssocArray([
            "host":"localhost",
            "user":"user",
            "pass":"pass",
            "port":"3304",
            "db":"foo"
    ]);
    
    assert(p.host == "localhost");
    assert(p.user == "user");
    assert(p.password == "pass");
    assert(p.database == "foo");
    assert(p.port == 3304);
    
    p.loadParams("h", "u", "p", "db", 3300);
    assert(p.host == "h");
    assert(p.user == "u");
    assert(p.password == "p");
    assert(p.database == "db");
    assert(p.port == 3300);
    
    p.loadUri(new Uri("resu:ssap@tsoh:6033/bd"));
    assert(p.host == "tsoh");
    assert(p.user == "resu");
    assert(p.password == "ssap");
    assert(p.database == "bd");
    assert(p.port == 6033);
}