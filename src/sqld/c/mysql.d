/**
 * This is based on misc-d-stuff by Adam D. Ruppe:
 *   https://github.com/adamdruppe/misc-stuff-including-D-programming-language-web-stuff
 */
module sqld.c.mysql;

version(SQLD_LINK_LIB)
{
	version(Windows)
	{
	    pragma(lib, "libmysql");
	}
	version(Unix)
	{
	    pragma(lib, "mysql")
	}
}


//import core.stdc.config;
extern(System):
struct MYSQL {};
struct MYSQL_RES {};
struct MYSQL_STMT {};

alias char* cstring;
alias const(const(char)*)* MYSQL_ROW;


struct MYSQL_FIELD { 
      const(char)* name;                 /* Name of column */
      const(char)* org_name;             /* Original column name, if an alias */ 
      const(char)* table;                /* Table of column if column was a field */
      const(char)* org_table;            /* Org table name, if table was an alias */
      const(char)* db;                   /* Database for table */
      const(char)* catalog;                  /* Catalog for table */
      const(char)* def;                  /* Default value (set by mysql_list_fields) */
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
      uint type;                     /* Type of field. See mysql_com.h for types */
      
      // type is actually an enum btw
      void* extension; 
}

char mysql_autocommit(MYSQL*, char);


const(char)* mysql_get_client_info();
MYSQL* mysql_init(MYSQL*);
uint mysql_errno(MYSQL*);
const(char)* mysql_error(MYSQL*);

MYSQL* mysql_real_connect(MYSQL*, const(char)*, const(char)*, const(char)*, const(char)*, uint, const(char)*, size_t);

int mysql_query(MYSQL*, const(char)*);
int mysql_real_query(MYSQL*, const(char)*, uint);

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
uint mysql_get_client_version(MYSQL*);
const(char)* mysql_get_server_info(MYSQL*);

void mysql_data_seek(MYSQL_RES*, ulong);

const(char)* mysql_get_ssl_cipher(MYSQL*);

uint mysql_escape_string(char*, const(char)*, size_t);
uint mysql_real_escape_string(MYSQL*, char*, const(char)*, uint);

void mysql_free_result(MYSQL_RES*);

int mysql_ping(MYSQL *mysql);

uint mysql_commit(MYSQL *mysql);
const(char)* mysql_get_host_info(MYSQL*);