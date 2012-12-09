module sqld.db.mysql.statement;

import std.c.stdlib;

import std.string, 
       std.stdio,
       std.datetime,
       std.conv,
       std.traits,
       std.typecons;

import sqld.base.statement,
       sqld.field,
       sqld.db.mysql.types,
       sqld.db.mysql.error,
       sqld.db.mysql.connection,
       sqld.db.mysql.c.mysql;


/**
 * Represents MySql statement
 * 
 * Used to execute stetements and receive results.
 * 
 * Types supported in binding and receiving:
 *  (u)int, (u)byte, (u)short, string, float, double, DateTime, TimeOfDay, Date
 * 
 * 
 * Examples:
 * ----
 * auto stmt = conn.prepare("SELECT ...");
 * stmt.execute();
 * 
 * while(stmt.next())
 * {
 *     auto row = stmt.read!(int, string...)
 * }
 * ----
 */
class MySqlStatement : IStatement
{
    protected MySqlConnection _conn;
    protected MYSQL_STMT* _stmt;
    protected MYSQL_BIND[] _paramBinds, _resultBinds;
    protected enum_field_types[] _resultFieldTypes;
    protected Field[] _fields;
    protected ResultData[] _results;
    protected bool _valid;
    protected bool _empty;
    
    protected uint _currentBind;
    protected int _paramCount;
    protected int _fieldCount;
    
