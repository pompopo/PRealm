# PRealm
Realm library for React Native. Currently only supports a few APIs and types.

# Install
1. Copy and add all files in `Class` into your React Native project.
2. Install realm-cocoa (https://github.com/realm/realm-cocoa) to your project. In my environment, Cocoa Pods caused an error.

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

# TODO
- support all type (NSDate, NSData...)
- implement all RLMRealm APIs.
- add tests
- add license

