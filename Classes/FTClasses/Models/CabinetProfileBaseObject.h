//
//  CabinetProfileBaseObject.h
//  FileThis
//
//  Created by Cuong Le on 3/3/14.
//
//

#import "NameBaseObject.h"

@interface CabinetProfileBaseObject : NameBaseObject
@property (nonatomic, strong) NSNumber *docCount;
- (BOOL)isSpecialType;
@end
