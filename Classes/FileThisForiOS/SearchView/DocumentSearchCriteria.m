//
//  DocumentSearchCriteria.m
//  FileThis
//
//  Created by Cuong Le on 1/10/14.
//
//

#import "DocumentSearchCriteria.h"
#import "DateHandler.h"
#import "CabinetDataManager.h"
#import "ProfileDataManager.h"
#import "TagDataManager.h"
#import "DocumentDataManager.h"
#import "NSArray+Ext.h"
#import "CommonDataManager.h"
#import "DocumentCabinetObject.h"

@interface DocumentSearchCriteria()
@property (nonatomic, strong) NSMutableArray *filteredDocObjsByDateCabProf;
@end

#pragma mark -

@implementation DocumentSearchCriteria

- (id)init {
    if (self = [super init]) {
        self.tagIds = [[NSMutableArray alloc] init];
        self.tags = [[NSMutableArray alloc] init];
        self.texts = [[NSMutableArray alloc] init];
    }
    return self;
}

#pragma mark - MyFunc
- (BOOL)isEqualToCriteria:(DocumentSearchCriteria*)criteria {
    if ([DateHandler compareDateComponents:self.date1 andDateComponents:criteria.date1] != NSOrderedSame)
        return NO;
    
    if ([DateHandler compareDateComponents:self.date2 andDateComponents:criteria.date2] != NSOrderedSame)
        return NO;
    
    if (![self.texts isSameAsArray:criteria.texts])
        return NO;
    
    if (self.cabinetId || criteria.cabinetId)
        if (![self.cabinetId isEqual:criteria.cabinetId])
            return NO;
    
    if (self.profileId || criteria.profileId)
        if (![self.profileId isEqual:criteria.profileId])
            return NO;
    
    if (![self.tagIds isSameAsArray:criteria.tagIds])
        return NO;
    
    return YES;
}

- (void)updateCabinetAndTags {
    self.cabinet = [BaseObject objectWithKey:self.cabinetId inArray:[[CabinetDataManager getInstance] getAllCabinets]];
    self.profile = [BaseObject objectWithKey:self.profileId inArray:[[ProfileDataManager getInstance] getAllProfiles]];
    self.tags = [BaseObject objectsWithKeys:self.tagIds inArray:[[TagDataManager getInstance] getAllTags]];
}

- (BOOL)isEmpty {
    if (self.date1)
        return NO;
    
    if (self.date2)
        return NO;
    
    if ([self.texts count] > 0)
        return NO;
    
    if (self.cabinet)
        return NO;
    
    if (self.profile)
        return NO;
    
    if ([self.tags count] > 0)
        return NO;
    
    return YES;
}

- (id)copy {
    DocumentSearchCriteria *ret = [[DocumentSearchCriteria alloc] init];
    ret.date1 = [self.date1 copy];
    ret.date2 = [self.date2 copy];
    ret.texts = [[NSMutableArray alloc] initWithArray:self.texts copyItems:YES];
    ret.cabinetId = [self.cabinetId copy];
    ret.profileId = [self.profileId copy];
    ret.tagIds = [self.tagIds copy];
    ret.cabinet = self.cabinet;
    ret.profile = self.profile;
    ret.tags = [[NSMutableArray alloc] init];
    for (id tag in self.tags) {
        [ret.tags addObject:tag];
    }
    return ret;
}