    protected void*[] _refKeeper;
    
    
    protected struct ResultData
    {
        uint length;
        byte[] buffer;
        char[] error;
        char isNull;
    }
    
    
    /**
     * Creates new MySqlStatement instance
     * 
     * Params:
     *  conn = MySql database connection
     *  query = String query to execute
     * 
     * Throws:
     *  Statement exception if could not initalize statement instance
     */
	this(MySqlConnection conn, string query, string file = __FILE__, uint line = __LINE__)
	{
        _conn = conn;
		_stmt = mysql_stmt_init(cast(MYSQL*)conn.handle);
        
        if(_stmt is null) {
            throw new StatementException(createStmtError(), file, line);
        }
        
        prepare(query, file, line);
	}
    
    
    ~this()
    {
        close();
    }
    
    
    /**
     * Prepares SQL statement with given query
     * 
     * You can reset the statement to state after
     * calling `prepare()` using `reset()` function.
     * 
     * Params:
     *  query = Query to prepare
     */
    MySqlStatement prepare(string query, string file = __FILE__, uint line = __LINE__)
    {
        int res = mysql_stmt_prepare(_stmt, query.toStringz(), query.length);
        
        if(res) {
            throw new StatementException(createStmtError(), file, line);
        }
        
        _paramCount = mysql_stmt_param_count(_stmt);
        _refKeeper.length = _paramCount;
        _paramBinds.length = _paramCount;
        
        readMetadata();
        _resultBinds.length = _fieldCount;
        _results.length = _fieldCount;
        _valid = !(_fieldCount == 0);
        _empty = true;
        
        foreach(i; 0.._fieldCount)
        {
            _results[i].buffer.length = 64;
            _results[i].error.length = 128;
        }
        
        return this;
    }
    
    
    /**
     * Resets a prepared statement on client and server to state after prepare.
     * 
     * To re-prepare the statement with another query, use `prepare()`.
     */
    MySqlStatement reset()
    {
        _valid = false;
        _empty = true;
        _currentBind = 0;
        _paramBinds = [];
        
        foreach(r; _refKeeper)
        {
            free(r);
        }
        
        mysql_stmt_reset(_stmt);
        
        return this;
    }
    
    
    /**
     * Closes statements and frees up data
     * 
     * Statement is not usable after closing.
     */
    void close()
    {
        if(_stmt != null)
        {
            foreach(r; _refKeeper)
            {
                free(r);
            }
            
            mysql_stmt_free_result(_stmt);
            mysql_stmt_close(_stmt);
        }
    }
    
    
    /**
     * Binds next parameter in statement
     * 
     * If you want to bind specific parameter, use second overload
     * of this function that takes offset as first parameter.
     * When trying to bind more parameters that statement has, exception is thrown.
     * 
     * Params:
     *  param = Value to bind
     */
    MySqlStatement bindParam(T)(T param)
    {
        bindParam(++_currentBind, param);
        return this;
    }
    
    
    /**
     * Binds specific parameter to statement
     * 
     * Parameter offset starts at 1. If offset is
     * bigger than paramCount, Exception is thrown.
     * 
     * Params:
     *  pos = Parameter number, starting from 1
     *  param = Value to bind
     * 
     * Throws:
     *  OutOfBoundsException
     */
    MySqlStatement bindParam(T)(uint pos, T param)
    {
        if(pos > _paramCount)
            throw new Exception("Trying to bind more parameters than specified.");
        
        pos -= 1;
        
        _paramBinds[pos].length = null;
        _paramBinds[pos].is_null = null;
        _paramBinds[pos].buffer_type = MySqlTypeOf!T;
        
        static if(is(T == string))
        {
            _refKeeper[pos] = malloc(param.length);
            foreach(i, c; param)
            {
                (cast(char*)_refKeeper[pos])[i] = c;
            }
            _paramBinds[pos].buffer = _refKeeper[pos];
            _paramBinds[pos].buffer_length = param.length;
        }
        else static if(is(T == DateTime))
        {
            MYSQL_TIME time;
            
            time.year   = param.year;
            time.month  = param.month;
            time.day    = param.day;
            time.hour   = param.hour;
            time.minute = param.minute;
            time.second = param.second;
            time.neg    = param < DateTime();
            time.time_type = enum_mysql_timestamp_type.MYSQL_TIMESTAMP_DATETIME;
            
            _refKeeper[pos] = malloc(time.sizeof);
            *cast(MYSQL_TIME*)_refKeeper[pos] = time;
            _paramBinds[pos].buffer = _refKeeper[pos];
        }
        else static if(is(T == Date))
        {
            MYSQL_TIME time;
            
            time.year   = param.year;
            time.month  = param.month;
            time.day    = param.day;
            time.neg    = param < Date();
            time.time_type = enum_mysql_timestamp_type.MYSQL_TIMESTAMP_DATE;
            
            _refKeeper[pos] = malloc(time.sizeof);
            *cast(MYSQL_TIME*)_refKeeper[pos] = time;
            _paramBinds[pos].buffer = _refKeeper[pos];
        }
        else static if(is(T == TimeOfDay))
        {
            MYSQL_TIME time;
            
            time.hour   = param.hour;
            time.minute = param.minute;
            time.second = param.second;
            time.neg    = 0;
            time.time_type = enum_mysql_timestamp_type.MYSQL_TIMESTAMP_TIME;
            
            _refKeeper[pos] = malloc(time.sizeof);
            *cast(MYSQL_TIME*)_refKeeper[pos] = time;
            _paramBinds[pos].buffer = _refKeeper[pos];
        }
        else
        {
            _refKeeper[pos] = malloc(param.sizeof);
            *cast(T*)_refKeeper[pos] = param;
            _paramBinds[pos].buffer = _refKeeper[pos];
        }
        
        
        return this;
    }
    
    
    /**
     * Executes statement
     * 
     * If some parameters are not bound, Exception is thrown.
     */
    MySqlStatement execute(string file = __FILE__, uint line = __LINE__)
    {
        validateBinds(file, line);
        
        int res = mysql_stmt_bind_param(_stmt, _paramBinds.ptr);
        if(res) {
            throw new StatementException(createStmtError(), file, line);
        }
        
        _valid = _fieldCount > 0;
        
        if(_valid)
        {
            bindResult(file, line);
            if(mysql_stmt_bind_result(_stmt, _resultBinds.ptr)) {
                throw new StatementException(createStmtError(), file, line);
            }
        }
        
        res = mysql_stmt_execute(_stmt);
        if(res) {
            throw new StatementException(createStmtError(), file, line);
        }
        
        return this;
    }
    
    
    /**
     * Reads current row from database
     * 
     * Call to this function should be preceded by next() call
     * 
     * Examples:
     * ---
     * auto stmt = conn.prepare("SELECT ...");
     * while(stmt.next())
     * {
     *     auto row = stmt.read!(int, string, string...);
     * }
     * ---
     * 
     * Returns:
     *  False if no more rows remain, true otherwise.
     */
    Tuple!(T) read(T...)(string file = __FILE__, uint line = __LINE__)
    {   
        static assert(T.length != 0, "Cannot read to empty tuple");
        if(T.length > _fieldCount)
            assert(0, "Invalid parameter count");
                
        Tuple!(T) ret;
        
        foreach(i, ref e; ret)
        {
            if(!typesCompatible(genericFieldTypeOf(_resultFieldTypes[i]), 
                genericFieldTypeOf( MySqlTypeOf!(typeof(e) ))) )
                assert(0, format("Incompatible type specified(%d) at %s:%d", i + 1, file, line));
            
            try {
                readColumn(i, e);
            } catch(Exception e) {
                e.file = file;
                e.line = line;
                throw e;
            }
        }
        
        return ret;
    }
    
    
    /**
     * Fetches new row from result
     * 
     * To read row contents, use read() function.
     * 
     * Examples:
     * ---
     * auto stmt = conn.prepare("SELECT ...");
     * while(stmt.next())
     * {
     *     auto row = stmt.read!(int, string, string...);
     * }
     * ---
     * 
     * Returns:
     *  False is no rows left, true otherwise.
     */
    bool next(string file = __FILE__, uint line = __LINE__)
    {
        int res;
        
        res = mysql_stmt_fetch(_stmt);
        
        if(res == 1) {
            throw new StatementException(createStmtError(), file, line);
        }
        _empty = (res == 100);
        return !_empty;
    }
    
    
    /**
     * Gets the number of parameter markers present in the prepared statement.
     */
    @property uint paramCount()
    {
        return _paramCount;
    }
    
    
    /**
     * Gets the number of columns in result set
     * 
     * Returns 0 if no result set was produced.
     */
    @property uint fieldCount()
    {
        return _fieldCount;
    }
    
    
    /**
     * Returns true if statement returned result
     */
    @property bool valid()
    {
        return _valid;
    }
    
    
    /**
     * Returns true if no rows are remaining.
     */
    @property bool empty()
    {
        return _empty;
    }
    
    
    /**
     * Gets fields info
     */
    @property Field[] fields()
    {
        return _fields;
    }
    
    
    
