//
//  DocumentSearchCriteriaManager.m
//  FileThis
//
//  Created by Cuong Le on 1/10/14.
//
//

#import "DocumentSearchCriteriaManager.h"
#import "FTSession.h"
#import "NSArray+Ext.h"

#define kRecentDocumentSearchCriteriaListKey    @"FTRecentDocumentSearchCriteriaList"
#define kRecentDocumentSearchStringListKey      @"FTRecentDocumentSearchStringList"

@interface DocumentSearchCriteriaManager()
@end

@implementation DocumentSearchCriteriaManager

static DocumentSearchCriteriaManager *instance_ = nil;

- (id)init {
    if (self = [super init]) {
        NSString *serverName = [FTSession hostName];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dict = [userDefaults objectForKey:[NSString stringWithFormat:@"%@_latestlogininfo", serverName]];
        NSString *username = [dict objectForKey:@"username"];

        id criteriaList = [userDefaults objectForKey:[NSString stringWithFormat:@"%@_%@_%@",kRecentDocumentSearchCriteriaListKey,serverName,username]];
        NSMutableArray *rawDocumentSearchCriteriaList;
        if (criteriaList)
            rawDocumentSearchCriteriaList = [[NSMutableArray alloc] initWithArray:criteriaList];
        else
            rawDocumentSearchCriteriaList = [[NSMutableArray alloc] init];
        
        [self loadDataFromRawDocumentSearchCriteriaList:rawDocumentSearchCriteriaList];
        
        id stringList = [userDefaults objectForKey:[NSString stringWithFormat:@"%@_%@_%@",kRecentDocumentSearchStringListKey,serverName,username]];
        if (stringList)
            self.recentDocumentSearchStringList = [[NSMutableArray alloc] initWithArray:stringList];
        else
            self.recentDocumentSearchStringList = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (DocumentSearchCriteriaManager*)getInstance {
    @synchronized(self) {
        if (instance_ == nil)
            instance_ = [[DocumentSearchCriteriaManager alloc] init];
    }
    
    return instance_;
}

- (void)loadDataFromRawDocumentSearchCriteriaList:(NSArray*)rawDocumentSearchCriteriaList {
    self.recentDocumentSearchCriteriaList = [[NSMutableArray alloc] init];
    
    if (rawDocumentSearchCriteriaList) {
        NSMutableArray *validRawDocumentSearchCriteriaList = [[NSMutableArray alloc] init];
        for (NSArray *rawDocumentSearchCriteria in rawDocumentSearchCriteriaList) {
            if ([rawDocumentSearchCriteria count] != 5) //invalid
                continue;
            
            NSArray *rawDocumentSearchCriteriaDate = [rawDocumentSearchCriteria objectAtIndex:0];
            if ([rawDocumentSearchCriteriaDate count] != 6) //invalid
                continue;
            
            id rawTexts = [rawDocumentSearchCriteria objectAtIndex:1];
            if (![rawTexts isKindOfClass:[NSArray class]])  //invalid data
                continue;
            
            DocumentSearchCriteria *criteria = [[DocumentSearchCriteria alloc] init];
            int rawDocumentSearchCriteriaDateDay1 = [[rawDocumentSearchCriteriaDate objectAtIndex:0] intValue];
            int rawDocumentSearchCriteriaDateMonth1 = [[rawDocumentSearchCriteriaDate objectAtIndex:1] intValue];
            int rawDocumentSearchCriteriaDateYear1 = [[rawDocumentSearchCriteriaDate objectAtIndex:2] intValue];
            int rawDocumentSearchCriteriaDateDay2 = [[rawDocumentSearchCriteriaDate objectAtIndex:3] intValue];
            int rawDocumentSearchCriteriaDateMonth2 = [[rawDocumentSearchCriteriaDate objectAtIndex:4] intValue];
            int rawDocumentSearchCriteriaDateYear2 = [[rawDocumentSearchCriteriaDate objectAtIndex:5] intValue];
            
            if (rawDocumentSearchCriteriaDateYear1 > 0) {
                criteria.date1 = [[NSDateComponents alloc] init];
                criteria.date1.day = rawDocumentSearchCriteriaDateDay1;
                criteria.date1.month = rawDocumentSearchCriteriaDateMonth1;
                criteria.date1.year = rawDocumentSearchCriteriaDateYear1;
            }
            
            if (rawDocumentSearchCriteriaDateYear2 > 0) {
                criteria.date2 = [[NSDateComponents alloc] init];
                criteria.date2.day = rawDocumentSearchCriteriaDateDay2;
                criteria.date2.month = rawDocumentSearchCriteriaDateMonth2;
                criteria.date2.year = rawDocumentSearchCriteriaDateYear2;
            }
            
            [criteria.texts addObjectsFromArray:rawTexts];
            
            NSString *rawCabinetId = [rawDocumentSearchCriteria objectAtIndex:2];
            if ([rawCabinetId length] > 0)
                criteria.cabinetId = [NSNumber numberWithInt:[rawCabinetId intValue]];
            
            NSString *rawProfileId = [rawDocumentSearchCriteria objectAtIndex:3];
            if ([rawProfileId length] > 0)
                criteria.profileId = [NSNumber numberWithInt:[rawProfileId intValue]];
            
            id tagList = [rawDocumentSearchCriteria objectAtIndex:4];
            criteria.tagIds = [[NSMutableArray alloc] initWithArray:tagList];
            //NSLog(@"criteria.tagIds %@", [criteria.tagIds description]);
            
            [criteria updateCabinetAndTags];
            
            [self.recentDocumentSearchCriteriaList addObject:criteria];
            [validRawDocumentSearchCriteriaList addObject:rawDocumentSearchCriteria];
        }
        
        NSString *serverName = [FTSession hostName];
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSMutableDictionary *dict = [userDefaults objectForKey:[NSString stringWithFormat:@"%@_latestlogininfo", serverName]];
        NSString *username = [dict objectForKey:@"username"];
        [userDefaults setObject:validRawDocumentSearchCriteriaList forKey:[NSString stringWithFormat:@"%@_%@_%@",kRecentDocumentSearchCriteriaListKey,serverName,username]];
        [userDefaults synchronize];
    }
}

- (void)saveCriteria:(DocumentSearchCriteria*)criteria {
    //prepare to write
    [criteria updateCabinetAndTags];
    
    NSArray *searchCriteriaDate;    //contains 6 strings day, month and year
    if (criteria.date1) {
        searchCriteriaDate = [NSArray arrayWithObjects:[NSString stringWithFormat:@"%i",criteria.date1.day],[NSString stringWithFormat:@"%i",criteria.date1.month],[NSString stringWithFormat:@"%i",criteria.date1.year],[NSString stringWithFormat:@"%i",criteria.date2.day],[NSString stringWithFormat:@"%i",criteria.date2.month],[NSString stringWithFormat:@"%i",criteria.date2.year],nil];
    } else
        searchCriteriaDate = [NSArray arrayWithObjects:@"-1",@"-1",@"-1",@"-1",@"-1",@"-1",nil];
    
    NSString *searchCriteriaCabinetId;
    if (criteria.cabinetId)
        searchCriteriaCabinetId = [criteria.cabinetId stringValue];
    else
        searchCriteriaCabinetId = @"";
    
    NSString *searchCriteriaProfileId;
    if (criteria.profileId)
        searchCriteriaProfileId = [criteria.profileId stringValue];
    else
        searchCriteriaProfileId = @"";
    
    NSArray *searchCriteria = [NSArray arrayWithObjects:searchCriteriaDate,criteria.texts,searchCriteriaCabinetId,searchCriteriaProfileId,criteria.tagIds,nil];
    
    //write file
    NSString *serverName = [FTSession hostName];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [userDefaults objectForKey:[NSString stringWithFormat:@"%@_latestlogininfo", serverName]];
    NSString *username = [dict objectForKey:@"username"];
    id criteriaList = [userDefaults objectForKey:[NSString stringWithFormat:@"%@_%@_%@",kRecentDocumentSearchCriteriaListKey,serverName,username]];
    NSMutableArray *rawDocumentSearchCriteriaList;
    if (criteriaList)
        rawDocumentSearchCriteriaList = [[NSMutableArray alloc] initWithArray:criteriaList];
    else
        rawDocumentSearchCriteriaList = [[NSMutableArray alloc] init];
    
    [self loadDataFromRawDocumentSearchCriteriaList:rawDocumentSearchCriteriaList];
    
    for (int i = [self.recentDocumentSearchCriteriaList count] - 1; i >= 0; i--) {
        DocumentSearchCriteria *c = [self.recentDocumentSearchCriteriaList objectAtIndex:i];
        if ([c isEqualToCriteria:criteria]) {
            [self.recentDocumentSearchCriteriaList removeObjectAtIndex:i];
            [rawDocumentSearchCriteriaList removeObjectAtIndex:i];
        }
    }
    
    [rawDocumentSearchCriteriaList insertObject:searchCriteria atIndex:0];
    [self.recentDocumentSearchCriteriaList insertObject:criteria atIndex:0];
    if ([rawDocumentSearchCriteriaList count] > kDocumentSearchCriteriaManager_MaxNumberOfRecentItems) {
        [rawDocumentSearchCriteriaList removeLastObject];
        [self.recentDocumentSearchCriteriaList removeLastObject];
    }
    [userDefaults setObject:rawDocumentSearchCriteriaList forKey:[NSString stringWithFormat:@"%@_%@_%@",kRecentDocumentSearchCriteriaListKey,serverName,username]];
    
    //write text if there is
    if ([criteria.texts count] > 0) {
        id stringList = [userDefaults objectForKey:[NSString stringWithFormat:@"%@_%@_%@",kRecentDocumentSearchStringListKey,serverName,username]];
        if (stringList)
            self.recentDocumentSearchStringList = [[NSMutableArray alloc] initWithArray:stringList];
        else
            self.recentDocumentSearchStringList = [[NSMutableArray alloc] init];
        
        //insert into array, sort asc
        for (NSString *text in criteria.texts) {
            if (![self.recentDocumentSearchStringList containsObject:text]) {
                [self.recentDocumentSearchStringList addObject:text];
                if ([self.recentDocumentSearchStringList count] > kDocumentSearchCriteriaManager_MaxNumberOfRecentTexts)
                    [self.recentDocumentSearchStringList removeObjectAtIndex:0];
            }
        }
        [userDefaults setObject:self.recentDocumentSearchStringList forKey:[NSString stringWithFormat:@"%@_%@_%@",kRecentDocumentSearchStringListKey,serverName,username]];
    }
    
    [userDefaults synchronize];
}

- (void)clearRecentList {
    NSString *serverName = [FTSession hostName];
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *dict = [userDefaults objectForKey:[NSString stringWithFormat:@"%@_latestlogininfo", serverName]];
    NSString *username = [dict objectForKey:@"username"];
    [userDefaults setObject:[NSMutableArray array] forKey:[NSString stringWithFormat:@"%@_%@_%@",kRecentDocumentSearchCriteriaListKey,serverName,username]];
    [userDefaults synchronize];
    self.recentDocumentSearchCriteriaList = [NSMutableArray array];
}
@end