- (void)updateRelatedDocumentsAndTags {
    self.tagIds = [BaseObject keysOfObjects:self.tags];
    self.relatedDocuments = [[NSMutableArray alloc] init];
    self.relatedUnselectedTags = [[NSMutableArray alloc] init];
    if ([self.tags count] > 0) {
        NSArray *allDocuments, *allTags;
        if (self.filteredDocObjsByDateCabProf) {
            allDocuments = [[NSArray alloc] initWithArray:self.filteredDocObjsByDateCabProf];
            NSArray *tagIds = [self.filteredTagIdsAndDocCountsByDateCabProf allKeys];
            allTags = [BaseObject objectsWithKeys:tagIds inArray:[[TagDataManager getInstance] getAllTags]];
        } else {
            allDocuments = [[NSArray alloc] initWithArray:[[DocumentDataManager getInstance] getAllDocuments]];
            allTags = [[NSArray alloc] initWithArray:[[TagDataManager getInstance] getAllTags]];
        }
        
        for (DocumentObject *docObj in allDocuments) {
            if ([docObj matchesTagIds:self.tagIds]) {
                [self.relatedDocuments addObject:docObj];
                NSArray *tagsOfDocument = [BaseObject objectsWithKeys:docObj.tags inArray:allTags];
                for (TagObject *tagOfDocument in tagsOfDocument) {
                    if (![self.tags containsObject:tagOfDocument]) {
                        if ([self.relatedUnselectedTags containsObject:tagOfDocument]) {
                            tagOfDocument.relatedDocCount++;
                            //NSLog(@"-- updateRelatedDocumentsAndTags %@ %i", tagOfDocument.name, tagOfDocument.relatedDocCount);
                        } else {
                            tagOfDocument.relatedDocCount = 1;
                            [self.relatedUnselectedTags addObject:tagOfDocument];
                        }
                    }
                }
            }
        }
    }
}

- (void)removeInvalidData {
    if (self.cabinet) {
        if (![[[CabinetDataManager getInstance] getAllCabinets] containsObject:self.cabinet]) {
            self.cabinet = nil;
            self.cabinetId = nil;
        }
    } else if (self.profile) {
        if (![[[ProfileDataManager getInstance] getAllProfiles] containsObject:self.profile]) {
            self.profile = nil;
            self.profileId = nil;
        }
    }
    
    NSArray *allTags = [[NSArray alloc] initWithArray:[[TagDataManager getInstance] getAllTags]];
    for (int i = [self.tags count]-1; i >= 0; i--) {
        TagObject *tagObj = [self.tags objectAtIndex:i];
        if (![allTags containsObject:tagObj]) {
            if ([self.tagIds containsObject:tagObj.id])
                [self.tagIds removeObject:tagObj.id];
            
            [self.tags removeObject:tagObj];
        }
    }
}

- (void)updateFilteredCabProfIdsAndDocCountsByDate {
    if (self.date1 == nil) {
        self.filteredCabIdsAndDocCountsByDate = nil;
        self.filteredProfIdsAndDocCountsByDate = nil;
        return;
    }
    
    NSMutableArray *docs = [[NSMutableArray alloc] init];
    [docs addObjectsFromArray:[[DocumentDataManager getInstance] getAllObjects]];
    
    NSDateComponents *fromDate = [self fromDate];
    NSDateComponents *toDate = [self toDate];
    
    for (int i = [docs count] - 1; i >= 0; i--) {
        DocumentObject *docObj = [docs objectAtIndex:i];
        NSDate *relevantDate = [NSDate dateWithTimeIntervalSince1970:[docObj.relevantDate longLongValue]];
        NSDateComponents *relevantDateComps = [DateHandler dateComponentsFromDate:relevantDate];
        if (![DateHandler isDateComponents:relevantDateComps betweenDateComponents:fromDate andDateComponents:toDate]) {
            [docs removeObjectAtIndex:i];
        }
    }
    
    NSArray *allDocumentCabinetObjects = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentCabinets]];
    NSArray *allDocumentProfileObjects = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentProfiles]];
    
    self.filteredCabIdsAndDocCountsByDate = [[NSMutableDictionary alloc] init];
    self.filteredProfIdsAndDocCountsByDate = [[NSMutableDictionary alloc] init];
    for (DocumentObject *docObj in docs) {
        for (DocumentCabinetObject *docCabObj in allDocumentCabinetObjects) {
            if ([docCabObj.arrDocuments containsObject:docObj]) {
                NSNumber *cabId = docCabObj.cabinetObj.id;
                NSNumber *docCount = [self.filteredCabIdsAndDocCountsByDate objectForKey:cabId];
                if (docCount)
                    docCount = [NSNumber numberWithInt:[docCount intValue]+1];
                else {
                    docCount = [NSNumber numberWithInt:1];
                    //NSLog(@"-- updateFilteredCabIdsAndDocCountsByDate found cabinet %i",[cabId intValue]);
                }
                [self.filteredCabIdsAndDocCountsByDate setObject:docCount forKey:cabId];
            }
        }
        for (DocumentProfileObject *docProfObj in allDocumentProfileObjects) {
            if ([docProfObj.arrDocuments containsObject:docObj]) {
                NSNumber *profId = docProfObj.profileObj.id;
                NSNumber *docCount = [self.filteredProfIdsAndDocCountsByDate objectForKey:profId];
                if (docCount)
                    docCount = [NSNumber numberWithInt:[docCount intValue]+1];
                else {
                    docCount = [NSNumber numberWithInt:1];
                }
                [self.filteredProfIdsAndDocCountsByDate setObject:docCount forKey:profId];
            }
        }
    }
}

