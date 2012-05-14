/**
 * This file is part of sqlD library
 *
 * Autors: Robert 'Robik' Pasiński
 * License: MIT License
 */
module sqld.core.mysql.params;

/**
 * Represents connection details
 */
struct MySQLParams
{
    /**
     * Host to connect
     */
    string host;
    
    /**
     * Username to log-in as
     */
    string user;
    
    /**
     * Username password
     */
    string pass;
    
    /**
     * Default database
     */
    string db;
    
    /**
     * Port to connect on
     */
    uint port;
    
    
    /**
     * Creates new ConnectionParams instance
     *
     * Params:
     *  host = Host name
     *  user = Database user name
     *  pass = Username password
     *  db   = Default database to select as first, if null, no database is selected 
     */
    this(string host, string user = "root", string pass = "", string db = null, uint port = 3306)
    {
        this.host     = host;
        this.user     = user;
        this.pass     = pass;
        this.db       = db; 
        this.port     = port;
    }
}