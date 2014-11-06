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
#import "CommonLayout.h"
#import "CommonFunc.h"
#import "NSString+Base64.h"

#define kAlertViewTag_InvalidEmail      1
#define kAlertViewTag_InvalidPassword   2
#define kAlertViewTag_PasswordNotMatch  3

@interface DestinationConfirmationViewController () <UITextFieldDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *captionLabel;
@property (weak, nonatomic) IBOutlet UITextView *descriptionView;
@property (strong) FTDestination *destination;
@property (strong) NSAttributedString *descriptionTemplate;

//Cuong
@property (nonatomic, strong) IBOutlet UIScrollView *containerScrollView;
@property (nonatomic, strong) UIView *inputCredentialsView;
@property (nonatomic, strong) UITextField *emailTextField, *passwordTextField, *retypePasswordTextField;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *rightBarButtonItem;
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
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
    //Modify font
    self.captionLabel.font = [CommonLayout getFontWithSize:14 isBold:NO];
    self.descriptionView.font = [CommonLayout getFontWithSize:14 isBold:NO];
    
	// Do any additional setup after loading the view.
    self.descriptionTemplate = self.descriptionView.attributedText;
    NSLog(@"navitem title=%@, nc title=%@", self.navigationItem.title,
          self.navigationController.title);
    [self.navigationItem setHidesBackButton:self.firstTime animated:YES];
    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { //Cuong
//        if (self.logoView.frame.origin.y < kIOS7ToolbarHeight + 10) {
//            self.logoView.frame = CGRectMake(self.logoView.frame.origin.x, kIOS7ToolbarHeight + 10, self.logoView.frame.size.width, self.descriptionView.frame.origin.y - kIOS7ToolbarHeight - 20);
//            [self.view layoutSubviews];
//        }
//    }
//    self.logoView.backgroundColor = [UIColor yellowColor];
    
    
    //Cuong code:
    float inputCredentialsViewWidth;
    UIFont *font;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        inputCredentialsViewWidth = self.logoView.frame.size.width - 30;
        font = [CommonLayout getFont:FontSizeXSmall isBold:NO];
    } else {
        inputCredentialsViewWidth = 450;
        font = [CommonLayout getFont:FontSizeMedium isBold:NO];
    }
    self.inputCredentialsView = [[UIView alloc] initWithFrame:[self.logoView rectAtBottom:5 width:inputCredentialsViewWidth height:self.view.frame.size.height - [self.logoView bottom]-10]];
    [self.containerScrollView addSubview:self.inputCredentialsView];
//    self.inputCredentialsView.backgroundColor = [UIColor yellowColor];
    self.inputCredentialsView.hidden = YES;
    self.inputCredentialsView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin;
    
    
    UIColor *textColor = [UIColor grayColor];
    UILabel *label = [CommonLayout createLabel:CGRectMake(10,0,self.inputCredentialsView.frame.size.width-20,30) font:font textColor:textColor backgroundColor:nil text:@"Please enter your login credentials:" superView:self.inputCredentialsView];
    
//    label = [CommonLayout createLabel:CGRectMake(10,[label bottom]+10,110,30) font:font textColor:textColor backgroundColor:nil text:@"Email" superView:self.inputCredentialsView];
    
    UIImageView *imv = [[UIImageView alloc] initWithFrame:[label rectAtBottom:10 width:self.inputCredentialsView.frame.size.width-10 height:40]];
    imv.image = [UIImage imageNamed:@"box_gray.png"];
    imv.contentMode = UIViewContentModeScaleToFill;
    [self.inputCredentialsView addSubview:imv];
    
    self.emailTextField = [CommonLayout createTextField:CGRectMake(imv.frame.origin.x + 10, imv.frame.origin.y+2, imv.frame.size.width-12, imv.frame.size.height-4) font:label.font textColor:textColor backgroundColor:[UIColor whiteColor] text:@"" superView:self.inputCredentialsView];
    self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
    self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.emailTextField.returnKeyType = UIReturnKeyNext;
    self.emailTextField.placeholder = @"Email";
    self.emailTextField.borderStyle = UITextBorderStyleNone;
    self.emailTextField.delegate = self;
    
//    label = [CommonLayout createLabel:[label rectAtBottom:10 height:30] font:font textColor:textColor backgroundColor:nil text:@"Password" superView:self.inputCredentialsView];
    imv = [[UIImageView alloc] initWithFrame:[imv rectAtBottom:8 width:self.inputCredentialsView.frame.size.width-10 height:40]];
    imv.image = [UIImage imageNamed:@"box_gray.png"];
    imv.contentMode = UIViewContentModeScaleToFill;
    [self.inputCredentialsView addSubview:imv];
    
    self.passwordTextField = [CommonLayout createTextField:CGRectMake(imv.frame.origin.x + 10, imv.frame.origin.y+2, imv.frame.size.width-12, imv.frame.size.height-4) font:label.font textColor:textColor backgroundColor:[UIColor whiteColor] text:@"" superView:self.inputCredentialsView];
    self.passwordTextField.secureTextEntry = YES;
    self.passwordTextField.returnKeyType = UIReturnKeyNext;
    self.passwordTextField.placeholder = @"Password";
    self.passwordTextField.borderStyle = UITextBorderStyleNone;
    self.passwordTextField.delegate = self;
    
