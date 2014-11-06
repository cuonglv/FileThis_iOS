//
//  MyCollectionFlowLayout.m
//  FileThis
//
//  Created by Cuong Le on 1/9/14.
//
//

#import "MyCollectionFlowLayout.h"

@implementation MyCollectionFlowLayout

- (id)initWithExtendedHeight:(float)extHeight {
    if (self = [super init]) {
        self.extendedHeight = extHeight;
    }
    return self;
}

- (CGSize)collectionViewContentSize {
    CGSize size = [super collectionViewContentSize];
    return CGSizeMake(size.width, size.height + self.extendedHeight);
}
@end
