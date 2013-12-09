//
//  OnboardingViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/15/13.
//
//

#import "OnboardingViewController.h"

@implementation OnboardingViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        float paddingLeft = self.view.frame.size.width * 0.08;
        float paddingTop = self.view.frame.size.height * 0.12;
        
        self.logoTextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(paddingLeft,paddingTop,self.view.frame.size.width-paddingLeft*2,self.view.frame.size.height*0.15)];
        //self.logoTextImageView.backgroundColor = [UIColor yellowColor];
        self.logoTextImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.logoTextImageView.image = [UIImage imageNamed:@"FetchLogo_Text.png"];
        [CommonLayout autoImageViewHeight:self.logoTextImageView];
        [self.view addSubview:self.logoTextImageView];
        
        self.bodyTextImageView = [[UIImageView alloc] initWithFrame:[self.logoTextImageView rectAtBottom:self.view.frame.size.height * 0.05 width:self.view.frame.size.width - paddingLeft * 2.5 height:self.view.frame.size.height*0.15]];
        //self.bodyTextImageView.backgroundColor = [UIColor yellowColor];
        self.bodyTextImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.bodyTextImageView];
        
        self.contentImageView = [[UIImageView alloc] initWithFrame:[self.bodyTextImageView rectAtBottom:self.view.frame.size.height * 0.1 width:self.view.frame.size.width - paddingLeft height:self.view.frame.size.height * 0.16]];
        //self.contentImageView.backgroundColor = [UIColor yellowColor];
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.contentImageView];
    }
    return self;
}

@end
