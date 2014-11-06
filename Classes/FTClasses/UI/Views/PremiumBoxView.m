//
//  PremiumBoxView.m
//  FileThis
//
//  Created by Manh nguyen on 1/21/14.
//
//

#import "PremiumBoxView.h"
#import "CommonLayout.h"
#import <QuartzCore/QuartzCore.h>
#import "FTMobileAppDelegate.h"

@implementation PremiumBoxView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self.layer setCornerRadius:5.0];
        [self.layer setBorderColor:kWhiteLightGrayColor.CGColor];
        [self.layer setBorderWidth:1.0];
        [self setBackgroundColor:[UIColor colorWithRed:249.0/255 green:249.0/255 blue:252.0/255 alpha:1.0]];
        
        // Initialization code
        self.lblTitle = [CommonLayout createLabel:CGRectMake(10, 10, frame.size.width - 20, 30) fontSize:kFontSizeNormal isBold:NO isItalic:YES textColor:kCabColorAll backgroundColor:nil text:NSLocalizedString(@"ID_PREMIUM_TITLE", @"") superView:self];
        [self.lblTitle setTextAlignment:NSTextAlignmentCenter];
        
        self.btnIcon = [CommonLayout createImageButton:CGRectMake(frame.size.width/2 - 43, [self.lblTitle bottom] + 5, 70, 68) fontSize:kFontSizeNormal isBold:NO textColor:kCabColorAll backgroundImage:[UIImage imageNamed:@"premium_icon.png"] text:@"" touchTarget:nil touchSelector:@selector(handlePremiumButton:) superView:self];
        
        self.lblPrice = [CommonLayout createLabel:CGRectMake(10, [self.btnIcon bottom] + 5, frame.size.width - 20, 30) fontSize:kFontSizeNormal isBold:NO isItalic:YES textColor:kCabColorAll backgroundColor:nil text:@"Just $4.99 per month" superView:self];
        [self.lblPrice setTextAlignment:NSTextAlignmentCenter];
        
        self.btnGo = [CommonLayout createImageButton:CGRectMake(frame.size.width/2 - 70, [self.lblPrice bottom] + 5, 121, 30) fontSize:kFontSizeNormal isBold:NO textColor:nil backgroundImage:[UIImage imageNamed:@"premium_button.png"] text:@"" touchTarget:self touchSelector:@selector(handlePremiumButton:) superView:self];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.lblPrice.hidden = YES;
            self.btnIcon.hidden = YES;
        }
    }
    
    return self;
}

- (void)resize {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self setHeight:70];
        [self.lblTitle setTop:0];
        [self.btnGo setTop:[self.lblTitle bottom]];
    }
}

#pragma mark - Button events
- (void)handlePremiumButton:(id)sender {
    FTMobileAppDelegate *app = (FTMobileAppDelegate*)[UIApplication sharedApplication].delegate;
    [app gotoPurchase];
}

@end