- (void)updateFilteredDocObjsByDateCabProf {
    if (self.date1 == nil && self.cabinet == nil && self.profile == nil) {
        self.filteredDocObjsByDateCabProf = nil;
        self.filteredTagIdsAndDocCountsByDateCabProf = nil;
        return;
    }
    
    self.filteredDocObjsByDateCabProf = [[NSMutableArray alloc] init];
    if (self.cabinet) {
        DocumentCabinetObject *docCabObj = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabId:self.cabinet.id];
        [self.filteredDocObjsByDateCabProf addObjectsFromArray:docCabObj.arrDocuments];
    } else if (self.profile) {
        DocumentProfileObject *docProObj = [[CommonDataManager getInstance] getDocumentProfileObjectByProfileId:self.profile.id];
        [self.filteredDocObjsByDateCabProf addObjectsFromArray:docProObj.arrDocuments];
    } else {
        NSArray *allDocs = [[DocumentDataManager getInstance] getAllObjects];
        [self.filteredDocObjsByDateCabProf addObjectsFromArray:allDocs];
    }
    
    if (self.date1) {
        NSDateComponents *fromDate = [self fromDate];
        NSDateComponents *toDate = [self toDate];
        
        for (int i = [self.filteredDocObjsByDateCabProf count] - 1; i >= 0; i--) {
            DocumentObject *docObj = [self.filteredDocObjsByDateCabProf objectAtIndex:i];
            NSDate *relevantDate = [NSDate dateWithTimeIntervalSince1970:[docObj.relevantDate longLongValue]];
            NSDateComponents *relevantDateComps = [DateHandler dateComponentsFromDate:relevantDate];
            if (![DateHandler isDateComponents:relevantDateComps betweenDateComponents:fromDate andDateComponents:toDate]) {
                [self.filteredDocObjsByDateCabProf removeObjectAtIndex:i];
            }
        }
    }
    
    self.filteredTagIdsAndDocCountsByDateCabProf = [[NSMutableDictionary alloc] init];
    for (DocumentObject *docObj in self.filteredDocObjsByDateCabProf) {
        for (NSNumber *tagId in docObj.tags) {
            NSNumber *docCount = [self.filteredTagIdsAndDocCountsByDateCabProf objectForKey:tagId];
            if (docCount)
                docCount = [NSNumber numberWithInt:[docCount intValue]+1];
            else
                docCount = [NSNumber numberWithInt:1];
            
            [self.filteredTagIdsAndDocCountsByDateCabProf setObject:docCount forKey:tagId];
        }
    }
}

- (NSDateComponents*)fromDate {
    if (self.date1) {
        NSDateComponents *fromDate = [self.date1 copy];
        if (fromDate.month <= 0)
            fromDate.month = 1;
        if (fromDate.day <=0)
            fromDate.day = 1;
        return fromDate;
    }
    return nil;
}

- (NSDateComponents*)toDate {
    if (self.date2) {
        NSDateComponents *toDate = [self.date2 copy];
        if (toDate.month <= 0)
            toDate.month = 12;
        if (toDate.day <=0)
            toDate.day = [DateHandler getNumberOfDaysInMonth:toDate.month year:toDate.year];
        return toDate;
    }
    return nil;
}

- (NSMutableArray*)getFilteredDocObjsByDateCabProf {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if (self.filteredDocObjsByDateCabProf)
        [array addObjectsFromArray:self.filteredDocObjsByDateCabProf];
    else
        [array addObjectsFromArray:[[DocumentDataManager getInstance] getAllObjects]];
    
    return array;
}
@end
