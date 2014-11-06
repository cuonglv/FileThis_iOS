//
//  SearchPdfTextView_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 3/4/14.
//
//

#import "SearchPdfTextView_iphone.h"

@implementation SearchPdfTextView_iphone

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.lblTitle.hidden = YES;
    }
    return self;
}

- (void)layoutSubviews {
    self.btnDone.frame = CGRectMake(self.frame.size.width - 80, 10, 80, 30);
    CGRect rect = self.txtKeyword.frame;
    self.txtKeyword.frame = CGRectMake(10, rect.origin.y, self.btnDone.frame.origin.x - 10, rect.size.height);
}

@end
