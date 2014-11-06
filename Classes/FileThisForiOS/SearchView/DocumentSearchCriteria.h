//
//  DocumentSearchCriteria.h
//  FileThis
//
//  Created by Cuong Le on 1/10/14.
//
//

#import <Foundation/Foundation.h>
#import "CabinetObject.h"
#import "ProfileObject.h"

@interface DocumentSearchCriteria : NSObject

@property (nonatomic, strong) NSDateComponents *date1, *date2;
@property (nonatomic, strong) NSMutableArray *texts;
@property (nonatomic, strong) NSNumber *cabinetId, *profileId;
@property (nonatomic, strong) NSMutableArray *tagIds;

@property (nonatomic, strong) CabinetObject *cabinet;   //according to cabinetId
@property (nonatomic, strong) ProfileObject *profile;   //according to cabinetId
@property (nonatomic, strong) NSMutableArray *tags; //according to tagIds

//derrived info (need calculation)
@property (nonatomic, strong) NSMutableArray *relatedDocuments;
@property (nonatomic, strong) NSMutableArray *relatedUnselectedTags;

@property (nonatomic, strong) NSMutableDictionary *filteredTagIdsAndDocCountsByDateCabProf, *filteredCabIdsAndDocCountsByDate, *filteredProfIdsAndDocCountsByDate;

#pragma mark - MyFunc
- (BOOL)isEqualToCriteria:(DocumentSearchCriteria*)criteria;
- (void)updateCabinetAndTags;
- (BOOL)isEmpty;
- (void)updateRelatedDocumentsAndTags;
- (void)removeInvalidData;
- (void)updateFilteredCabProfIdsAndDocCountsByDate;
- (void)updateFilteredDocObjsByDateCabProf;
- (NSDateComponents*)fromDate;
- (NSDateComponents*)toDate;
- (NSMutableArray*)getFilteredDocObjsByDateCabProf;
@end
