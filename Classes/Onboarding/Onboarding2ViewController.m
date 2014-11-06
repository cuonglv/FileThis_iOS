//
//  Onboarding2ViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/15/13.
//
//

#import "Onboarding2ViewController.h"

@implementation Onboarding2ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.lblText1.text = NSLocalizedString(@"ID_ONBOARD2_TEXT1", @"");
        self.lblText2.text = NSLocalizedString(@"ID_ONBOARD2_TEXT2", @"");
        
        self.contentImageView.image = [UIImage imageNamed:@"Onboarding_logo_2.png"];
        [CommonLayout autoImageViewHeight:self.contentImageView];
    }
    return self;
}

- (void)relayout {
    [super relayout];
}

@end
