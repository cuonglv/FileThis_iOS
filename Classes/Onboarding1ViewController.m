//
//  Onboarding1ViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/15/13.
//
//

#import "Onboarding1ViewController.h"

@implementation Onboarding1ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.bodyTextImageView.image = [UIImage imageNamed:@"Onboarding_text_1.png"];
        [CommonLayout autoImageViewHeight:self.bodyTextImageView];
        
        self.contentImageView.image = [UIImage imageNamed:@"Onboarding_logo_1.png"];
        [CommonLayout autoImageViewHeight:self.contentImageView];
    }
    return self;
}

@end