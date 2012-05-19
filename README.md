## What is it?
SQLd is simple, open-source, object-oriented library written in D Progamming Language. 
It provides unified API for diffrent database drivers, such as MySQL, SQLite and others.

#### This project is currently in development state, and API may change in future.

## Examples

#### Simple Select
```D
import sqld.base;

void main()
{   
    auto db = Database.factory("mysql:host=localhost;user=root");    
    db.open();
    
    auto res = db.query("SELECT * FROM `test`");
    foreach(row; res)
    {
        writeln(row["id"]);
    }
    res.free();
    
    db.close();
}
```

#### Statements

```D
import std.stdio, sqld.base;

void main()
{   
    auto db = Database.factory("mysql:host=localhost;user=root;pass=root;db=test");
    db.open();
    
    db.prepare("UPDATE `?` SET `name`=':name' WHERE `id`=:id")
      .bind("test")
      .bind(":id",   "0")
      .bind(":name", "name" )
      .execute();
        
    db.close();
}

```

##### Using ActiveRecord
```D
import std.stdio,
       sqld.base,
       sqld.model;

void main()
{   
    // Create database instance
    auto db = Database.factory("mysql:host=localhost;user=root");    
    db.open();
    
    // Find post with ID 1
    auto post = Posts.findId(1);
    writefln("(%d)Post by %s: %s", post.id, post.author, post.value);
    
    db.close();
}

// Model!YourClassName
class Posts : Model!Posts
{
    this( ModelData data )
    {
        super(data);
        
        // Only fields specified here will be updated on save
        fields = ["id", "value", "author"];
    }
}
```
