## What is it?
SQLd is simple, open-source, object-oriented library written in D Progamming Language. 
It provides unified API for diffrent database drivers, such as MySQL, SQLite and others.

#### This project is currently in development state, and API may change in future.

## Examples

##### Using ActiveRecord
```D
import std.stdio,
       sqld.mysql,
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
