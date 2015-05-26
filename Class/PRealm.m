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

RCT_EXPORT_METHOD(add:(NSString *)name obj:(NSDictionary *)dict) {
  RLMRealm *realm = [RLMRealm defaultRealm];
  [realm transactionWithBlock:^{
    id obj = [PRealmObject instanceWithClassNamed:name dictionary:dict];
    [realm addObject:obj];
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
