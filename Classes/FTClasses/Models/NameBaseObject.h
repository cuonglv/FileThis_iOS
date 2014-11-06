//
//  NameBaseObject.h
//  FileThis
//
//  Created by Cuong Le on 3/3/14.
//
//

#import "BaseObject.h"

@interface NameBaseObject : BaseObject

@property (nonatomic, copy) NSString *name;

- (int)insertIntoArraySortedByName:(NSMutableArray*)array;

@end
