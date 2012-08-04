module sqld.c.postgre;

pragma(lib, "libpq");

extern(C):
struct PGconn {}
struct PGresult {}

PGconn* PQconnectdb(const(char)*);
PGconn* PQconnectdbParams(const(char)** keywords, const(char)** values, int expand_dbname);
void PQfinish(PGconn*);

int PQstatus(PGconn*);
void PQfreemem(const(void)*ptr);

const (char*) PQerrorMessage(PGconn*);

PGresult* PQexec(PGconn*, const(char)*);
void PQclear(PGresult*);

int PQresultStatus(PGresult*);

int PQnfields(PGresult*);
const(char*) PQfname(PGresult*, int);

int PQntuples(PGresult*);
const(char*) PQgetvalue(PGresult*, int row, int column);

size_t PQescapeString (char *to, const(char)* from, size_t length);
const(char)* PQescapeLiteral(PGconn*, const(char)*, size_t);
const(char)* PQcmdTuples(PGresult*);

int PQgetlength(const PGresult *res, int row_number, int column_number);
int PQgetisnull(const PGresult *res, int row_number, int column_number);


enum CONNECTION_OK = 0;
enum PGRES_COMMAND_OK = 1;
enum PGRES_TUPLES_OK = 2;