//
//  Onboarding1ViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/15/13.
//
//

#import "Onboarding1ViewController.h"
#import "Constants.h"

@implementation Onboarding1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.lblText1.text = NSLocalizedString(@"ID_ONBOARD1_TEXT1", @"");
        self.lblText2.text = NSLocalizedString(@"ID_ONBOARD1_TEXT2", @"");
        
        self.contentImageView.image = [UIImage imageNamed:@"Onboarding_logo_1.png"];
        [CommonLayout autoImageViewHeight:self.contentImageView];
    }
    return self;
}

- (void)relayout {
    [super relayout];
}

@end
