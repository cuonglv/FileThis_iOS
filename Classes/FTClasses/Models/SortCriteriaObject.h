//
//  SortCriteriaObject.h
//  FileThis
//
//  Created by Manh nguyen on 1/10/14.
//
//

#import "BaseObject.h"

typedef enum SORTBY {
    Name_A_Z,
    Name_Z_A,
    RelevantDate_NewestFirst,
    RelevantDate_OldestFirst,
    DateCreated_NewestFirst,
    DateCreated_OldestFirst,
    DateAdded_NewestFirst,
    DateAdded_OldestFirst
} SORTBY;

@interface SortCriteriaObject : BaseObject

@property (nonatomic, copy) NSString *sortName;
@property (nonatomic, assign) SORTBY    sortBy;

- (id)initWithSortBy:(SORTBY)by;

@end
