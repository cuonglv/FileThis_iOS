//
//  BaseObject.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UILabel+Style.h"
#import "UIView+ExtLayout.h"
#import "Constants.h"
#import "Enums.h"

@interface BaseObject : NSObject

@property (nonatomic, strong) NSNumber *id;

- (id)initWithDictionary:(NSDictionary *)dict;
- (NSArray *)allPropertyNames;

+ (id)objectWithKey:(NSNumber *)key inArray:(NSArray*)array;
+ (NSMutableArray*)objectsWithKeys:(NSArray*)keys inArray:(NSArray*)array;
+ (NSMutableArray*)keysOfObjects:(NSArray*)objects;
@end
