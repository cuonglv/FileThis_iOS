//
//  MyCollectionFlowLayout.h
//  FileThis
//
//  Created by Cuong Le on 1/9/14.
//
//

#import "LeftAlignedCollectionViewFlowLayout.h"

@interface MyCollectionFlowLayout : LeftAlignedCollectionViewFlowLayout
@property (assign) float extendedHeight;
- (id)initWithExtendedHeight:(float)extHeight;
@end
