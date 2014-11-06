//
//  ReferralTableHeaderView.m
//  FileThis
//
//  Created by Cao Huu Loc on 6/3/14.
//
//

#import "ReferralTableHeaderView.h"
#import "CommonLayout.h"
#import "ReferralViewConstants.h"

@implementation ReferralTableHeaderView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.lblEmail = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:kTextOrangeColor backgroundColor:[UIColor clearColor] text:NSLocalizedString(@"ID_REFERRALS", @"") superView:self];
        self.lblEmail.textAlignment = NSTextAlignmentLeft;
        self.line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_vertical.png"]];
        [self addSubview:self.line1];
        
        self.lblExpire = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:kTextOrangeColor backgroundColor:[UIColor clearColor] text:NSLocalizedString(@"ID_EXPIRES", @"") superView:self];
        self.lblExpire.textAlignment = NSTextAlignmentLeft;
        self.line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_vertical.png"]];
        [self addSubview:self.line2];
        
        self.lblStorage = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:kTextOrangeColor backgroundColor:[UIColor clearColor] text:NSLocalizedString(@"ID_STORAGE", @"") superView:self];
        self.lblStorage.textAlignment = NSTextAlignmentCenter;
        self.line3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_vertical.png"]];
        [self addSubview:self.line3];
        
        self.lblConnection = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:kTextOrangeColor backgroundColor:[UIColor clearColor] text:NSLocalizedString(@"ID_CONNECTIONS", @"") superView:self];
        self.lblConnection.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

#pragma mark - Layout
- (void)layoutSubviews {
    int height = self.bounds.size.height;
    int width1 = self.bounds.size.width * kRefTblColumn1Scale;
    int width2 = self.bounds.size.width * kRefTblColumn2Scale;
    int width3 = self.bounds.size.width * kRefTblColumn3Scale;
    int width4 = self.bounds.size.width - (width1 + width2 + width3);
    
    self.lblEmail.frame = CGRectMake(kRefTblTextMargin, 0, width1 - kRefTblTextMargin, height);
    self.line1.frame = CGRectMake([self.lblEmail right] - 2, 0, 2, height);
    
    self.lblExpire.frame = CGRectMake([self.lblEmail right] + kRefTblTextMargin, 0, width2 - kRefTblTextMargin, height);
    self.line2.frame = CGRectMake([self.lblExpire right] - 2, 0, 2, height);
    
    self.lblStorage.frame = CGRectMake([self.lblExpire right], 0, width3, height);
    self.line3.frame = CGRectMake([self.lblStorage right] - 2, 0, 2, height);
    
    self.lblConnection.frame = CGRectMake([self.lblStorage right], 0, width4, height);
}

@end
