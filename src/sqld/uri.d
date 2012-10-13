/**
 * Uri parser
 *
 * Parse URI (Uniform Resource Identifiers) into parts described in RFC, based on tango.net.uri and GIO
 *
 * Authors: $(WEB github.com/robik, Robert 'Robik' Pasiński), $(WEB dzfl.pl/, Damian 'nazriel' Ziemba)
 * Copyright: Robert 'Robik' Pasiński, Damian 'nazriel' Ziemba 2011
 * License: $(WEB http://www.boost.org/users/license.html, Boost license)
 *
 * Source: $(REPO std/net/uri.d)
 */
module sqld.uri;

import std.string : indexOf;
import std.conv   : to;
import std.array  : split;

static import std.uri;


/**
 * Represents URI query
 */
struct UriQuery
{
    /**
     * Array of params
     */
    string[string] params;
    
    /**
     * Returns query param value with specified name
     * 
     * Params:
     *  name    =   Query param name
     * 
     * Throws:
     *  Exception if not exists
     * 
     * Return:
     *  String with contents
     */
    string opIndex(string name)
    {
        if(name !in params) {
            throw new Exception("Param with name '"~name~"' does not exists");
        }
        
        return params[name];
    }
    
    size_t length() const
    {
        return params.length;
    }
    
    /**
     * Adds new query param
     * 
     * Params:
     *  k = Key
     *  v = Value
     */
    void add(string k, string v)
    {
        params[k] = v;
    }
    
    /**
     * Removes query param
     */
    void remove(string k)
    {
        if(k in params) {
            params.remove(k);
        }
    }
}


/**
 * Represents URI
 * 
 * Examples:
 * ---------
 * auto uri = new Uri("http://domain.com/path"); 
 * assert(uri.domain == "domain.com");
 * assert(uri.path == "/path");
 * ---------
 */
class Uri
{   
    protected
    {
        string   _rawscheme;
        string   _domain;
        ushort   _port;
        string   _path;
        UriQuery _query;
        string   _rawquery;
        string   _user;
        string   _password;
        string   _fragment;
        string   _rawUri;
    }
    
    /**
     * Creates new Uri object
     * 
     * Params:
     *  uri =   Uri to parse
     */
    this(string uri)
    {
        parse(uri);
    }
    
    /**
     * Creates new Uri object
     * 
     * Params:
     *  uri =   Uri to parse
     *  port    =   Port
     */
    this(string uri, ushort port)
    {
        parse(uri, port);
    }
    
    /**
     * Parses Uri
     * 
     * Params:
     *  uri =   Uri to parse
     *  port    = Port
     */
    void parse(string uri, ushort port = 0)
    {
        reset();
        
        size_t i, j;
        _port = port;
        _rawUri = uri;
        
        /* 
         * Scheme
         */
        i = uri.indexOf("://");
        if(i != -1)  
        {
            _rawscheme = uri[0 .. i];                        
            uri = uri[i + 3 .. $];
        } 
        else
        {
            //i = uri.indexOf(":");
        }
        
        /* 
         * Username and Password
         */
        j = uri.indexOf("/");
        if(j != -1)
        {
            i = uri[0..j].indexOf("@");
            if(i != -1) 
            {
                j = uri[0..i+1].indexOf(":");
                
                if(j != -1) 
                {
                    _user = uri[0 .. j];
                    _password = uri[j+1 .. i];
                } 
                else 
                {
                    _user = uri[0 .. i];
                }
                
                uri = uri[i+1 .. $]; 
            }
        }
        
        /* 
         * Host and port
         */
        i = uri.indexOf("/");
        if(i == -1) i = uri.length;
        
        j = uri[0..i].indexOf(":");
        if(j != -1)
        {
            _domain = uri[0..j];
            _port = to!(ushort)(uri[j+1..i]);
        } 
        else
        {
            _domain = uri[0..i];
        }
        
            
        uri = uri[i .. $];   
        
        
        /*
         * Fragment
         */
        i = uri.indexOf("#");
        if(i != -1)
        {
            _fragment = uri[i+1..$];
            uri = uri[0..i];
        }
        
        
        /*
         * Path and Query
         */
        i = uri.indexOf("?");
        if(i != -1)
        {
            _rawquery = uri[i+1 .. $];
            _path = uri[0 .. i];
            parseQuery();  
        }
        else
            _path = uri[0..$];
            
        if ( _path == "" )
        {
            _path = "/";
        }
    }
	
