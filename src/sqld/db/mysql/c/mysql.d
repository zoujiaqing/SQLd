module sqld.db.mysql.c.mysql;

/**
 * This is based on misc-d-stuff by Adam D. Ruppe:
 *   https://github.com/adamdruppe/misc-stuff-including-D-programming-language-web-stuff
 */

//import core.stdc.config;
extern(System):
struct MYSQL {}
struct MYSQL_RES {}

struct LIST {
  LIST* prev, next;
  void *data;
}

struct USED_MEM {
  USED_MEM *next;
  uint left;
  uint size;
}

struct MEM_ROOT {
  USED_MEM* free;
  USED_MEM* used;
  USED_MEM* pre_alloc;
  uint min_malloc;
  uint block_size;
  uint block_num;
  uint first_block_usage;
  void function() error_handler;
}

struct MYSQL_STMT
{
    MEM_ROOT mem_root;
    LIST list;
    MYSQL *mysql;
    MYSQL_BIND *params;
    MYSQL_BIND *bind;
    MYSQL_FIELD *fields;
}

alias char* cstring;
alias const(const(char)*)* MYSQL_ROW;


struct MYSQL_FIELD
{ 
      const(char)* name;             /* Name of column */
      const(char)* org_name;         /* Original column name, if an alias */ 
      const(char)* table;            /* Table of column if column was a field */
      const(char)* org_table;        /* Org table name, if table was an alias */
      const(char)* db;               /* Database for table */
      const(char)* catalog;          /* Catalog for table */
      const(char)* def;              /* Default value (set by mysql_list_fields) */
      uint length;                   /* Width of column (create length) */
      uint max_length;               /* Max width for selected set */
      uint name_length;
      uint org_name_length;
      uint table_length;
      uint org_table_length;
      uint db_length;
      uint catalog_length;
      uint def_length;
      uint flags;                     /* Div flags */
      uint decimals;                  /* Number of decimals in field */
      uint charsetnr;                 /* Character set */
      enum_field_types  type;         /* Type of field. See mysql_com.h for types */
      
      void* extension; 
}

struct MYSQL_BIND
{
    uint *length;      /* output length pointer */
    char *is_null;     /* Pointer to null indicator */
    void *buffer;      /* buffer to get/put data */
    
    /* set this if you want to track data truncations happened during fetch */
    char*  error;
    ubyte* row_ptr;         /* for the current data position */
    void function(void*, MYSQL_BIND*) store_param_func;
    void function(MYSQL_BIND*, MYSQL_FIELD*, ubyte**) fetch_result;
    void function(MYSQL_BIND*, MYSQL_FIELD*, ubyte**) skip_result;
    
    /* output buffer length, must be set when fetching str/binary */
    uint buffer_length;
    uint offset;           /* offset position for char/binary fetch */
    uint length_value;     /* Used if length is 0 */
    uint param_number;     /* For null count and error messages */
    uint pack_length;      /* Internal length for packed data */
    enum_field_types buffer_type; /* buffer type */
    char error_value;      /* used if error is 0 */
    char is_unsigned;      /* set if integer type is unsigned */
    char long_data_used;   /* If used with mysql_send_long_data */
    char is_null_value;    /* Used if is_null is 0 */
    void *extension;
}

enum enum_field_types
{
    MYSQL_TYPE_DECIMAL,
    MYSQL_TYPE_TINY,
    MYSQL_TYPE_SHORT,
    MYSQL_TYPE_LONG,
    MYSQL_TYPE_FLOAT,
    MYSQL_TYPE_DOUBLE,
    MYSQL_TYPE_NULL,
    MYSQL_TYPE_TIMESTAMP,
    MYSQL_TYPE_LONGLONG,
    MYSQL_TYPE_INT24,
    MYSQL_TYPE_DATE,
    MYSQL_TYPE_TIME,
    MYSQL_TYPE_DATETIME,
    MYSQL_TYPE_YEAR,
    MYSQL_TYPE_NEWDATE,
    MYSQL_TYPE_VARCHAR,
    MYSQL_TYPE_BIT,
    MYSQL_TYPE_NEWDECIMAL=246,
    MYSQL_TYPE_ENUM=247,
    MYSQL_TYPE_SET=248,
    MYSQL_TYPE_TINY_BLOB=249,
    MYSQL_TYPE_MEDIUM_BLOB=250,
    MYSQL_TYPE_LONG_BLOB=251,
    MYSQL_TYPE_BLOB=252,
    MYSQL_TYPE_VAR_STRING=253,
    MYSQL_TYPE_STRING=254,
    MYSQL_TYPE_GEOMETRY=255
}

enum enum_stmt_attr_type
{
    STMT_ATTR_UPDATE_MAX_LENGTH,
    STMT_ATTR_CURSOR_TYPE
}