    /*
     * Reads result metadata if any
     */
    protected void readMetadata()
    {
        auto res = mysql_stmt_result_metadata(_stmt);
        if(res == null) {
            _fieldCount = 0;
            return;
        }
        
        _fieldCount = mysql_num_fields(res);
        _resultFieldTypes.length = _fieldCount;
        _fields.length = _fieldCount;
        
        for(int i = 0; i < _fieldCount; i++)
        {
            auto field = mysql_fetch_field(res);
            _resultFieldTypes[i] = field.type;
            _fields[i].name = to!string(field.name);
            _fields[i].type = genericFieldTypeOf(field.type);
        }
    }
    
    
    /*
     * Binds MySql data references to respective result element
     */
    protected void bindResult(string file = __FILE__, uint line = __LINE__)
    {
        foreach(i; 0 .. _fieldCount)
        {
            auto gen = genericFieldTypeOf(_resultFieldTypes[i]);
            if(gen == FieldType.String || gen == FieldType.Blob)
            {
                _resultBinds[i].buffer = null;
                _resultBinds[i].buffer_length = 0;
                _resultBinds[i].length = &_results[i].length;
            }
            else
            {
                _resultBinds[i].buffer = _results[i].buffer.ptr;
            }
            
            _resultBinds[i].buffer_type = _resultFieldTypes[i];
            _resultBinds[i].is_null = &_results[i].isNull;
            _resultBinds[i].error = _results[i].error.ptr;
        }
    }
    
    
    /*
     * Validates parameter bindings
     */
    protected void validateBinds(string file, uint line)
    {
        foreach(bind; _paramBinds)
        {   
            if(bind.buffer == null) {
                throw new Exception("Parmeter not bound", file, line);
            }
        }
    }
    
    
    /*
     * Reads specific column from statement result
     * 
     * v parameter contains read data
     */
    protected void readColumn(T)(int n, ref T v)
    {
        static if(isDynamicArray!T)
        {
            MYSQL_BIND[1] bind;
            _results[n].buffer.length = _results[n].length;
            bind[0].buffer_length = _results[n].length;
            bind[0].buffer = _results[n].buffer.ptr;
            
            mysql_stmt_fetch_column(_stmt, bind.ptr, n, 0);
            
            v = cast(T)(_results[n].buffer);
        }
        else static if(is(T == DateTime))
        {
            MYSQL_TIME time;
            time = *cast(MYSQL_TIME*)_results[n].buffer.ptr;
            
            if(time.time_type != enum_mysql_timestamp_type.MYSQL_TIMESTAMP_DATETIME)
                assert(0, format("Tried to read field as DateTime, field time type: %s", to!string(time.time_type)));
            
            v = DateTime(time.year, time.month, time.day, time.hour, time.minute, time.second);
            if(time.neg)
                v.year = -v.year;
        }
        else static if(is(T == TimeOfDay))
        {
            MYSQL_TIME time;
            time = *cast(MYSQL_TIME*)_results[n].buffer.ptr;
            
            if(time.time_type != enum_mysql_timestamp_type.MYSQL_TIMESTAMP_TIME)
                assert(0, format("Tried to read field as Time, field time type: %s", to!string(time.time_type)));
            
            v = TimeOfDay(time.hour, time.minute, time.second);
        }
        else static if(is(T == Date))
        {
            MYSQL_TIME time;
            time = *cast(MYSQL_TIME*)_results[n].buffer.ptr;
            
            if(time.time_type != enum_mysql_timestamp_type.MYSQL_TIMESTAMP_DATE)
                assert(0, format("Tried to read field as Date, field time type: %s", to!string(time.time_type)));
            
            v = Date(time.year, time.month, time.day);
            if(time.neg)
                v.year = -v.year;
        }
        else
        {
            v = *cast(T*)_results[n].buffer.ptr;
        }
    }
    
    
    /*
     * Creates statement error exception from error number and message
     */
    protected SqlError createStmtError()
    {
        int code = mysql_stmt_errno(_stmt);
        string msg = to!string(mysql_stmt_error(_stmt));
        
        return SqlError(code, translateError(code), msg);
    }
}