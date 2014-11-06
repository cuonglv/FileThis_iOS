//
//  CabinetObject.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "CabinetProfileBaseObject.h"

@interface CabinetObject : CabinetProfileBaseObject

//{"id":-1001,"name":"All","type":"alll","canedit":false,"candelete":false,"computed":true
@property (nonatomic, copy) NSString *type, *canedit, *candelete, *computed;

@property int groupOrder; //Only used for sort on GUI
@property (nonatomic, assign) BOOL isAutoCalculateItemsInside;

- (id)initWithCabinetId:(NSNumber *)cabinetId cabName:(NSString *)cabName;
- (void)updateDocCount;

@end
