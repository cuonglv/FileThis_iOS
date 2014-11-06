//
//  BaseCollectionCell.m
//  FileThis
//
//  Created by Manh nguyen on 1/12/14.
//
//

#import "BaseCollectionCell.h"

@implementation BaseCollectionCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)updateCellWithObject:(NSObject *)obj {
    self.m_obj = obj;
}

@end
