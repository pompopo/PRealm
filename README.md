# PRealm
Realm library for React Native. Currently only supports a few APIs and types.
Planning to support android.

# Install
1. Copy and add all files in `Class` into your React Native project.
2. Install realm-cocoa (https://github.com/realm/realm-cocoa) to your project. In my environment, Cocoa Pods caused an error.

# Demo
To run demo app, install realm-cocoa manually. Android demo does not use PRealm.

# Usage

```
var PRealm = require('NativeModules').PRealm;

PRealm.defineSchema("Person", {name: "string", age: "int", like: "array Item"});
PRealm.defineSchema("Item", {name: "string"});

var e1 = {name: "Beer"};
var e2 = {name: "Game"};
PRealm.add("Person", {name:"pompopo", age: 28, like: [e1, e2]});
PRealm.find("Person", "age > 26", (e) => {
  console.log(e);
});
```

# Models
`PRealm.defineSchema()` creates subclass of `RLMObject` dynamically.
```
PRealm.defineSchema("MyModel", {field1: type1, field2: type2...});
```
currently PRealm supports types below

- "string" (`NSString *`)
- "int" (`long long`)
- "bool" (`BOOL`)
- "float" (`float`)
- "array" T (`RLMArray<T>`. T must be a RLMObject)

and you can use primary key
- "string primary"
- "int primary"

# Adding, Updating, Deleting

- `PRealm.add(className, object)`
- `PRealm.update(className, object)`
- `PRealm.deleteAllObjects()`
- `PRealm.deleteObject(className, object)` // The class must have a primary key.

# Queries
- `PRealm.allObjects(className, callback)`
- `PRealm.find(className, query, callback)`

Because Objective-C codes cannot return value to JS in React Native, you must use callback function to get result.
```
PRealm.allObjects("MyModel", (e) => {
  console.log(e); // e is an array of objects.
});

PRealm.find("MyModel", "age > 26", (e) => {
  console.log(e[0]);
});
```
You can use query same as `[RLMObject objectsWhere:]`.

# Migrations
PRealm can only update Schema version...

`PRealm.setSchemaVersion(version)`

# TODO
- support all type (NSDate, NSData...)
- implement all RLMRealm APIs.
- add tests
- add license
