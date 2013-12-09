//
//  DestinationConfirmationViewController.m
//  FileThis
//
//  Created by Drew Wilson on 2/26/13.
//
//

#import <Crashlytics/Crashlytics.h>
#import "FTDestination.h"
#import "FTSession.h"
#import "DestinationConfirmationViewController.h"
#import "AuthenticateDestinationViewController.h"
#import "Constants.h"   //Cuong

@interface DestinationConfirmationViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;

@property (strong) FTDestination *destination;

@property (strong) NSAttributedString *descriptionTemplate;

@end

@implementation DestinationConfirmationViewController

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
    self.descriptionTemplate = self.descriptionView.attributedText;
    NSLog(@"navitem title=%@, nc title=%@", self.navigationItem.title,
          self.navigationController.title);
    [self.navigationItem setHidesBackButton:self.firstTime animated:YES];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { //Cuong
        if (self.logoView.frame.origin.y < kIOS7ToolbarHeight + 10) {
            self.logoView.frame = CGRectMake(self.logoView.frame.origin.x, kIOS7ToolbarHeight + 10, self.logoView.frame.size.width, self.descriptionView.frame.origin.y - kIOS7ToolbarHeight - 20);
            [self.view layoutSubviews];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSString *)createStringForDestination:(NSString *)template {
    return [template stringByReplacingOccurrencesOfString:@"%@" withString:self.destination.name];
}

-(void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"DestinationConfirmationViewController viewWillAppear:");
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self setupForDestination];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"DestinationConfirmationViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

-(void)viewDidAppear:(BOOL)animated {
    if (self.alertUser) {
        NSString *m = NSLocalizedString(@"Before you can use FileThis Fetch you must log into your %@ account.", @"Before you can use FileThis Fetch you must log into your %@ account.");
        NSString *message = [NSString stringWithFormat:m, self.destination.name];
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FileThis" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)setupForDestination {
    if (self.destination && self.logoView) {
        [self.destination configureForImageView:self.logoView];
        self.navigationController.title = self.destination.name;

        // replace all instances of %@ with destination name
        NSMutableAttributedString *description = [self.descriptionTemplate mutableCopy];
        NSError *error;
        NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"%@" options:kNilOptions error:&error];
        NSString *descriptionString = [description string];
        
        NSArray *matches = [re matchesInString:descriptionString options:kNilOptions range:NSMakeRange(0, descriptionString.length)];
        [matches enumerateObjectsWithOptions:NSEnumerationReverse
                usingBlock:^(NSTextCheckingResult *result, NSUInteger idx, BOOL *stop) {
            NSRange r = [result rangeAtIndex:0];
            [description replaceCharactersInRange:r withString:self.destination.name];
                }];
        
        self.descriptionView.attributedText = description;
        [self.view setNeedsDisplay];
    }
}

- (void)checkDestinations:(id)sender {
    FTDestination *destination = [FTDestination destinationWithId:self.destinationId];
    if (destination != nil) {
        self.destination = destination;
        [self setupForDestination];
    } else {
        NSLog(@"no destination found for %d. Retrying after 1 second", self.destinationId);
        [self performSelector:@selector(checkDestinations:) withObject:nil afterDelay:1.0];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"authenticateDestination"]) {
        AuthenticateDestinationViewController *w = segue.destinationViewController;
        NSAssert(self.authenticationString != nil, @"nil auth string");
        w.authenticationString = self.authenticationString;
        w.firstTime = self.firstTime;
        [w.navigationController setNavigationBarHidden:self.firstTime animated:YES];
    }
}

- (void)setDestinationId:(NSInteger)destinationId {
    _destinationId = destinationId;
    [self checkDestinations:0];
}

- (IBAction)connect:(id)sender {
    [[FTSession sharedSession] getAuthenticationURLForDestination:self.destination.destinationId
          withSuccess:^(id JSON) {
              self.authenticationString = JSON[@"returnValue"];
              NSAssert(self.authenticationString, @"nil auth string");
              NSLog(@"authenticate using %@", self.authenticationString);
              [self performSegueWithIdentifier:@"authenticateDestination" sender:sender];
          } ];
}

@end
