module sqld.db.mysql.field;

import sqld.field;



/**
 * Detailistic field meta information
 */
struct MySqlField
{
    /**
     * Field name.
     * 
     * May be an alias.
     */
    string name;
    
    
    /**
     * Field type
     */
    FieldType type;
    
    
    /**
     * Type length.
     */
    uint length;
    
    
    /**
     * True if field can be null
     */
    bool nullable;
    
    
    /**
     * Key type
     */
    KeyType key;
    
    
    /**
     * Default field value.
     * 
     * Can be null.
     */
    string defaultValue;
    
    
    
    /**
     * Creates new instance of Field
     * 
     * Params:
     *  name = Field name
     *  type = Field type
     */
    this(string name, FieldType type)
    {
        this.name = name;
        this.type = type;
    }
}