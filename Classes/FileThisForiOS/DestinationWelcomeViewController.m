//
//  DestinationWelcomeViewController.m
//  FileThis
//
//  Created by Cuong Le on 3/2/14.
//
//

#import "DestinationWelcomeViewController.h"
#import "DestinationViewController.h"
#import "FTMobileAppDelegate.h"
#import "DestinationViewController.h"
#import "FTSession.h"
#import "CommonFunc.h"

#define kMargin  (IS_IPHONE ? 20.0 : 50.0)

@interface DestinationWelcomeViewController ()
@property (nonatomic, strong) UILabel *welcomeLabel, *guideLabel1, *guideLabel2, *guideLabel3;
@property (nonatomic, strong) UIButton *useFileThisCloudDestinationButton, *changeDestinationButton;
@end

@implementation DestinationWelcomeViewController

- (BOOL)shouldUseBackButton {
    return NO;
}

- (void)initializeScreen {
    [super initializeScreen];
    BOOL isiPhone = IS_IPHONE;
    
    self.titleLabel.text = @"FileThis";
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    self.welcomeLabel = [CommonLayout createLabel:CGRectMake(kMargin, isiPhone ? 20 : 40, self.contentView.frame.size.width - 2 * kMargin, 40) fontSize:(isiPhone ? FontSizeMedium : FontSizexLarge) isBold:YES textColor:kBackgroundOrange backgroundColor:nil text:NSLocalizedString(@"ID_WELCOME_TO_FILETHIS", @"") superView:self.contentView];
    self.welcomeLabel.textAlignment = NSTextAlignmentCenter;
    
    self.guideLabel1 = [CommonLayout createLabel:[self.welcomeLabel rectAtBottom:(isiPhone ? 16 : 40) height:(isiPhone ? 50 : 60)] fontSize:(isiPhone ? FontSizexXSmall : FontSizeMedium) isBold:NO textColor:kTextGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_DESTINATION_WELCOME_GUIDE1", @"") superView:self.contentView];
    self.guideLabel1.numberOfLines = 2;
    self.guideLabel1.textAlignment = NSTextAlignmentCenter;
    
    self.guideLabel2 = [CommonLayout createLabel:[self.guideLabel1 rectAtBottom:(isiPhone ? 12 : 30) height:(isiPhone ? 60 : 80)] font:self.guideLabel1.font textColor:kTextGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_DESTINATION_WELCOME_GUIDE2", @"") superView:self.contentView];
    self.guideLabel2.numberOfLines = 3;
    self.guideLabel2.textAlignment = NSTextAlignmentCenter;
    
    float buttonWidth, buttonHeight, buttonIconHeight, buttonSpacing, offsetBetweenTextAndIcon;
    UIFont *buttonFont;
    if (isiPhone) {
        buttonWidth = 220;
        buttonHeight = 40;
        buttonIconHeight = 40;
        buttonSpacing = 10;
        offsetBetweenTextAndIcon = 8;
        buttonFont = [CommonLayout getFont:FontSizexSmall isBold:YES];
    } else {
        buttonWidth = 300;
        buttonHeight = 50;
        buttonIconHeight = 48;
        buttonSpacing = 20;
        offsetBetweenTextAndIcon = 12;
        buttonFont = [CommonLayout getFont:FontSizeMedium isBold:YES];
    }
    
    self.useFileThisCloudDestinationButton = [CommonLayout createTextImageButton:[self.guideLabel2 rectAtBottom:buttonSpacing width:buttonWidth height:buttonHeight] text:NSLocalizedString(@"ID_USE_FILETHIS_CLOUD", @"") font:buttonFont textColor:kBackgroundOrange icon:[UIImage imageNamed:@"destination_icon_orange.png"] iconSize:CGSizeMake(buttonIconHeight, buttonIconHeight) offsetBetweenTextAndIcon:offsetBetweenTextAndIcon iconLeftOffset:-2 backgroundImage:nil touchTarget:self touchSelector:@selector(handleUseFileThisCloudButton) superView:self.contentView];
    self.useFileThisCloudDestinationButton.backgroundColor = [UIColor colorWithRedInt:249 greenInt:248 blueInt:253];
    self.useFileThisCloudDestinationButton.layer.borderColor = [kBorderLightGrayColor CGColor];
    self.useFileThisCloudDestinationButton.layer.borderWidth = 1.0;
    self.useFileThisCloudDestinationButton.layer.cornerRadius = 1.0;
    
    self.guideLabel3 = [CommonLayout createLabel:[self.useFileThisCloudDestinationButton rectAtBottom:(isiPhone ? 30 : 70) width:self.guideLabel2.frame.size.width height:(isiPhone ? 85 : 105)] font:self.guideLabel1.font textColor:kTextGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_DESTINATION_WELCOME_GUIDE3", @"") superView:self.contentView];
    self.guideLabel3.numberOfLines = 4;
    self.guideLabel3.textAlignment = NSTextAlignmentCenter;
    
    self.changeDestinationButton = [CommonLayout createTextImageButton:[self.guideLabel3 rectAtBottom:buttonSpacing width:buttonWidth height:buttonHeight] text:NSLocalizedString(@"ID_CHANGE_DESTINATION", @"") font:buttonFont textColor:kBackgroundOrange icon:[UIImage imageNamed:@"destination_icon_orange.png"] iconSize:CGSizeMake(buttonIconHeight, buttonIconHeight) offsetBetweenTextAndIcon:offsetBetweenTextAndIcon iconLeftOffset:-2 backgroundImage:nil touchTarget:self touchSelector:@selector(handleChangeDestinationButton) superView:self.contentView];
    self.changeDestinationButton.backgroundColor = self.useFileThisCloudDestinationButton.backgroundColor;
    self.changeDestinationButton.layer.borderColor = self.useFileThisCloudDestinationButton.layer.borderColor;
    self.changeDestinationButton.layer.borderWidth = self.useFileThisCloudDestinationButton.layer.borderWidth;
    self.changeDestinationButton.layer.cornerRadius = self.useFileThisCloudDestinationButton.layer.cornerRadius;
}

- (void)relayout {
    [super relayout];
    float right = self.contentView.frame.size.width-kMargin;
    [self.welcomeLabel setRightWithoutChangingLeft:right];
    [self.guideLabel1 setRightWithoutChangingLeft:right];
    [self.guideLabel2 setRightWithoutChangingLeft:right];
    [self.useFileThisCloudDestinationButton moveToHorizontalCenterOfSuperView];
    [self.guideLabel3 setRightWithoutChangingLeft:right];
    [self.changeDestinationButton moveToHorizontalCenterOfSuperView];
}

- (void)handleUseFileThisCloudButton {
    for (FTDestination* dest in [FTSession sharedSession].destinations) {
        if ([dest.provider isEqualToString:@"this"] && [dest.type isEqualToString:@"host"]) {
            [[FTSession sharedSession] getAuthenticationURLForDestination:dest.destinationId withSuccess:^(id JSON) {
                [CommonLayout showInfoAlert:[NSString stringWithFormat:@"Connected successfully with %@ destination",dest.name] delegate:nil];
                [[FTSession sharedSession] refreshCurrentDestination];
                [CommonFunc selectMenu:MenuItemConnections animated:YES];
            } ];
        }
    }
}

- (void)handleChangeDestinationButton {
    DestinationViewController *target = [[DestinationViewController alloc] initWithNibName:nil bundle:nil];
    target.myDetailViewControllerDelegate = (FTMobileAppDelegate*)[UIApplication sharedApplication].delegate;
    [self.navigationController pushViewController:target animated:YES];
    self.navigationController.viewControllers = [NSArray arrayWithObjects:target,nil];
}
@end
