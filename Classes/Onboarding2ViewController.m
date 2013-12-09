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
        self.bodyTextImageView.image = [UIImage imageNamed:@"Onboarding_text_2.png"];
        [CommonLayout autoImageViewHeight:self.bodyTextImageView];
        
        float paddingLeft = [self.logoTextImageView left];
        self.contentImageView.frame = [self.bodyTextImageView rectAtBottom:self.view.frame.size.height * 0.1 width:self.view.frame.size.width - paddingLeft * 2 height:self.view.frame.size.height * 0.22];
        self.contentImageView.image = [UIImage imageNamed:@"Onboarding_logo_2.png"];
    }
    return self;
}

@end
