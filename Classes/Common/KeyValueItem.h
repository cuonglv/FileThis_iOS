//
//  KeyValueItem.h
//  TKD
//
//  Created by decuoi on 5/10/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface KeyValueItem : NSObject {
@private
    NSString *key, *value, *description;
    id data;
    BOOL deleted;
}
@property (nonatomic,retain) NSString *key, *value, *description;
@property (nonatomic,retain) id data;
@property (atomic,assign) BOOL deleted;

- (id)initWithKey:(NSString*)k value:(NSString*)v;
- (BOOL)isValueBefore:(KeyValueItem*)keyValueItem;
- (BOOL)isKeyBefore:(KeyValueItem*)keyValueItem;
- (int)insertIntoArraySortedByValue:(NSMutableArray*)keyValueItemArray ascending:(BOOL)ascending; //insert into an array of KeyValueItems, return position inserted
- (int)insertIntoArraySortedByKey:(NSMutableArray*)keyValueItemArray ascending:(BOOL)ascending; //insert into an array of KeyValueItems, return position inserted

+ (KeyValueItem*)itemWithKey:(NSString*)k inArray:(NSArray*)keyValueItemArray;
+ (KeyValueItem*)itemWithValue:(NSString*)v inArray:(NSArray*)keyValueItemArray;
+ (NSMutableArray*)itemsWithKeys:(NSArray*)keys inArray:(NSArray*)keyValueItemArray;
+ (NSMutableArray*)itemsWithoutKeys:(NSMutableArray*)keys inArray:(NSArray*)keyValueItemArray;
+ (int)indexOfItemWithKey:(NSString*)k inArray:(NSArray*)keyValueItemArray;

+ (NSMutableArray*)getKeysOfItems:(NSArray*)items;
+ (NSMutableArray*)getValuesOfItems:(NSArray*)items;

+ (NSString*)getValueByKey:(NSString*)k ofItems:(NSArray*)items;
+ (NSString*)getValuesStringByKeys:(NSArray*)keys ofItems:(NSArray*)items;
+ (NSString*)getValuesStringOfItems:(NSArray*)items;

+ (float)maxTextWidthForItems:(NSArray*)items font:(UIFont*)font;
@end
