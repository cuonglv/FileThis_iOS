//
//  LoginViewController_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/12/14.
//
//

#import "LoginViewController_iphone.h"
#import "CommonFunc.h"

#define KEYBOARD_PORTRAIT_HEIGHT    216

@interface LoginViewController_iphone ()
@property (nonatomic, strong) MyScrollView *scrollView;
@end

@implementation LoginViewController_iphone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.automaticallyAdjustsScrollViewInsets = NO; //Loc Cao
    
    CGRect rect = self.view.bounds;
    self.bgPage.image = [UIImage imageNamed:@"bg_common_iphone.png"];
    self.bgPage.frame = rect;
    
    CGSize size = CGSizeMake(282, 357);
    int y = 0;
    self.centerView.frame = CGRectMake(self.view.frame.size.width - size.width, y, size.width, size.height);
    
    MyScrollView *v = [[MyScrollView alloc] initWithFrame:self.view.bounds];
    for (UIView *sub in self.view.subviews)
    {
        [v addSubview:sub];
    }
    v.backgroundColor = [UIColor colorWithRed:236/255.0 green:87/255.0 blue:18/255.0 alpha:1];
    [self.view addSubview:v];
    v.touchDelegate = self;
    self.scrollView = v;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeScreen {
    [super initializeScreen];
    [self.centerView setupViewForIdiom:UIUserInterfaceIdiomPhone];
}

#pragma mark - MyScrollViewTouchEvent
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event sender:(id)sender
{
    [self.centerView cancelInputingText];
}

#pragma mark - Layout
- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)relayout_device {
    CGRect rect = self.centerView.frame;
    rect.origin.x = self.view.bounds.size.width/2 - rect.size.width/2;
    rect.origin.y = self.view.bounds.size.height/2 - rect.size.height/2;
    self.centerView.frame = rect;
    
#ifdef DEBUG
    rect = self.serverNameLabel.frame;
    rect.origin.x = (self.view.frame.size.width - rect.size.width) / 2.0;
    rect.origin.y = self.view.frame.size.height - rect.size.height - 10;
    self.serverNameLabel.frame = rect;
#endif

    BOOL showingKeyboard = [self.centerView isInputingText];
    [self layoutCenterSideView:showingKeyboard];
}

- (void)layoutCenterSideView:(BOOL)isShowKeyboard
{
    if (isShowKeyboard)
    {
        self.scrollView.frame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height - KEYBOARD_PORTRAIT_HEIGHT);
    }
    else
    {
        self.scrollView.frame = self.view.bounds;
    }
    self.scrollView.contentSize = self.view.bounds.size;
    
    if (isShowKeyboard)
    {
        [self.scrollView setContentOffset:CGPointMake(0, 110) animated:YES];
    }
}

@end