    void parseQuery()
    {
        auto parts = _rawquery.split("&");
        
        foreach(part; parts)
        {
            auto i = part.indexOf("=");
            _query.add( part[0 .. i], part[i+1..$] );
        }
                
    }
        
    
        
    /**
     * Resets Uri Data
     * 
     * Example:
     * --------
     * uri.parse("http://domain.com");
     * assert(uri.domain == "domain.com");
     * uri.reset;
     * assert(uri.domain == null);
     * --------
     */
    void reset()
    {
        _port = 0;
        _domain = _domain.init;
        _path = _path.init;
        _rawquery = _rawquery.init;
        _query = UriQuery();
        _user = _user.init;
        _password = _password.init;
        _fragment = _fragment.init;
    }
    
    /**
     * Builds Uri string
     * 
     * Returns:
     *  Uri
     */
    alias build toString;
    
    /// ditto
    string build()
    {
        string uri;
        
        uri ~= _rawscheme ~ "://";
        
        if(_user)
        {
            uri ~= _user;
            if(_password)
                uri ~= ":"~ _password;
            
            uri ~= "@";   
        }
        
        uri ~= _domain;
        
        if(_port != 0)
            uri ~= ":" ~ to!(string)(_port);
            
        uri ~= _path;
        
        if(_rawquery)
            uri ~= "?" ~ _rawquery;
        
        if(_fragment)
            uri ~= "#" ~ fragment; 
        
        return uri;
    }
        
    /**
     * Returns: Raw scheme
     */
    @property string rawscheme() const
    {
        return _rawscheme;
    }
    
    /**
     * Returns: Uri domain
     */    
    @property string domain() const
    {
        return _domain;
    }
    
    /// ditto
    alias domain host;
    
    /**
     * Returns: Uri port
     */
    @property ushort port() const
    {
        return _port;
    }
    
    @property Uri port(ushort port_)
    {
        _port = port_;
        
        return this;
    }
    
    /**
     * Returns: raw Uri
     */
    @property string rawUri() const
    {
        return _rawUri;
    }
    
    /**
     * Returns: Uri path
     */
    @property string path() const
    {
        return _path;
    }
    
    @property Uri path(string path_)
    {
        _path = path_;
        return this;
    }
    /**
     * Returns: Uri query (raw)
     */
    @property string rawquery() const
    {
        return _rawquery;
    }
    
    @property UriQuery query()
    {
        return _query;
    }
    
    /**
     * Returns: Uri username
     */
    @property string user() const
    {
        return _user;
    }
    
    @property Uri user(string username)
    {
        _user = username;
        
        return this;
    }
    
    /**
     * Returns: Uri password
     */
    @property string password() const
    {
        return _password;
    }
    
    
    @property Uri password(string pass)
    {
        _password = pass;
        
        return this;
    }
    /**
     * Returns: Uri fragment
     */
    @property string fragment() const
    {
        return _fragment;
    }
    
    /**
     * Parses Uri and returns new Uri object
     * 
     * Params:
     *  uri =   Uri to parse
     *  port    =  Port
     * 
     * Returns:
     *  Uri
     * 
     * Example:
     * --------
     * auto uri = Uri.parseUri("http://domain.com", 80);
     * --------
     */
    static Uri parseUri(string uri, ushort port)
    {
        return new Uri(uri, port);
    }
    
    /**
     * Parses Uri and returns new Uri object
     * 
     * Params:
     *  uri =   Uri to parse
     * 
     * Returns:
     *  Uri
     * 
     * Example:
     * --------
     * auto uri = Uri.parseUri("http://domain.com");
     * --------
     */
    static Uri parseUri(string uri)
    {
        return new Uri(uri);
    }


    static string encode(string uri)
    {
        return std.uri.encode(uri);
    }
    
    
    static string decode(string uri)
    {
        return std.uri.decode(uri);
    }
}

unittest
{   
    auto uri = new Uri("http://user:pass@domain.com:80/path/a?q=query#fragment");
        
    assert(uri.host == "domain.com");
    assert(uri.port == 80);
    assert(uri.user == "user");
    assert(uri.password == "pass");
    assert(uri.path == "/path/a");
    assert(uri.rawquery == "q=query");
    assert(uri.query["q"] == "query");
    assert(uri.fragment == "fragment");
    
    uri.parse("http://google.com:666");
    assert(uri.port() == 666);
        
    UriQuery query = UriQuery();
    query.add("key", "value");
    query.add("key1" ,"value1");
    assert(query.length() == 2);
    
    uri = Uri.parseUri("http://test.com/mail/user@page.com");
    assert(uri.path == "/mail/user@page.com");
    assert(uri.rawscheme == "http");
}