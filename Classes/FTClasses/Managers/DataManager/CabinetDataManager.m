//
//  CabinetDataManager.m
//  FileThis
//
//  Created by Manh nguyen on 12/16/13.
//
//

#import "CabinetDataManager.h"
#import "CabinetService.h"
#import "CabinetObject.h"
#import "EventManager.h"
#import "CommonLayout.h"
#import "Utils.h"

@interface BaseDataManager ()
@property (nonatomic, strong) NSMutableArray *allObjects;
@property (nonatomic, strong) NSMutableDictionary *findObjectByIdDictionary;
@end

@implementation CabinetDataManager
static CabinetDataManager *instance = nil;

+ (CabinetDataManager *)getInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[CabinetDataManager alloc] init];
        }
    }
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        // TODO
    }
    return self;
}

- (NSArray *)getAllCabinets {
    if (self.allObjects != nil) {
        return [self getAllObjects];
    }
    
    [self reloadAll];
    return [self getAllObjects];
}

- (void)reloadAll {
    @synchronized(self) {
        CabinetService *service = [[CabinetService alloc] initWithAction:kActionGetAllCabs];
        NSError *error;
        id dataResponse = [service sendRequestToServer:&error];
        if (dataResponse) {
            self.allObjects = [self parseDataToObjects:dataResponse];
            
            //sort all cabinets by type "alll", "vitl", "rcnt", "ucat", "utag", "basc"
            CabinetObject *allCab = nil, *vitalCab = nil, *recentCab = nil, *unCategorizedCab = nil, *unTaggedCab = nil;
            for (CabinetObject *cab in self.allObjects) {
                if ([cab.type isEqualToString:@"alll"])
                    allCab = cab;
                else if ([cab.type isEqualToString:@"vitl"])
                    vitalCab = cab;
                else if ([cab.type isEqualToString:@"rcnt"])
                    recentCab = cab;
                else if ([cab.type isEqualToString:@"ucat"])
                    unCategorizedCab = cab;
                else if ([cab.type isEqualToString:@"utag"])
                    unTaggedCab = cab;
            }
            int index = 0;
            if (allCab) {
                allCab.isAutoCalculateItemsInside = YES;
                [self.allObjects removeObject:allCab];
                [self.allObjects insertObject:allCab atIndex:index];
                index++;
            }
            if (vitalCab) {
                [self.allObjects removeObject:vitalCab];
                [self.allObjects insertObject:vitalCab atIndex:index];
                index++;
            }
            if (recentCab) {
                recentCab.isAutoCalculateItemsInside = YES;
                [self.allObjects removeObject:recentCab];
                [self.allObjects insertObject:recentCab atIndex:index];
                index++;
            }
            if (unCategorizedCab) {
                [self.allObjects removeObject:unCategorizedCab];
                [self.allObjects insertObject:unCategorizedCab atIndex:index];
                index++;
            }
            if (unTaggedCab) {
                unTaggedCab.isAutoCalculateItemsInside = YES;
                [self.allObjects removeObject:unTaggedCab];
                [self.allObjects insertObject:unTaggedCab atIndex:index];
                index++;
            }
            [self updateFindObjectByIdDictionary];
            
        } else {
            /*dispatch_async(dispatch_get_main_queue(), ^{
             [CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_CANNOT_LOAD_CABINET_LIST", @"") errorMessage:[error localizedDescription] delegate:nil];
             });*/
        }
    }
}

- (NSArray*)getCabinetsForSearching {
    NSArray *allCabinets = [[CabinetDataManager getInstance] getAllCabinets];
    NSMutableArray *ret = [[NSMutableArray alloc] init];
    for (CabinetObject *cabObj in allCabinets) {
        if ([cabObj.type isEqualToString:@"alll"])   //Do not include "All" cabinet
            continue;
        
        if (cabObj.docCount == nil) //invalid docCount
            continue;
        
        if ([cabObj.docCount intValue] <= 0)    //do not display empty cabinet
            continue;
        
        [ret addObject:cabObj];
    }
    return [NSArray arrayWithArray:ret];
}

- (NSMutableArray *)parseDataToObjects:(id)dict {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        id account = [dict objectForKey:@"account"];
        if ([account isKindOfClass:[NSDictionary class]]) {
            id cabs = [account objectForKey:@"cabs"];
            for (id cabObj in cabs) {
                CabinetObject *cabinetObj = [[CabinetObject alloc] initWithDictionary:cabObj];
                [results addObject:cabinetObj];
            }
        }
    }
    
    return results;
}

- (BOOL)checkCabinetNameExisted:(NSString *)cabinetName {
    for (CabinetObject *cabObj in [self getAllObjects]) {
        if ([[cabObj.name lowercaseString] isEqualToString:[cabinetName lowercaseString]]) {
            return YES;
        }
    }
    
    return NO;
}

- (CabinetObject *)addCabinet:(NSString *)cabName {
    @synchronized(self) {
        CabinetService *service = [[CabinetService alloc] initWithAction:kActionAddCabinet];
        service.cabinetName = cabName;
        NSError *error = nil;
        id dataResponse = [service sendRequestToServer:&error];
        
        if (dataResponse) {
            CabinetObject *cabObj = [[CabinetObject alloc] initWithCabinetId:[NSNumber numberWithInt:[dataResponse intValue]] cabName:cabName];
            return cabObj;
        } else if (error) {
            if ([service.errorMessage length] > 0 && [service.errorMessage rangeOfString:@"Exception"].location != NSNotFound) {
                [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:service.errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
            } else {
                [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_CANNOT_ADD_CABINET", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
            }
        }
        return nil;
    }
}

- (BOOL)removeCabinet:(CabinetObject*)cabinetObject {
    @synchronized(self) {
        CabinetService *service = [[CabinetService alloc] initWithAction:kActionRemoveCabinet];
        service.cabinetId = cabinetObject.id;
        NSError *error = nil;
        [service sendRequestToServer:&error];
        if (service.responseStatusCode == 200) {
            // Post event to UI
            Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_REMOVE_CABINET];
            [event setContent:cabinetObject];
            [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
            
            [self.allObjects removeObject:cabinetObject];
            return YES;
        } else if (error) {
            if ([service.errorMessage length] > 0 && [service.errorMessage rangeOfString:@"Exception"].location != NSNotFound) {
                [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:service.errorMessage delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
            } else {
                [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_CANNOT_REMOVE_CABINET", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
            }
        }
        return NO;
    }
}

@end
