//
//  AuthenticateDestinationViewController.m
//  FileThis
//
//  Created by Drew Wilson on 1/9/13.
//
//

#import <Crashlytics/Crashlytics.h>
#import "AuthenticateDestinationViewController.h"
#import "FTSession.h"


@interface AuthenticateDestinationViewController () <UIWebViewDelegate>
@property (weak, nonatomic) IBOutlet UIWebView *destinationProviderWebView;
@end

@implementation AuthenticateDestinationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
    NSURL *url = [NSURL URLWithString:self.authenticationString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.destinationProviderWebView loadRequest:request];
//    self.destinationProviderWebView.load
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"AuthenticateDestinationViewController viewWillAppear:");
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"AuthenticateDestinationViewController viewWillDisappear:");
    
    [[FTSession sharedSession] refreshCurrentDestination];  //Cuong
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIWebViewDelegate

- (NSString *)nameForUIWebViewNavigationType:(UIWebViewNavigationType)type
{
    switch (type) {
        case UIWebViewNavigationTypeLinkClicked:
            return @"UIWebViewNavigationTypeLinkClicked";
            break;
        case UIWebViewNavigationTypeFormSubmitted:
            return @"UIWebViewNavigationTypeFormSubmitted";
            break;
        case UIWebViewNavigationTypeBackForward:
            return @"UIWebViewNavigationTypeBackForward";
            break;
        case UIWebViewNavigationTypeReload:
            return @"UIWebViewNavigationTypeReload";
            break;
        case UIWebViewNavigationTypeFormResubmitted:
            return @"UIWebViewNavigationTypeFormResubmitted";
            break;
        case UIWebViewNavigationTypeOther:
            return @"UIWebViewNavigationTypeOther";
            break;
    }
}

- (BOOL)webView:(UIWebView *)webView
        shouldStartLoadWithRequest:(NSURLRequest *)request
        navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *host = request.URL.host;
    BOOL isFileThis = [host rangeOfString:@"filethis.com"].length != 0;
    
    NSLog(@"AuthenticateDestinationViewController request: %@", [request.URL description]);
    if (isFileThis) {
        // TODO: put up spinning progress indicator here...
        [[FTSession sharedSession] verifyDestinationAuthorization:request.URL
            withSuccess:^(NSInteger result) {
                if (result == 200) {
                    NSLog(@"authenticated destination %d", result);
                    //[[FTSession sharedSession] refreshCurrentDestination];  //Cuong
                    [self.navigationController popToRootViewControllerAnimated:YES];
                }
            }
            orFailure:^(NSURLRequest *req, NSHTTPURLResponse *response, NSError *error) {
                NSLog(@"oops! %@, - %@", error, response);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Couldn't verify the connected destination. Please try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }];
        
        return NO;
    }
    
    NSLog(@"navigating %@ %@", [self nameForUIWebViewNavigationType:navigationType], request);
    return  YES;
}

@end