enum MYSQL_DATA_TRUNCATED = 100;
enum MYSQL_NO_DATA = 101;

char mysql_autocommit(MYSQL*, char);

const(char)* mysql_get_client_info();
MYSQL* mysql_init(MYSQL*);
uint mysql_errno(MYSQL*);
const(char)* mysql_error(MYSQL*);

MYSQL* mysql_real_connect(MYSQL*, const(char)*, const(char)*, const(char)*, const(char)*, uint, const(char)*, size_t);

int mysql_query(MYSQL*, const(char)*);
int mysql_real_query(MYSQL*, const(char)*, uint);

int mysql_select_db(MYSQL*, const(char)*);

void mysql_close(MYSQL*);
uint mysql_field_count(MYSQL*);

uint mysql_num_rows(MYSQL_RES*);
uint mysql_num_fields(MYSQL_RES*);
bool mysql_eof(MYSQL_RES*);

size_t mysql_affected_rows(MYSQL*);
size_t mysql_insert_id(MYSQL*);

MYSQL_RES* mysql_store_result(MYSQL*);
MYSQL_RES* mysql_use_result(MYSQL*);

MYSQL_ROW mysql_fetch_row(MYSQL_RES*);
uint* mysql_fetch_lengths(MYSQL_RES*);
MYSQL_FIELD* mysql_fetch_field(MYSQL_RES*);
MYSQL_FIELD* mysql_fetch_fields(MYSQL_RES*);


uint mysql_get_server_version(MYSQL*);
uint mysql_get_client_version();
const(char)* mysql_get_server_info(MYSQL*);

void mysql_data_seek(MYSQL_RES*, ulong);

const(char)* mysql_get_ssl_cipher(MYSQL*);

uint mysql_escape_string(char*, const(char)*, size_t);
uint mysql_real_escape_string(MYSQL*, char*, const(char)*, uint);

void mysql_free_result(MYSQL_RES*);

int mysql_ping(MYSQL *mysql);

uint mysql_commit(MYSQL *mysql);
const(char)* mysql_get_host_info(MYSQL*);

MYSQL_STMT *mysql_stmt_init(MYSQL*);
char mysql_stmt_close(MYSQL_STMT*);
char mysql_stmt_reset(MYSQL_STMT*);
int mysql_stmt_prepare(MYSQL_STMT*, const(char*), uint);
uint mysql_stmt_param_count(MYSQL_STMT*);
int mysql_stmt_execute(MYSQL_STMT*);
uint mysql_stmt_errno(MYSQL_STMT*);
const(char*) mysql_stmt_error(MYSQL_STMT*);
char mysql_stmt_bind_param(MYSQL_STMT*, MYSQL_BIND*);
uint mysql_stmt_field_count(MYSQL_STMT*);
char mysql_stmt_bind_result(MYSQL_STMT*, MYSQL_BIND*);
int mysql_stmt_fetch(MYSQL_STMT*);
MYSQL_RES* mysql_stmt_result_metadata(MYSQL_STMT*);
MYSQL_RES* mysql_stmt_param_metadata(MYSQL_STMT*);
int mysql_stmt_store_result(MYSQL_STMT*);
int mysql_stmt_fetch_column(MYSQL_STMT*, MYSQL_BIND*, uint, uint);
char mysql_stmt_free_result(MYSQL_STMT*);
char mysql_stmt_attr_set(MYSQL_STMT*,enum_stmt_attr_type, const(void*));
MYSQL_ROW_OFFSET mysql_stmt_row_tell(MYSQL_STMT*);
ulong mysql_stmt_num_rows(MYSQL_STMT*);

enum enum_mysql_timestamp_type
{
    MYSQL_TIMESTAMP_NONE     = -2,
    MYSQL_TIMESTAMP_ERROR    = -1,
    MYSQL_TIMESTAMP_DATE     = 0,
    MYSQL_TIMESTAMP_DATETIME = 1,
    MYSQL_TIMESTAMP_TIME     = 2
}

struct MYSQL_TIME
{
    uint year;
    uint month;
    uint day;
    uint hour;
    uint minute;
    uint second;
    uint second_part;
    char neg;
    enum_mysql_timestamp_type time_type;
}

struct MYSQL_ROWS {
  MYSQL_ROWS* next;
  MYSQL_ROW data;
  uint length;
}
alias MYSQL_ROWS* MYSQL_ROW_OFFSET;

enum enum_cursor_type
{
    CURSOR_TYPE_NO_CURSOR  = 0,
    CURSOR_TYPE_READ_ONLY  = 1,
    CURSOR_TYPE_FOR_UPDATE = 2,
    CURSOR_TYPE_SCROLLABLE = 4
}