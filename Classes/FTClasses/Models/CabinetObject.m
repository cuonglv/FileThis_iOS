//
//  CabinetObject.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "CabinetObject.h"
#import "DocumentDataManager.h"

#define ORDER_NORMAL    10

@implementation CabinetObject

- (id)initWithCabinetId:(NSNumber *)cabinetId cabName:(NSString *)cabName {
    self = [super init];
    if (self) {
        self.name = cabName;
        self.id = cabinetId;
        self.docCount = [NSNumber numberWithInt:0];
        self.type = kCabinetNormalType;
        self.groupOrder = ORDER_NORMAL;
    }
    
    return self;
}

- (id)copy {
    CabinetObject *cabObj = [[CabinetObject alloc] init];
    cabObj.id = self.id;
    cabObj.name = self.name;
    cabObj.type = self.type;
    cabObj.canedit = self.canedit;
    cabObj.candelete = self.candelete;
    cabObj.computed =self.computed;
    return cabObj;
}

- (void)updateDocCount {
    @synchronized(self) {
        NSArray *allDocuments = [[DocumentDataManager getInstance] getAllObjects];
        int count = 0;
        for (DocumentObject *docObj in allDocuments) {
            if ([docObj.tags containsObject:self.id])
            count++;
        }
        self.docCount = [NSNumber numberWithInt:count];
    }
}

- (BOOL)isSpecialType {
    return ![self.type isEqualToString:@"basc"];
}

- (void)setType:(NSString *)aType {
    _type = aType;
    if ([_type isEqualToString:kCabinetAllType]) {
        _groupOrder = 1;
    }
    else if ([_type isEqualToString:kCabinetVitalRecordType]) {
        _groupOrder = 2;
    }
    
    else if ([_type isEqualToString:kCabinetUntaggedType]) {
        _groupOrder = 101;
    }
    else if ([_type isEqualToString:kCabinetUncategorizedType]) {
        _groupOrder = 102;
    }
    else if ([_type isEqualToString:kCabinetRecentlyAddedType]) {
        _groupOrder = 103;
    }
    else {
        _groupOrder = ORDER_NORMAL;
    }
}

@end
