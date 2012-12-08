module sqld.field;


/**
 * Field type.
 */
enum FieldType
{
    ///
    String,
    
    ///
    Integer,
    
    ///
    Short,
    
    ///
    Long,
    
    ///
    Float,
    
    ///
    Double,
    
    ///
    Real,
    
    ///
    Blob,
    
    ///
    DateTime,
    
    ///
    Date,
    
    ///
    Time,
    
    ///
    Bool,
    
    ///
    Byte
}


/**
 * Represents result field
 */
struct Field
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