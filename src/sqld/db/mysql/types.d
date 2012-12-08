module sqld.db.mysql.types;

import std.datetime;

public import sqld.db.mysql.c.mysql,
       sqld.field;

/**
 * Translates D type into MySql field type.
 */
template MySqlTypeOf(T)
{
    static if(is(T == int))
        alias enum_field_types.MYSQL_TYPE_LONG MySqlTypeOf;
    
    else static if(is(T == bool))
        alias enum_field_types.MYSQL_TYPE_BIT MySqlTypeOf;
    
    else static if(is(T == byte[]))
        alias enum_field_types.MYSQL_TYPE_BLOB MySqlTypeOf;
    
    else static if(is(T == char[]))
        alias enum_field_types.MYSQL_TYPE_STRING MySqlTypeOf;
    
    else static if(is(T == string))
        alias enum_field_types.MYSQL_TYPE_STRING MySqlTypeOf;
    
    else static if(is(T == byte))
        alias enum_field_types.MYSQL_TYPE_TINY MySqlTypeOf;
    
    else static if(is(T == short))
        alias enum_field_types.MYSQL_TYPE_SHORT MySqlTypeOf;
    
    else static if(is(T == float))
        alias enum_field_types.MYSQL_TYPE_FLOAT MySqlTypeOf;
    
    else static if(is(T == double))
        alias enum_field_types.MYSQL_TYPE_DOUBLE MySqlTypeOf;
    
    else static if(is(T == DateTime))
        alias enum_field_types.MYSQL_TYPE_DATETIME MySqlTypeOf;
    
    else static if(is(T == TimeOfDay))
        alias enum_field_types.MYSQL_TYPE_TIME MySqlTypeOf;
    
    else static if(is(T == Date))
        alias enum_field_types.MYSQL_TYPE_DATE MySqlTypeOf;
}

template DTypeOf(enum_field_types type)
{
    static if(type == enum_field_types.MYSQL_TYPE_LONG)
        alias int DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_BIT)
        alias bool DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_BLOB)
        alias byte[] DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_STRING)
        alias string DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_TINY)
        alias byte DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_SHORT)
        alias short DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_FLOAT)
        alias float DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_DOUBLE)
        alias double DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_DATETIME)
        alias DateTime DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_DATE)
        alias Date DTypeOf;
    
    else static if(type == enum_field_types.MYSQL_TYPE_TIME)
        alias Time DTypeOf;
}


bool typesCompatible(FieldType t1, FieldType t2)
{
    if(t1 == FieldType.String && t2 == FieldType.Blob
    || t2 == FieldType.String && t1 == FieldType.Blob)
        return true;
    
    return t1 == t2;
}


/**
 * Translates MySql field type into generic one
 * 
 * Params:
 *  type = MySql field type
 * 
 * Returns:
 *  Translated field type
 */
FieldType genericFieldTypeOf(enum_field_types type)
{
    switch(type)
    {
        case enum_field_types.MYSQL_TYPE_BIT:
            return FieldType.String;
        
        case enum_field_types.MYSQL_TYPE_TINY:
            return FieldType.Byte;
        
        case enum_field_types.MYSQL_TYPE_SHORT:
            return FieldType.Short;
        
        case enum_field_types.MYSQL_TYPE_LONG:
            return FieldType.Integer;
        
        case enum_field_types.MYSQL_TYPE_LONGLONG:
            return FieldType.Long;
        
        case enum_field_types.MYSQL_TYPE_FLOAT:
            return FieldType.Float;
        
        case enum_field_types.MYSQL_TYPE_DOUBLE:
            return FieldType.Double;
        
        case enum_field_types.MYSQL_TYPE_INT24:
            return FieldType.Integer;
        
        case enum_field_types.MYSQL_TYPE_TIME:
            return FieldType.Time;
        
        case enum_field_types.MYSQL_TYPE_TIMESTAMP:
            return FieldType.DateTime;
            
        case enum_field_types.MYSQL_TYPE_DATETIME:
            return FieldType.DateTime;
            
        case enum_field_types.MYSQL_TYPE_DATE:
            return FieldType.Date;
            
        case enum_field_types.MYSQL_TYPE_BLOB:
        case enum_field_types.MYSQL_TYPE_TINY_BLOB:
        case enum_field_types.MYSQL_TYPE_MEDIUM_BLOB:
        case enum_field_types.MYSQL_TYPE_LONG_BLOB:
            return FieldType.Blob;
        
        case enum_field_types.MYSQL_TYPE_STRING:
        case enum_field_types.MYSQL_TYPE_VAR_STRING:
        case enum_field_types.MYSQL_TYPE_VARCHAR:
            return FieldType.String;
            
        default:
            assert(0, "Unsupported type");
    }
}