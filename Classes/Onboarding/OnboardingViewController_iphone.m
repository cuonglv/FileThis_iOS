//
//  OnboardingViewController_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/19/14.
//
//

#import "OnboardingViewController_iphone.h"
#import <Crashlytics/Crashlytics.h>
#import "CommonLayout.h"
#import "CommonFunc.h"
#import "Constants.h"

@interface OnboardingViewController_iphone ()
@end

@implementation OnboardingViewController_iphone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.view.backgroundColor = [UIColor whiteColor];
        
        int yBanner = 119;
        CGSize size = CGSizeMake(225, 70);
        
        if (![CommonFunc isTallScreen])
        {
            yBanner = 90;
            size.width = 200;
            size.height = 60;
        }
        CGRect rect = CGRectMake((320-size.width)/2, (yBanner-size.height)/2, size.width, size.height);
        self.imgvwLogo = [[UIImageView alloc] initWithFrame:rect];
        self.imgvwLogo.image = [UIImage imageNamed:@"FetchLogo_Text.png"];
        [self.view addSubview:self.imgvwLogo];
        
        self.bannerView = [[UIView alloc] initWithFrame:CGRectMake(0, yBanner, 320, 95)];
        self.bannerView.backgroundColor = kBackgroundOrange;
        int marginLabel = 20;
        self.lblBanner = [CommonLayout createLabel:CGRectMake(marginLabel, 0, self.bannerView.frame.size.width - 2*marginLabel, self.bannerView.frame.size.height) fontSize:18.0 isBold:NO textColor:kWhiteColor backgroundColor:nil text:@"" superView:self.bannerView];
        [self.lblBanner setTextAlignment:NSTextAlignmentCenter];
        self.lblBanner.numberOfLines = 0;
        [self.view addSubview:self.bannerView];
        
        int padSpace = 15;
        if (![CommonFunc isTallScreen])
            padSpace = -5;
        rect = CGRectMake(0, [self.bannerView bottom] + padSpace, 320, 213);
        self.imgvwContent = [[UIImageView alloc] initWithFrame:rect];
        [self.view addSubview:self.imgvwContent];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
