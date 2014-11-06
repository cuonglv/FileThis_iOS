//
//  CustomPageViewController.m
//  PageViewController
//
//  Created by Tom Fewster on 11/01/2012.
//

#import "CustomPagerViewController.h"
#import "FTSession.h"
#import "Onboarding1ViewController.h"
#import "Onboarding2ViewController.h"
#import "Onboarding3ViewController.h"
#import "CommonFunc.h"
#import "Constants.h"

@interface CustomPagerViewController ()

@end

@implementation CustomPagerViewController

- (void)viewWillAppear:(BOOL)animated {
    //[super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:NO];
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewDidLoad {
	// Do any additional setup after loading the view, typically from a nib. 
    [super viewDidLoad];
    
    [self setTitle:NSLocalizedString(@"ID_ABOUT_FILETHIS", @"")];
}

- (void)viewWillLayoutSubviews {
    [self relayout];
}

- (void)createChildViewControllers {
	[self addChildViewController:[[[CommonFunc idiomClassWithName:@"Onboarding1ViewController"] alloc] initWithNibName:nil bundle:nil]];
	[self addChildViewController:[[[CommonFunc idiomClassWithName:@"Onboarding2ViewController"] alloc] initWithNibName:nil bundle:nil]];
	[self addChildViewController:[[[CommonFunc idiomClassWithName:@"Onboarding3ViewController"] alloc] initWithNibName:nil bundle:nil]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (NSUInteger)supportedInterfaceOrientations
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return UIInterfaceOrientationMaskPortrait;
    
    return [super supportedInterfaceOrientations];
}

- (void)relayout {
    [super relayout];
}

- (IBAction)cancel:(UIStoryboardSegue *)segue {
    NSLog(@"cancelled %@ from %@ to %@", segue.identifier, segue.sourceViewController, segue.destinationViewController);
}

@end
