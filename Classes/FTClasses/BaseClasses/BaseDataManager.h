//
//  BaseDataManager.h
//  FileThis
//
//  Created by Manh nguyen on 12/16/13.
//
//

#import "BaseObject.h"

@interface BaseDataManager : BaseObject

- (BOOL)hasData;
- (NSArray*)getAllObjects;
- (NSUInteger)countObjects;
- (NSMutableArray *)parseDataToObjects:(id)dict;
- (void)clearAll;
- (void)reloadAll;
- (void)addObject:(id)object;
- (void)removeObject:(id)object;

- (id)getObjectByKey:(id)key;
- (void)updateFindObjectByIdDictionary;

@end
