module sqld.all;

public import
        sqld.uri,
        sqld.base.connection,
        sqld.db.mysql.connection;


/**
 * Connects to database using proper database driver
 * 
 * Params:
 *  uri = Connection parameters
 *  autoConnect = Auto connect?
 * 
 * Returns:
 *  Database connection
 */
IConnection openDatabase(string uri, bool autoConnect = true)
{
    Uri u = new Uri(uri);
    IConnection conn;
    
    switch(u.rawscheme)
    {
        case "mysql":
            conn = new MySqlConnection(uri);
        break;
            
        default:
            assert(0, "Unsupported database driver");
    }
    
    if(autoConnect)
        conn.open();
    
    return conn;
}

