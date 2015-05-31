//
//  PRealm.m
//

#import "PRealm.h"
#import <Realm/Realm.h>
#import <objc/runtime.h>
#import "PRealmObject.h"

@implementation PRealm
RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(registerScheme:(NSString *)name scheme:(NSDictionary *)dict) {
    [PRealmObject createClassNamed:name scheme:dict];
}

RCT_EXPORT_METHOD(setSchemaVersion:(NSUInteger)version) {
    [RLMRealm setSchemaVersion:version
                forRealmAtPath:[RLMRealm defaultRealmPath]
            withMigrationBlock:nil];
}

RCT_EXPORT_METHOD(add:(NSString *)name obj:(NSDictionary *)dict) {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        id obj = [PRealmObject instanceWithClassNamed:name dictionary:dict];
        [realm addObject:obj];
    }];
}

RCT_EXPORT_METHOD(update:(NSString *)name obj:(NSDictionary *)dict) {
    RLMRealm *realm = [RLMRealm defaultRealm];
    Class klass = NSClassFromString(name);
    if ([klass respondsToSelector:@selector(primaryKey)]) {
        NSString *primaryKey = [klass performSelector:@selector(primaryKey)];
        NSString *query = [NSString stringWithFormat:@"%@ == %@", primaryKey, dict[primaryKey]];
        RLMResults *results = [klass performSelector:@selector(objectsWhere:) withObject:query];
        RLMObject *obj = results[0];
        [realm transactionWithBlock:^{
            NSMutableDictionary *mutableDict = dict.mutableCopy;
            [mutableDict removeObjectForKey:primaryKey];
            [obj setValuesForKeysWithDictionary:mutableDict];

            [realm addOrUpdateObject:obj];
        }];
    } else {
        [self add:name obj:dict];
    }
}

RCT_EXPORT_METHOD(deleteAllObjects) {
    RLMRealm *realm = [RLMRealm defaultRealm];
    [realm transactionWithBlock:^{
        [realm deleteAllObjects];
    }];
}

RCT_EXPORT_METHOD(find:(NSString *)name callback:(RCTResponseSenderBlock)block) {
    Class klass = NSClassFromString(name);
    RLMResults *results = [klass performSelector:@selector(allObjects)];
    returnResults(results, block);
}

RCT_EXPORT_METHOD(find:(NSString *)name where:(NSString *)where callback:(RCTResponseSenderBlock)block) {
    Class klass = NSClassFromString(name);
    RLMResults *results = [klass performSelector:@selector(objectsWhere:) withObject:where];
    returnResults(results, block);
}

void returnResults(RLMResults *results, RCTResponseSenderBlock block) {
    NSMutableArray *array = @[].mutableCopy;
    for (PRealmObject *obj in results) {
        [array addObject:[obj dictionary]];
    }
    block(@[array]);
}
@end
