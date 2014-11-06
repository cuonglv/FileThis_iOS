//
//  SortCriteriaObject.m
//  FileThis
//
//  Created by Manh nguyen on 1/10/14.
//
//

#import "SortCriteriaObject.h"

@implementation SortCriteriaObject

- (id)initWithSortBy:(SORTBY)by {
    self = [super init];
    if (self) {
        self.sortBy = by;
        
        switch (self.sortBy) {
            case Name_A_Z:
                self.sortName = NSLocalizedString(@"Name_A_Z", @"");
                break;
            case Name_Z_A:
                self.sortName = NSLocalizedString(@"Name_Z_A", @"");
                break;
            case RelevantDate_NewestFirst:
                self.sortName = NSLocalizedString(@"RelevantDate_NewestFirst", @"");
                break;
            case RelevantDate_OldestFirst:
                self.sortName = NSLocalizedString(@"RelevantDate_OldestFirst", @"");
                break;
            case DateCreated_NewestFirst:
                self.sortName = NSLocalizedString(@"DateCreated_NewestFirst", @"");
                break;
            case DateCreated_OldestFirst:
                self.sortName = NSLocalizedString(@"DateCreated_OldestFirst", @"");
                break;
            case DateAdded_NewestFirst:
                self.sortName = NSLocalizedString(@"DateAdded_NewestFirst", @"");
                break;
            case DateAdded_OldestFirst:
                self.sortName = NSLocalizedString(@"DateAdded_OldestFirst", @"");
                break;
            default:
                self.sortName = NSLocalizedString(@"Name_A_Z", @"");
                break;
        }
    }
    return self;
}

@end