//    label = [CommonLayout createLabel:[label rectAtBottom:10 height:30] font:font textColor:textColor backgroundColor:nil text:@"Re-enter password" superView:self.inputCredentialsView];
//    label.adjustsFontSizeToFitWidth = YES;
//    label.minimumScaleFactor = 0.2;
    
    imv = [[UIImageView alloc] initWithFrame:[imv rectAtBottom:8 width:self.inputCredentialsView.frame.size.width-10 height:40]];
    imv.image = [UIImage imageNamed:@"box_gray.png"];
    imv.contentMode = UIViewContentModeScaleToFill;
    [self.inputCredentialsView addSubview:imv];
    
    self.retypePasswordTextField = [CommonLayout createTextField:CGRectMake(imv.frame.origin.x + 10, imv.frame.origin.y+2, imv.frame.size.width-12, imv.frame.size.height-4) font:label.font textColor:textColor backgroundColor:[UIColor whiteColor] text:@"" superView:self.inputCredentialsView];
    self.retypePasswordTextField.secureTextEntry = YES;
    self.retypePasswordTextField.returnKeyType = UIReturnKeyDone;
    self.retypePasswordTextField.placeholder = @"Re-enter password";
    self.retypePasswordTextField.borderStyle = UITextBorderStyleNone;
    self.retypePasswordTextField.delegate = self;
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

        if ([self.destination.provider isEqualToString:@"aone"]) { //Cuong: AboutOne
            float inputCredentialsViewWidth;
            if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                inputCredentialsViewWidth = self.logoView.frame.size.width - 30;
            } else {
                inputCredentialsViewWidth = 500;
            }
            self.inputCredentialsView.frame = [self.logoView rectAtBottom:5 width:inputCredentialsViewWidth height:self.view.frame.size.height-[self.logoView bottom]-10];
            self.containerScrollView.contentSize = CGSizeMake(self.containerScrollView.frame.size.width, [self.inputCredentialsView bottom] + 350);
            self.inputCredentialsView.hidden = NO;
            self.descriptionView.hidden = YES;
            
            UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStylePlain target:self action:@selector(authorizeCredentials)];
            [self.navigationItem setRightBarButtonItem:barButtonItem];
            self.containerScrollView.scrollEnabled = YES;
        } else {
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
            self.containerScrollView.scrollEnabled = NO;
        }
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
              if ([self.destination.provider isEqualToString:@"this"]) {
                  [CommonLayout showInfoAlert:[NSString stringWithFormat:@"Connected successfully with %@ destination",self.destination.name] delegate:nil];
                  [[FTSession sharedSession] refreshCurrentDestination];
                  [self.navigationController popToRootViewControllerAnimated:YES];
              } else {
                  self.authenticationString = JSON[@"returnValue"];
                  NSAssert(self.authenticationString, @"nil auth string");
                  NSLog(@"authenticate using %@", self.authenticationString);
                  [self performSegueWithIdentifier:@"authenticateDestination" sender:sender];
              }
          } ];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField)
        [self.passwordTextField becomeFirstResponder];
    else if (textField == self.passwordTextField)
        [self.retypePasswordTextField becomeFirstResponder];
    else if (textField == self.retypePasswordTextField)
        [self authorizeCredentials];
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    if (textField == self.emailTextField) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            self.containerScrollView.contentOffset = CGPointMake(0, [self.inputCredentialsView top] - (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?100:70));
    } else if (textField == self.passwordTextField) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            self.containerScrollView.contentOffset = CGPointMake(0, [self.inputCredentialsView top] - (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?80:45));
    } else if (textField == self.retypePasswordTextField) {
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            self.containerScrollView.contentOffset = CGPointMake(0, [self.inputCredentialsView top] - (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")?60:20));
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertViewTag_InvalidEmail) {
        [self.emailTextField becomeFirstResponder];
    } else if (alertView.tag == kAlertViewTag_InvalidPassword) {
        [self.passwordTextField becomeFirstResponder];
    } else if (alertView.tag == kAlertViewTag_PasswordNotMatch) {
        [self.retypePasswordTextField becomeFirstResponder];
    }
}

- (void)authorizeCredentials {
    NSString *username = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![CommonFunc validateEmail:username]) {
        [CommonLayout showWarningAlert:@"Invalid email" errorMessage:nil tag:kAlertViewTag_InvalidEmail delegate:self];
        return;
    }
    
    NSString *password = self.passwordTextField.text;
    NSString *passwordAgain = self.retypePasswordTextField.text;
    
    if ([password length] == 0) {
        [CommonLayout showWarningAlert:@"Invalid password" errorMessage:nil tag:kAlertViewTag_InvalidPassword delegate:self];
        return;
    }
    
    if (![password isEqualToString:passwordAgain]) {
        [CommonLayout showWarningAlert:@"Passwords don’t match." errorMessage:nil tag:kAlertViewTag_PasswordNotMatch delegate:self];
        return;
    }
    
    //send request
    NSString *encryptedUsername = [username base64String]; //[[username dataUsingEncoding:NSASCIIStringEncoding] base64EncodedString];
    NSString *encryptedPassword = [password base64String]; //[[password dataUsingEncoding:NSASCIIStringEncoding] base64EncodedString];
    
    [[FTSession sharedSession] connectToDestination:self.destination.destinationId username:encryptedUsername password:encryptedPassword withSuccess:^(id JSON) {
        NSString *returnValue = JSON[@"returnValue"];
        if ([[returnValue lowercaseString] isEqualToString:@"valid"]) {
            //OK
            //NSLog(@"authenticated destination %d", result);
            [[FTSession sharedSession] refreshCurrentDestination];
            [self.navigationController popToRootViewControllerAnimated:YES];
            
        } else {
            [CommonLayout showWarningAlert:@"Invalid credentials" errorMessage:nil delegate:nil];
        }
    } ];
}
@end
