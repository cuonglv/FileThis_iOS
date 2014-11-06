//
//  DocumentSearchCriteriaManager
//  FileThis
//
//  Created by Cuong Le on 1/10/14.
//
//

#import <Foundation/Foundation.h>
#import "DocumentSearchCriteria.h"

#define kDocumentSearchCriteriaManager_MaxNumberOfRecentItems   15
#define kDocumentSearchCriteriaManager_MaxNumberOfRecentTexts   1000

@interface DocumentSearchCriteriaManager : NSObject

@property (nonatomic, strong) NSMutableArray *recentDocumentSearchCriteriaList;
@property (nonatomic, strong) NSMutableArray *recentDocumentSearchStringList;

+ (DocumentSearchCriteriaManager*)getInstance;
- (void)saveCriteria:(DocumentSearchCriteria*)criteria;
- (void)clearRecentList;

@end
