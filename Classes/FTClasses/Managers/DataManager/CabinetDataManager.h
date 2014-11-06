//
//  CabinetDataManager.h
//  FileThis
//
//  Created by Manh nguyen on 12/16/13.
//
//

#import "BaseDataManager.h"
#import "CabinetObject.h"

@interface CabinetDataManager : BaseDataManager

+ (CabinetDataManager *)getInstance;
- (NSArray *)getAllCabinets;
- (NSArray*)getCabinetsForSearching;
- (BOOL)checkCabinetNameExisted:(NSString *)name;
- (CabinetObject *)addCabinet:(NSString *)cabName;
- (BOOL)removeCabinet:(CabinetObject*)cabinetObject;

@end
