//
//  GetCabinetListService.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "BaseService.h"

#define kUrlGetAllCabinetsLink  @"compact=true&json=true&op=cablist&ticket=%@"
#define kUrlAddCabinet      @"compact=true&json=true&op=addcab&name=%@&ticket=%@"
#define kUrlRemoveCabinet   @"op=removecab&json=true&ids=%@&ticket=%@"

// Cabinet Actions
#define kActionGetAllCabs   0
#define kActionAddCabinet   1
#define kActionRemoveCabinet   2

@interface CabinetService : BaseService

@property (nonatomic, copy) NSString *cabinetName;
@property (nonatomic, copy) NSNumber *cabinetId;

@end
