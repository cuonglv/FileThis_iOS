//
//  Onboarding3ViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/15/13.
//
//

#import "Onboarding3ViewController.h"

@implementation Onboarding3ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.lblText1.text = NSLocalizedString(@"ID_ONBOARD3_TEXT1", @"");
        self.lblText2.text = NSLocalizedString(@"ID_ONBOARD3_TEXT2", @"");
        
        self.contentImageView.frame = [self.bodyTextView rectAtBottom:self.view.frame.size.height * 0.1 width:self.view.frame.size.width height:330 ];
        self.contentImageView.image = [UIImage imageNamed:@"Onboarding_logo_3.png"];
        [self.contentImageView setLeft:[self.bodyTextView left] + 40];
    }
    return self;
}

- (void)relayout {
    [super relayout];
}

@end
