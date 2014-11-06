//
//  GetCabinetListService.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "CabinetService.h"
#import "CommonVar.h"
#import "NSString+Custom.h"

@implementation CabinetService

- (NSString *)serviceLink {
    if (self.action == kActionGetAllCabs) {
        return [NSString stringWithFormat:kUrlGetAllCabinetsLink, [CommonVar ticket]];
    } else if (self.action == kActionAddCabinet) {
        return [NSString stringWithFormat:kUrlAddCabinet, [self.cabinetName urlEncode], [CommonVar ticket]];
    } else if (self.action == kActionRemoveCabinet) {
        return [NSString stringWithFormat:kUrlRemoveCabinet, [self.cabinetId stringValue], [CommonVar ticket]];
    }
    
    return nil;
}

@end
