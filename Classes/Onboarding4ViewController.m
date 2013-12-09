//
//  Onboarding4ViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/15/13.
//
//

#import "Onboarding4ViewController.h"

@implementation Onboarding4ViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        float paddingLeft = [self.logoTextImageView left];
        
        self.bodyTextImageView.image = [UIImage imageNamed:@"Onboarding_text_4.png"];
        [self.bodyTextImageView moveToBottomOfView:self.logoTextImageView offset:self.view.frame.size.height * 0.07];
        [CommonLayout autoImageViewHeight:self.bodyTextImageView];
        
        self.contentImageView.frame = CGRectMake(paddingLeft,[self.bodyTextImageView bottom] + self.view.frame.size.height * 0.11, self.view.frame.size.width - paddingLeft * 2, self.view.frame.size.height * 0.2);
        self.contentImageView.image = [UIImage imageNamed:@"duck_logo_medium.png"];
    }
    return self;
}

@end
