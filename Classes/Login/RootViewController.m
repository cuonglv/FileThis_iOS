//
//  RootViewController.m
//  FileThis
//
//  Created by Drew Wilson on 11/14/12.
//
//

#import <Crashlytics/Crashlytics.h>
#import "RootViewController.h"

#import "ConnectionViewController.h"
#import "SignupViewController.h"

#import "CommonVar.h"
#import "Layout.h"

@interface RootViewController ()

@end

@implementation RootViewController

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
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
    //get app version TODO: use GCD
    NSDictionary *dictInfo = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Info" ofType:@"plist"]];
    NSString *sVersion = dictInfo[@"CFBundleShortVersionString"];
    NSString *versionString = [NSString stringWithFormat:@"v%@ (%@)", sVersion, dictInfo[@"CFBundleVersion"]];
    
    UILabel *label = [Layout labelWithFrame:CGRectZero text:versionString font:[UIFont systemFontOfSize:12] textColor:[UIColor blackColor] backColor:[UIColor clearColor]];
    [label sizeToFit];
    label.frame = [Layout CGRectMoveTo:label.frame newX:(self.view.frame.size.width - label.frame.size.width)/2 newY:self.view.frame.size.height - 30];
    [self.view addSubview:label];
    
    [CommonVar setAppVersion:sVersion];
}

- (void)viewWillAppear:(BOOL)animated {
    [self presentLogin];
    CLS_LOG(@"RootViewController viewWillAppear:");
    NSLog(@"%@ viewWillAppear", self);
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"RootViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

//- (void)viewDidAppear:(BOOL)animated
//{
//    [super viewDidAppear:animated];
////    [super presentLogin];
//}
//

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showSignup {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSelectorOnMainThread:@selector(presentSignup) withObject:nil waitUntilDone:NO];
//    [self presentSignup];
}

- (void)presentLogin {
//    UIViewController *vc = [[LoginController alloc] initWithNibName:@"LoginController" bundle:nil];
//    BOOL isPad = NO && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
//    CGRect bounds;
//    if(isPad) {
//        vc.view.autoresizesSubviews = NO;
//        vc.view.autoresizingMask = UIViewAutoresizingNone;
//        vc.definesPresentationContext = YES;
//        vc.providesPresentationContextTransitionStyle = YES;
//        vc.modalPresentationStyle = UIModalPresentationFormSheet;
//        bounds = vc.view.bounds;
//    }
//    vc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:vc animated:YES completion:nil];
//    if (isPad) {
//        NSLog(@"login view is %@, login's superview is %@", vc.view, vc.view.superview);
//        // ModalPresentationForm Sheet resizes nib. reset the super's bounds to match nib's bounds after presenting.
//        // http://stackoverflow.com/questions/2457947/how-to-resize-a-uipresentationformsheet/4271364#4271364
//        vc.view.superview.bounds = bounds;
//    }
}

- (void)presentSignup {
    UIViewController *vc = [[SignupViewController alloc] initWithNibName:@"SignupViewController" bundle:nil];
    vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)switchToLogin {
    [self dismissViewControllerAnimated:YES completion:nil];
    [self performSelector:@selector(presentLogin) withObject:nil afterDelay:1.0];
}

- (void)pushConnectionView {
    ConnectionViewController *vc = [[ConnectionViewController alloc] initWithNibName:nil bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:vc animated:YES];
}


@end
