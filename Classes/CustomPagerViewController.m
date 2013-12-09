//
//  CustomPageViewController.m
//  PageViewController
//
//  Created by Tom Fewster on 11/01/2012.
//

#import "CustomPagerViewController.h"
#import "NewSignUpViewController.h"
#import "NewLoginViewController.h"
#import "FTSession.h"
#import "Onboarding1ViewController.h"
#import "Onboarding2ViewController.h"
#import "Onboarding3ViewController.h"
#import "Onboarding4ViewController.h"
#import "Constants.h"

@interface CustomPagerViewController ()

@end

@implementation CustomPagerViewController

- (void)viewDidLoad {
    float y;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        y = kIOS7CarrierbarHeight;
    } else
        y = 0;
    
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - 120 - y)];
    [self.view addSubview:self.scrollView];
    
	// Do any additional setup after loading the view, typically from a nib. 
    [super viewDidLoad];
    
}

- (void)createChildViewControllers {
	[self addChildViewController:[[Onboarding1ViewController alloc] initWithNibName:nil bundle:nil]];
	[self addChildViewController:[[Onboarding2ViewController alloc] initWithNibName:nil bundle:nil]];
	[self addChildViewController:[[Onboarding3ViewController alloc] initWithNibName:nil bundle:nil]];
	[self addChildViewController:[[Onboarding4ViewController alloc] initWithNibName:nil bundle:nil]];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
//    self.scrollView.frame = CGRectMake(0, 0, self.view.frame.size.width, 350);
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    self.scrollView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
//    self.scrollView.contentSize = CGSizeMake(self.scrollView.contentSize.width, self.scrollView.frame.size.height);
//    self.scrollView.contentOffset = CGPointMake(0, 0);
}

- (IBAction)login:(id)sender {
//    NSLog(@"Scrollview: %@, content size: (%.2f, %.2f), contentOffset: (%.2f, %.2f)", [self.scrollView description], self.scrollView.contentSize.width, self.scrollView.contentSize.height, self.scrollView.contentOffset.x, self.scrollView.contentOffset.y);
    [self performSegueWithIdentifier:@"login" sender:self];
}

- (IBAction)signUp:(id)sender {
    [NewLoginViewController setLastSignedUpEmail:nil];
    [NewLoginViewController setLastSignedUpPassword:nil];
    [self performSegueWithIdentifier:@"createNewAccount" sender:self];
}

- (IBAction)cancel:(UIStoryboardSegue *)segue {
    NSLog(@"cancelled %@ from %@ to %@", segue.identifier, segue.sourceViewController, segue.destinationViewController);
}

- (IBAction)accountCreated:(UIStoryboardSegue *)segue {
    NewSignUpViewController *signup = segue.sourceViewController;
    [NewLoginViewController setLastSignedUpEmail:signup.email];
    [NewLoginViewController setLastSignedUpPassword:signup.password];
    
//    NSString *serverName = [FTSession hostName];
//    // get last login credentials
//    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//    NSDictionary *userObject = [defaults objectForKey:serverName];
//    if (userObject) {
//        [userObject setValue:signup.email forKey:@"username"];
//        [userObject setValue:signup.password forKey:@"password"];
//    }
    [self performSelector:@selector(login:) withObject:nil afterDelay:0.5];
//    [self performSegueWithIdentifier:@"login" sender:self];
}

- (void)signUpCompletedWithEmail:(NSString*)email password:(NSString*)password {
    [self.navigationController popToRootViewControllerAnimated:NO];
    [NewLoginViewController setLastSignedUpEmail:email];
    [NewLoginViewController setLastSignedUpPassword:password];
    [self performSegueWithIdentifier:@"login" sender:self];
}

- (void)resetConnectionViewController {
    
}

@end
