//
//  LabelCollectionReusableView.m
//  FileThis
//
//  Created by Cuong Le on 12/19/13.
//
//

#import "LabelCollectionReusableView.h"

@implementation LabelCollectionReusableView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.myLabel = [CommonLayout createLabel:self.bounds fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:kTextGrayColor backgroundColor:nil text:@"" superView:self];
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

@end
