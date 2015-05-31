//
//  PRealmObject.h
//

#import <Foundation/Foundation.h>
#import <Realm/Realm.h>

@interface PRealmObject : RLMObject

- (NSDictionary *)dictionary;

+ (void)createClassNamed:(NSString *)name scheme:(NSDictionary *)dict;
+ (PRealmObject *)instanceWithClassNamed:(NSString *)name dictionary:(NSDictionary *)dict;
@end
