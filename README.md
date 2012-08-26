## What is it?
SQLd is simple, open-source, object-oriented library written in D Progamming Language. 
It provides unified API for diffrent database drivers, such as MySQL, SQLite and PostgreSQL (more will be added).

#### This project is currently in development state, and API is changing pretty often.

## Examples

#### Simple Select
```D
import sqld.all;

void main()
{   
    /// Uri is used for defining connection details
    auto db = Database.factory("mysql://user:password@localhost/database");
    db.open();
    
    auto res = db.query("SELECT * FROM `test`");
    foreach(row; res)
    {
        writeln(row);
        writeln(row["column"]);
    }
    res.free();
    
    db.close();
}
```

#### Statements

```D
import std.stdio, sqld.all;

void main()
{   
    auto db = Database.factory("mysql://user:password@localhost/databae");
    db.open();
    
    db.prepare("UPDATE ? SET `name`=:name WHERE `id`=:id")
      .bindColumn("test")
      .bindValue(":id",   "0")
      .bindValue(":name", "name" )
      .execute();
        
    db.close();
}

```
