//
//  RLMObject+PRealm.h
//  PRealmDemo
//
//  Created by pompopo on 2015/06/09.
//  Copyright (c) 2015年 Facebook. All rights reserved.
//

#import <Realm/Realm.h>

@interface RLMObject (PRealm)
- (NSDictionary *)dictionary;

+ (void)createClassNamed:(NSString *)name scheme:(NSDictionary *)dict;
+ (RLMObject *)instanceWithClassNamed:(NSString *)name dictionary:(NSDictionary *)dict;
@end
