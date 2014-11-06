//
//  ReferralCell.m
//  FileThis
//
//  Created by Cao Huu Loc on 6/3/14.
//
//

#import "ReferralCell.h"
#import "CommonLayout.h"
#import "ReferralViewConstants.h"
#import "CommonFunc.h"
#import "FTSession.h"

@implementation ReferralCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        self.lblEmail = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:YES textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] text:@"" superView:self.contentView];
        self.lblEmail.textAlignment = NSTextAlignmentLeft;
        self.line1 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_vertical.png"]];
        [self.contentView addSubview:self.line1];
        
        self.lblExpire = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] text:@"" superView:self.contentView];
        self.lblExpire.textAlignment = NSTextAlignmentLeft;
        self.line2 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_vertical.png"]];
        [self.contentView addSubview:self.line2];
        
        self.lblStorage = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] text:@"" superView:self.contentView];
        self.lblStorage.textAlignment = NSTextAlignmentCenter;
        self.line3 = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"line_vertical.png"]];
        [self.contentView addSubview:self.line3];
        
        self.lblConnection = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] text:@"" superView:self.contentView];
        self.lblConnection.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)loadData:(ReferralObject*)obj {
    self.lblEmail.text = obj.refereeEmail;
    self.lblExpire.text = [CommonFunc dateStringFromInterval:[obj.expires doubleValue] format:@"EEE, MMM dd, yyyy"];
    self.lblStorage.text = [CommonLayout storageTextFromKB:[obj.storageQuota longValue]/1000 decimalPlaces:1];
    self.lblConnection.text = [NSString stringWithFormat:@"%d", [obj.sourceConnectionQuota intValue]];
    
    FTDestinationConnection *dest = [FTSession sharedSession].currentDestination;
    if (dest.name && ([dest.name isEqualToString:@"FileThis Cloud"])) {
        self.lblStorage.hidden = NO;
    } else {
        self.lblStorage.hidden = YES;
    }
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
