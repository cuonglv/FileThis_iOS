//
//  ReferralCell_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 6/6/14.
//
//

#import "ReferralCell_iphone.h"
#import "CommonLayout.h"
#import "CommonFunc.h"
#import "FTSession.h"

@implementation ReferralCell_iphone

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        self.topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 300, 32)];
        
        self.topView.backgroundColor = [UIColor colorWithRedInt:225 greenInt:224 blueInt:229];
        [self.contentView addSubview:self.topView];
        
        self.lblReferralTitle = [CommonLayout createLabel:CGRectMake(10, 0, 120, self.topView.frame.size.height) fontSize:FontSizeXXSmall isBold:NO isItalic:NO textColor:kTextGrayColor backgroundColor:[UIColor clearColor] text:@"Referral" superView:self.topView];
        self.lblReferralTitle.textAlignment = NSTextAlignmentLeft;
        
        self.lblEmail = [CommonLayout createLabel:CGRectMake(80, 0, self.topView.frame.size.width - 80 - 10, self.topView.frame.size.height) fontSize:FontSizeXXSmall isBold:NO isItalic:YES textColor:kTextOrangeColor backgroundColor:[UIColor clearColor] text:@"" superView:self.topView];
        self.lblEmail.textAlignment = NSTextAlignmentRight;
        
        self.lblLine = [[UILabel alloc] initWithFrame:CGRectMake(0, [self.topView bottom] - 1, self.topView.frame.size.width, 1)];
        self.lblLine.backgroundColor = [UIColor colorWithRedInt:211 greenInt:211 blueInt:214];
        [self.topView addSubview:self.lblLine];
        
        self.lblExpireTitle = [CommonLayout createLabel:CGRectMake(10, [self.topView bottom] + 10, 100, 20) fontSize:FontSizeXXSmall isBold:NO isItalic:NO textColor:kTextGrayColor backgroundColor:[UIColor clearColor] text:@"Expires" superView:self.contentView];
        self.lblExpireTitle.textAlignment = NSTextAlignmentLeft;
        self.lblExpire = [CommonLayout createLabel:[self.lblExpireTitle rectAtBottom:0 height:20] fontSize:FontSizexXSmall isBold:NO isItalic:NO textColor:kTextGrayColor backgroundColor:[UIColor clearColor] text:@"" superView:self.contentView];
        self.lblExpire.textAlignment = NSTextAlignmentLeft;
        
        self.lblStorageTitle = [CommonLayout createLabel:[self.lblExpireTitle rectAtRight:0 width:90] fontSize:FontSizeXXSmall isBold:NO isItalic:NO textColor:kTextGrayColor backgroundColor:[UIColor clearColor] text:@"Storage" superView:self.contentView];
        self.lblStorageTitle.textAlignment = NSTextAlignmentLeft;
        self.lblStorage = [CommonLayout createLabel:[self.lblStorageTitle rectAtBottom:0 height:20] fontSize:FontSizexXSmall isBold:NO isItalic:NO textColor:kTextGrayColor backgroundColor:[UIColor clearColor] text:@"" superView:self.contentView];
        self.lblStorage.textAlignment = NSTextAlignmentLeft;
        
        self.lblConnectionTitle = [CommonLayout createLabel:[self.lblStorageTitle rectAtRight:0 width:90] fontSize:FontSizeXXSmall isBold:NO isItalic:NO textColor:kTextGrayColor backgroundColor:[UIColor clearColor] text:@"Connections" superView:self.contentView];
        self.lblConnectionTitle.textAlignment = NSTextAlignmentCenter;
        self.lblConnection = [CommonLayout createLabel:[self.lblConnectionTitle rectAtBottom:0 height:20] fontSize:FontSizexXSmall isBold:NO isItalic:NO textColor:kTextGrayColor backgroundColor:[UIColor clearColor] text:@"" superView:self.contentView];
        self.lblConnection.textAlignment = NSTextAlignmentCenter;
        
        /*self.lblStorage = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] text:@"" superView:self.contentView];
        self.lblStorage.textAlignment = NSTextAlignmentCenter;
        
        self.lblConnection = [CommonLayout createLabel:CGRectZero fontSize:FontSizeXSmall isBold:NO isItalic:NO textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] text:@"" superView:self.contentView];
        self.lblConnection.textAlignment = NSTextAlignmentCenter;*/
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
    self.lblExpire.text = [CommonFunc dateStringFromInterval:[obj.expires doubleValue] format:@"MM/dd/yyyy"];
    self.lblStorage.text = [CommonLayout storageTextFromKB:[obj.storageQuota longValue]/1000 decimalPlaces:1];
    self.lblConnection.text = [NSString stringWithFormat:@"%d", [obj.sourceConnectionQuota intValue]];
    
    FTDestinationConnection *dest = [FTSession sharedSession].currentDestination;
    if (dest.name && ([dest.name isEqualToString:@"FileThis Cloud"])) {
        self.lblStorage.hidden = NO;
    } else {
        self.lblStorage.hidden = YES;
    }
}

@end
