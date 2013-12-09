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
        self.bodyTextImageView.image = [UIImage imageNamed:@"Onboarding_text_3.png"];
        [CommonLayout autoImageViewHeight:self.bodyTextImageView];
    }
    return self;
}

@end
