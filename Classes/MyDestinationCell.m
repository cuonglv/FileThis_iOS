//
//  MyDestinationCell.m
//  FileThis
//
//  Created by Cuong Le on 12/11/13.
//
//

#import "MyDestinationCell.h"
#import "CommonLayout.h"
#import "Constants.h"

@interface MyDestinationCell()
@property (nonatomic, strong) UILabel *errorLabel;
@property (nonatomic, strong) UIImageView *errorImageView;
@end

@implementation MyDestinationCell

- (id)initWithTable:(UITableView*)table reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        BOOL isiPhone = IS_IPHONE;
        
        self.myTable = table;
        float width = self.myTable.frame.size.width;
        float rowHeight = self.myTable.rowHeight;
        float offset =  roundf(width * 0.04);
        
        self.logoView = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 200, rowHeight - 20)];
        self.logoView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.logoView];
        
        self.myLabel = [CommonLayout createLabel:[self.logoView rectAtRight:offset width:width-40-offset-[self.logoView right]] fontSize:(isiPhone ? FontSizeSmall : FontSizeLarge) isBold:NO textColor:kTextGrayColor backgroundColor:nil text:@"" superView:self];
        self.myLabel.textAlignment = NSTextAlignmentLeft;
        //self.myLabel.adjustsFontSizeToFitWidth = YES;
        //self.myLabel.minimumScaleFactor = 0.2;
        self.myLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        
        self.rightImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width - 40, rowHeight/2 - 12, 24, 24)];
        self.rightImageView.image = [UIImage imageNamed:@"arrow right.png"];
        self.rightImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.rightImageView];
        
        float iconHeight = (isiPhone ? 24 : 40);
        
        self.errorImageView = [CommonLayout createImageView:[self.rightImageView rectAtLeft:(isiPhone ? 10 : 20) width:iconHeight height:iconHeight] image:[UIImage imageNamed:@"error_icon_red.png"] contentMode:UIViewContentModeScaleAspectFit superView:self];
        self.errorImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin;
        self.errorImageView.hidden = YES;
        
        self.errorLabel = [CommonLayout createLabel:[self.errorImageView rectAtBottom:0 width:400 height:18] font:[CommonLayout getFont:(isiPhone ? FontSizeTiny : FontSizeSmall) isBold:NO isItalic:YES] textColor:kTextOrangeColor backgroundColor:nil text:NSLocalizedString(@"ID_WAITING_FOR_YOUR_AUTHORIZATION", @"") superView:self];
        self.errorLabel.hidden = YES;
        [self.errorLabel autoWidth];
        
        self.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    return self;
}

- (void)configure:(FTDestination *)destination selected:(BOOL)selected authorizationError:(BOOL)authorizationError {
    BOOL isiPhone = IS_IPHONE;
    [destination configureForTextLabel:self.myLabel withImageView:self.logoView];
    self.errorLabel.hidden = self.errorImageView.hidden = YES;
    [self.myLabel setTop:self.myTable.rowHeight/2-self.myLabel.frame.size.height/2];
    [self.rightImageView setRight:self.myTable.frame.size.width-(isiPhone ? 6 : 16)];
    if (selected) {
        self.rightImageView.image = [UIImage imageNamed:@"checked_orange_small.png"];
        if (authorizationError) {
            [self.myLabel setTop:self.myTable.rowHeight/2-self.myLabel.frame.size.height/2-6];
            self.errorLabel.hidden = self.errorImageView.hidden = NO;
            
            [self.errorImageView moveToLeftOfView:self.rightImageView offset:(isiPhone ? 10 : 20)];
            [self.errorLabel moveToBottomOfView:self.errorImageView offset:0];
            if ([self.errorLabel right] > self.myTable.frame.size.width - 2) {
                [self.errorLabel setRight:self.myTable.frame.size.width-2];
            }
        }
    } else
        self.rightImageView.image = [UIImage imageNamed:@"arrow right.png"];
}
@end
