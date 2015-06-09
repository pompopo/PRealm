//
//  RLMObject+PRealm.m
//  PRealmDemo
//
//  Created by pompopo on 2015/06/09.
//  Copyright (c) 2015年 Facebook. All rights reserved.
//

#import "RLMObject+PRealm.h"
#import <objc/runtime.h>

@implementation RLMObject (PRealm)
- (NSDictionary *)dictionary {
  NSMutableDictionary *tmp = @{}.mutableCopy;
  for (NSString *key in [self allPropertyNames]) {
    id value = [self valueForKey:key];
    if ([value isKindOfClass:[RLMArray class]]) {
      NSMutableArray *array = @[].mutableCopy;
      for (RLMObject *elem in value) {
        [array addObject:[elem dictionary]];
      }
      tmp[key] = array;
    } else {
      tmp[key] = value;
    }
  }
  return tmp.copy;
}

+ (void)createClassNamed:(NSString *)name scheme:(NSDictionary *)dict {
  Class klass = objc_allocateClassPair([RLMObject class], [name UTF8String], 0);
  for (NSString *key in [dict allKeys]) {
    const char *iVarName = [[NSString stringWithFormat:@"_%@", key] UTF8String];
    
    class_addIvar(klass, iVarName, sizeof(id), rint(log2(sizeof(id))), @encode(id));
    
    objc_property_attribute_t type = attributeWithType(dict[key], klass, key);
    objc_property_attribute_t attrs[] = {type};
    class_addProperty(klass, [key UTF8String], attrs, 1);
    
    // getter
    SEL getter = NSSelectorFromString(key);
    class_addMethod(klass, getter, imp_implementationWithBlock((id) ^(id this, SEL _cmd) {
      Ivar ivar = class_getInstanceVariable(klass, iVarName);
      return object_getIvar(this, ivar);
    }), "@@:");
    
    // setter
    SEL setter = setterForPath(key);
    class_addMethod(klass, setter, imp_implementationWithBlock(^(id this, id val) {
      Ivar ivar = class_getInstanceVariable(klass, iVarName);
      object_setIvar(this, ivar, val);
    }), "v@:@");
    
  }
  
  objc_registerClassPair(klass);
}

+ (RLMObject *)instanceWithClassNamed:(NSString *)name dictionary:(NSDictionary *)dict {
  Class klass = NSClassFromString(name);
  id obj = [[klass alloc] init];
  for (NSString *key in [dict allKeys]) {
    id value = dict[key];
    if ([value isKindOfClass:[NSArray class]]) {
      RLMArray *array = [obj valueForKey:key];
      RLMObjectSchema *schema = ((RLMObject *) obj).objectSchema;
      for (RLMProperty *property in schema.properties) {
        if ([property.name isEqualToString:key]) {
          NSString *typeName = property.objectClassName;
          for (NSDictionary *subDict in value) {
            id subObj = [self instanceWithClassNamed:typeName dictionary:subDict];
            [array addObject:subObj];
          }
          break;
        }
      }
      
    } else {
      [obj setValue:dict[key] forKey:key];
    }
  }
  
  return obj;
}

objc_property_attribute_t attributeWithType(NSString *type, Class klass, NSString *key) {
  
  NSArray *components = [type componentsSeparatedByString:@" "];
  
  if (components.count > 1 && [components[1] isEqualToString:@"primary"]) {
    Class metaClass = object_getClass(klass);
    class_addMethod(metaClass, @selector(primaryKey), imp_implementationWithBlock(^(id this) {
      return key;
    }), "@@:");
  }
  
  NSString *name = components[0];
  if ([name isEqualToString:@"string"]) {
    return (objc_property_attribute_t) {"T", "@\"NSString\""};
  } else if ([name isEqualToString:@"array"]) {
    NSString *className = components[1];
    makeProtocolNamed(className);
    NSString *value = [NSString stringWithFormat:@"@\"RLMArray<%@>\"", className];
    return (objc_property_attribute_t) {"T", [value UTF8String]};
  } else if ([name isEqualToString:@"int"]) {
    return (objc_property_attribute_t) {"T", "q"}; // long long
  } else if ([name isEqualToString:@"bool"]) {
    return (objc_property_attribute_t) {"T", "B"}; // BOOL
  } else if ([name isEqualToString:@"float"]) {
    return (objc_property_attribute_t) {"T", "f"}; // float
  }
  return (objc_property_attribute_t) {};
}

void makeProtocolNamed(NSString *name) {
  if (NSProtocolFromString(name)) {
    Protocol *proto = objc_allocateProtocol([name UTF8String]);
    objc_registerProtocol(proto);
  }
  
}

SEL setterForPath(NSString *path) {
  SEL setter = NSSelectorFromString([NSString stringWithFormat:@"set%@%@:", [[path substringToIndex:1] uppercaseString], [path substringFromIndex:1]]);
  return setter;
}

- (NSArray *)allPropertyNames {
  NSMutableArray *names = @[].mutableCopy;
  for (RLMProperty *property in self.objectSchema.properties) {
    [names addObject:property.name];
  }
  return names.copy;
}
@end
