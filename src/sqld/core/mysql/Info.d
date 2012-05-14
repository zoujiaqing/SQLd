/**
 * This file is part of sqlD library
 *
 * Autors: Robert 'Robik' Pasiński
 * License: MIT License
 */
module sqld.core.mysql.info;

import sqld.c.mysql;
import std.conv : to;

/**
 * Represents client info
 */
struct MySQLInfo
{
    /**
     * Client version as string
     */
    private MYSQL* _sql;
    
    
    
    /**
     * Creates new MySqlInfo instance
     *
     * Params:
     *  MySql handle, returned by mysql_init
     */
    public this(MYSQL* sql)
    {
        this._sql = sql;
    }
    
    /**
     * Returns client version
     *
     * This template only takes 2 types, string and integer.
     *
     * Numeric version format is returned in following format: 
     *  major_version*10000 + minor_version *100 + sub_version
     *
     * Examples:
     * ---
     * auto info = db.info;
     * writeln( info.clientVersion!string() ); // Prints client version to stdout
     * ---
     *
     * Returns:
     *  Client version in specified type
     */
    public T clientVersion(T)()
        if( is(T : string) || is(T : int) )
    {
        static if( is(T : string) )
        {
            return to!string( mysql_get_client_info() );
        }
        else static if( is(T : int) )
        {
            return mysql_get_client_version(_sql);
        }
        else
        {
            static assert(0, "Unsupported type: "~T.stringof);
        }
    }
    
    /**
     * Returns server version
     *
     * This template only takes 2 types, string and integer.
     *
     * Numeric version format is returned in following format: 
     *  major_version*10000 + minor_version *100 + sub_version
     *
     * Examples:
     * ---
     * auto info = db.info;
     * writeln( info.serverVersion!string() ); // Prints server version to stdout
     * ---
     *
     * Returns:
     *  Client server in specified type
     */
    public T serverVersion(T)()
        if( is(T : string) || is(T : int) )
    {
        static if( is(T : string) )
        {
            return to!string( mysql_get_server_info(_sql) );
        }
        else static if( is(T : int) )
        {
            return mysql_get_server_version(_sql);
        }
        else
        {
            static assert(0, "Unsupported type: "~T.stringof);
        }
    }
    
    /**
     * Returns SSL cipher
     *
     * Returns:
     *  Current SSL cipher used, null if none is used
     */
    public string cipher() @property
    {
        return to!string( mysql_get_ssl_cipher(_sql) );
    }
    
    /**
     * Host information
     *
     * Returns:
     *  String with host information
     */
    public string host() @property
    {
        return to!string(mysql_get_host_info(_sql));        
    }
}