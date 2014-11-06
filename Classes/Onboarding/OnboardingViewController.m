//
//  OnboardingViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/15/13.
//
//

#import "OnboardingViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "Constants.h"
#import "CommonLayout.h"

@implementation OnboardingViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        float paddingTop = self.view.frame.size.height * 0.12;
        
        self.logoTextImageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.view.center.x - 200, paddingTop, 400, 120)];
        self.logoTextImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.logoTextImageView.image = [UIImage imageNamed:@"FetchLogo_Text.png"];
        [CommonLayout autoImageViewHeight:self.logoTextImageView];
        [self.view addSubview:self.logoTextImageView];
        
        self.bodyTextView = [[UIView alloc] initWithFrame:[self.logoTextImageView rectAtBottom:self.view.frame.size.height * 0.05 width:self.view.frame.size.width height:100]];
        self.bodyTextView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.bodyTextView];
        [self.bodyTextView setBackgroundColor:kCabColorAll];
        
        self.lblText1 = [CommonLayout createLabel:CGRectMake(0, 17, self.bodyTextView.frame.size.width, 30) fontSize:24.0 isBold:NO textColor:kWhiteColor backgroundColor:nil text:@"" superView:self.bodyTextView];
        [self.lblText1 setTextAlignment:NSTextAlignmentCenter];
        
        self.lblText2 = [CommonLayout createLabel:[self.lblText1 rectAtBottom:5 height:30] fontSize:24.0 isBold:NO textColor:kWhiteColor backgroundColor:nil text:@"" superView:self.bodyTextView];
        [self.lblText2 setTextAlignment:NSTextAlignmentCenter];
        
        [self.view addSubview:self.bodyTextView];
        self.contentImageView = [[UIImageView alloc] initWithFrame:CGRectMake([self.bodyTextView left] + 20, [self.bodyTextView bottom] + 60, self.bodyTextView.frame.size.width - 40, self.view.frame.size.height * 0.30)];
        self.contentImageView.contentMode = UIViewContentModeScaleAspectFit;
        [self.view addSubview:self.contentImageView];
        
        [self relayout];
    }
    return self;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self relayout];
}

- (void)relayout
{
    //float paddingLeft = 0;
    NSLog(@"width = %lf, height = %lf", self.view.bounds.size.width, self.view.bounds.size.height);
    float paddingTop = self.view.frame.size.height * 0.12;
    
    CGRect rect = self.logoTextImageView.frame;
    rect.origin.x = (self.view.bounds.size.width - rect.size.width) / 2;
    rect.origin.y = paddingTop;
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation))
    {
        rect.origin.y -= 20;
    }
    self.logoTextImageView.frame = rect;
    
    [self.bodyTextView setFrame:CGRectMake(0, [self.logoTextImageView bottom] + 30, self.view.bounds.size.width, 100)];
    NSLog(@"self.width = %lf", self.bodyTextView.frame.size.width);
    [self.lblText1 setWidth:self.bodyTextView.frame.size.width];
    [self.lblText2 setWidth:self.bodyTextView.frame.size.width];
    
    int width = 728;
    int height = 288;
    rect = CGRectMake((self.view.frame.size.width - width)/2, [self.bodyTextView bottom] + 60, width, height);
    self.contentImageView.frame = rect;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self relayout];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self relayout];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
}

@end
