//
//  SubscriptionView.m
//  FileThis
//
//  Created by Cao Huu Loc on 6/2/14.
//
//

#import "SubscriptionView.h"
#import "CommonLayout.h"
#import "FTSession.h"

@implementation SubscriptionView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    self.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1].CGColor;
    self.layer.borderWidth = 1;
    
    self.lblPlanTitle.font = [CommonLayout getFont:FontSizeXSmall isBold:YES isItalic:NO];
    self.lblPlanText.font = [CommonLayout getFont:FontSizexSmall isBold:YES isItalic:NO];
    self.lblPlanText.textColor = kTextOrangeColor;
    
    self.lblStorageTitle.font = [CommonLayout getFont:FontSizexSmall isBold:NO isItalic:NO];
    self.lblStorageTitle.textColor = kTextOrangeColor;
    self.lblStorageText.font = [CommonLayout getFont:FontSizeMedium isBold:YES isItalic:NO];
    
    self.lblConnectionTitle.font = [CommonLayout getFont:FontSizexSmall isBold:NO isItalic:NO];
    self.lblConnectionTitle.textColor = kTextOrangeColor;
    self.lblConnectionText.font = [CommonLayout getFont:FontSizeMedium isBold:YES isItalic:NO];
    
    self.btnUpgrade.backgroundColor = kBackgroundOrange;
    [self.btnUpgrade setTitle:NSLocalizedString(@"ID_BTN_UPGRADE", @"") forState:UIControlStateNormal];
    [self.btnUpgrade setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btnUpgrade setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    self.btnUpgrade.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btnUpgrade.titleLabel.font = [CommonLayout getFont:FontSizeSmall isBold:YES];
}

- (void)layoutSubviews {
    [super layoutSubviews]; //Use layout mask
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.storageView.hidden) {
            [self.connectionView setTop:[self.topView bottom]];
        } else {
            [self.connectionView setTop:[self.storageView bottom]];
        }
        [self.upgradeView setTop:[self.connectionView bottom]];
        return;
    }
    
    //Customize layout
    int width = self.frame.size.width * 0.3;
    CGRect rect = CGRectMake(0, [self.topView bottom], width, self.frame.size.height - [self.topView bottom]);
    self.storageView.frame = rect;
    
    rect.origin.x += rect.size.width;
    self.connectionView.frame = rect;
    
    rect.origin.x += rect.size.width;
    rect.size.width = self.frame.size.width - rect.origin.x;
    self.upgradeView.frame = rect;
    
    [self.lblStorageText sizeToFit];
    [self.lblConnectionText sizeToFit];
    
    int x, top;
    top = 20;
    self.line1ImageView.frame = CGRectMake(self.storageView.frame.size.width - 2, top, 2, self.storageView.frame.size.height - top * 2);
    self.line2ImageView.frame = CGRectMake(self.connectionView.frame.size.width - 2, top, 2, self.connectionView.frame.size.height - top * 2);
    
    //Upgrate button
    top = (self.upgradeView.frame.size.height - self.btnUpgrade.frame.size.height) / 2;
    x = (self.upgradeView.frame.size.width - self.btnUpgrade.frame.size.width) / 2;
    [self.btnUpgrade setTop:top];
    [self.btnUpgrade setLeft:x];
    
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        //Storage View
        [self.storageImageView setTop:30];
        x = (self.storageView.frame.size.width - self.storageImageView.frame.size.width) / 2;
        [self.storageImageView setLeft:x];
        
        [self.lblStorageTitle setTop:[self.storageImageView bottom] + 4];
        x = (self.storageView.frame.size.width - self.lblStorageTitle.frame.size.width) / 2;
        [self.lblStorageTitle setLeft:x];
        
        [self.lblStorageText setTop:[self.lblStorageTitle bottom] + 4];
        x = (self.storageView.frame.size.width - self.lblStorageText.frame.size.width) / 2;
        [self.lblStorageText setLeft:x];
        
        //Connection View
        [self.connectionImageView setTop:[self.storageImageView top]];
        x = (self.connectionView.frame.size.width - self.connectionImageView.frame.size.width) / 2;
        [self.connectionImageView setLeft:x];
        
        [self.lblConnectionTitle setTop:[self.connectionImageView bottom] + 4];
        x = (self.connectionView.frame.size.width - self.lblConnectionTitle.frame.size.width) / 2;
        [self.lblConnectionTitle setLeft:x];
        
        [self.lblConnectionText setTop:[self.lblConnectionTitle bottom] + 4];
        x = (self.connectionView.frame.size.width - self.lblConnectionText.frame.size.width) / 2;
        [self.lblConnectionText setLeft:x];
    } else {
        int delta;
        //Storage View
        [self.storageImageView setTop:20];
        [self.storageImageView setLeft:55];

        [self.lblStorageTitle setTop:[self.storageImageView bottom] + 2];
        delta = (self.storageImageView.frame.size.width - self.lblStorageTitle.frame.size.width) / 2;
        x = [self.storageImageView left] + delta;
        [self.lblStorageTitle setLeft:x];
        
        top = (self.storageView.frame.size.height - self.lblStorageText.frame.size.height) / 2;
        width = self.storageView.frame.size.width - [self.storageImageView right];
        x = (width - self.lblStorageText.frame.size.width) / 2 + [self.storageImageView right];
        [self.lblStorageText setTop:top];
        [self.lblStorageText setLeft:x];
        
        //Connection View
        [self.connectionImageView setTop:[self.storageImageView top]];
        [self.connectionImageView setLeft:[self.storageImageView left]];
        
        [self.lblConnectionTitle setTop:[self.connectionImageView bottom] + 2];
        delta = (self.connectionImageView.frame.size.width - self.lblConnectionTitle.frame.size.width) / 2;
        x = [self.connectionImageView left] + delta;
        [self.lblConnectionTitle setLeft:x];
        
        top = (self.connectionView.frame.size.height - self.lblConnectionText.frame.size.height) / 2;
        width = self.connectionView.frame.size.width - [self.connectionImageView right];
        x = (width - self.lblConnectionText.frame.size.width) / 2 + [self.connectionImageView right];
        [self.lblConnectionText setTop:top];
        [self.lblConnectionText setLeft:x];
    }
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    _interfaceOrientation = interfaceOrientation;
    [self setNeedsLayout];
}

- (void)refreshGUI {
    BOOL isFTDestination = NO;
    FTDestinationConnection *dest = [FTSession sharedSession].currentDestination;
    if (dest.name && ([dest.name isEqualToString:@"FileThis Cloud"])) {
        isFTDestination = YES;
    }
    self.storageView.hidden = !isFTDestination;
    
    FTAccountSettings *settings = [FTSession sharedSession].settings;
    if (settings) {
        self.lblPlanText.text = [settings.localizedServicePlan uppercaseString];
        self.lblStorageText.text = [CommonLayout storageTextFromKB:settings.subscriptStorageQuota decimalPlaces:1];
        self.lblConnectionText.text = [NSString stringWithFormat:@"%d", settings.subscriptConnectionQuota];
        
        [self setNeedsLayout];
    }
}

@end
