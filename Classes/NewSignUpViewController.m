//
//  NewSignUpViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/14/13.
//
//

#import <Crashlytics/Crashlytics.h>
#import "NewSignUpViewController.h"
#import "UIKitExtensions.h"
#import "FTSession.h"
#import "RootViewController.h"
#import "FormLayoutView.h"
#import "Constants.h"
#import "CustomPagerViewController.h"
#import "CommonLayout.h"

#define MIN_PASSWORD_LENGTH 6
#define kAlertViewTag_EnterFirstName    1
#define kAlertViewTag_EnterLastName     2
#define kAlertViewTag_InvalidEmail      3
#define kAlertViewTag_InvalidPassword   4
#define kAlertViewTag_AccountCreated    5

@interface NewSignUpViewController () <UIWebViewDelegate>
@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UILabel *firstNameWarning;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UILabel *lastNameWarning;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UILabel *emailWarning;
@property (strong, nonatomic) IBOutlet UITextField *passwordField;
@property (strong, nonatomic) IBOutlet UILabel *passwordWarning;
@property (strong, nonatomic) IBOutlet UITextField *confirmPasswordField;
@property (strong, nonatomic) IBOutlet UILabel *confirmPasswordWarning;
@property (strong, nonatomic) IBOutlet UITextView *warningsTextView;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (strong, nonatomic) IBOutlet UIWebView *eulaFooterView;
@property (strong, nonatomic) IBOutlet UIScrollView *scrollView;
@property (strong, nonatomic) IBOutlet UIImageView *boxImageView1, *boxImageView2, *boxImageView3, *boxImageView4, *boxImageView5;


//@property (strong, nonatomic) IBOutlet UIView *emptyView;  //Cuong
@property (strong, nonatomic) IBOutlet UITableView *tableView;  //Cuong


@property (weak, nonatomic) IBOutlet UIBarButtonItem *signupButton;

@property (strong, nonatomic) IBOutlet FormLayoutView *formBackground;
@property (strong) NSMutableArray *errors;
@property (strong) NSArray *requiredFields;
@property BOOL accountCreated;

@end

@implementation NewSignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    
    float y;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        y = kIOS7ToolbarHeight;
    } else {
        y = 0;
    }
    
    float textFieldPadding = 10;
    float boxHeight, fontHeight;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        boxHeight = floorf(self.view.frame.size.height * 0.075);
        fontHeight = floorf(self.view.frame.size.height * 0.038);
        self.scrollView.scrollEnabled = YES;
        [self.boxImageView1 setTop:8.0 height:boxHeight];
    } else {    //iPad
        boxHeight = 53;
        fontHeight = 22;
        self.scrollView.scrollEnabled = NO;
        [self.boxImageView1 setTop:20.0 height:boxHeight];
    }
    
    self.scrollView.frame = CGRectMake(0, y, self.view.frame.size.width, self.view.frame.size.height - y);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.scrollView.frame.size.height + 120);
    self.scrollView.contentOffset = CGPointMake(0, 0);
    
    self.firstNameField.frame = CGRectMake(self.boxImageView1.frame.origin.x + textFieldPadding, self.boxImageView1.frame.origin.y, self.boxImageView1.frame.size.width - textFieldPadding - 1, self.boxImageView1.frame.size.height);
    
    [self.boxImageView2 setTop:[self.boxImageView1 bottom]+2 height:boxHeight];
    self.lastNameField.frame = CGRectMake(self.boxImageView2.frame.origin.x + textFieldPadding, self.boxImageView2.frame.origin.y, self.boxImageView2.frame.size.width - textFieldPadding - 1, self.boxImageView2.frame.size.height);
    
    [self.boxImageView3 setTop:[self.boxImageView2 bottom]+2 height:boxHeight];
    self.emailField.frame = CGRectMake(self.boxImageView3.frame.origin.x + textFieldPadding, self.boxImageView3.frame.origin.y, self.boxImageView3.frame.size.width - textFieldPadding - 1, self.boxImageView3.frame.size.height);
    
    [self.boxImageView4 setTop:[self.boxImageView3 bottom]+2 height:boxHeight];
    self.passwordField.frame = CGRectMake(self.boxImageView4.frame.origin.x + textFieldPadding, self.boxImageView4.frame.origin.y, self.boxImageView4.frame.size.width - textFieldPadding - 1, self.boxImageView4.frame.size.height);
    
    [self.boxImageView5 setTop:[self.boxImageView4 bottom]+2 height:boxHeight];
    self.confirmPasswordField.frame = CGRectMake(self.boxImageView5.frame.origin.x + textFieldPadding, self.boxImageView5.frame.origin.y, self.boxImageView5.frame.size.width - textFieldPadding - 1, self.boxImageView5.frame.size.height);
    
    self.firstNameField.font = self.lastNameField.font = self.emailField.font = self.passwordField.font = self.confirmPasswordField.font = [CommonLayout getFont:fontHeight isBold:NO];
    
    [self.eulaFooterView setTop:[self.boxImageView5 bottom]+2 bottom:self.scrollView.frame.size.height];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SignupFooter" ofType:@"html"];
	NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
	NSString *htmlString = [[NSString alloc] initWithData:[readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];
    [self.eulaFooterView loadHTMLString:htmlString baseURL:nil];
    self.eulaFooterView.scrollView.scrollEnabled = NO;
    
    self.errors = [[NSMutableArray alloc] init];
    self.requiredFields = @[self.firstNameField, self.lastNameField, self.emailField, self.passwordField, self.confirmPasswordField];
    
    [self enableSignupIfComplete];
    
    [self.firstNameField becomeFirstResponder];
    
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"SignupViewController viewWillAppear:");
    [self.navigationController setNavigationBarHidden:NO animated:NO];
//    [self.firstNameField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"SignupViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

- (IBAction)createAccount:(id)sender {
    [self.firstNameField resignFirstResponder];
    [self.lastNameField resignFirstResponder];
    [self.emailField resignFirstResponder];
    [self.passwordField resignFirstResponder];
    [self.confirmPasswordField resignFirstResponder];
    [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
    if ([self validateInput]) {
        [self createUser:self.email
           withFirstName:self.firstName
            withLastName:self.lastName
            withPassword:self.password
       withPasswordAgain:self.confirmPassword];
    }
}

- (void)viewDidUnload {
    [self setLastNameField:nil];
    [self setFirstNameField:nil];
    [self setEmailField:nil];
    [self setPasswordField:nil];
    [self setConfirmPasswordField:nil];
    [self setFirstNameWarning:nil];
    [self setLastNameWarning:nil];
    [self setEmailWarning:nil];
    [self setPasswordWarning:nil];
    [self setFormBackground:nil];
    [self setActivityIndicator:nil];
    
    [super viewDidUnload];
}

#pragma mark property accessors

- (NSString *)firstName { return self.firstNameField.text; }
- (NSString *)lastName { return self.lastNameField.text; }
- (NSString *)email { return self.emailField.text; }
- (NSString *)password { return self.passwordField.text; }
- (NSString *)confirmPassword { return self.confirmPasswordField.text; }

// http://stackoverflow.com/questions/800123/best-practices-for-validating-email-address-in-objective-c-on-ios-2-0
- (BOOL)validateEmail {
    NSString *email = self.emailField.text;
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    if (!isValid) {
        [self.errors addObject:@"Email is invalid."];
    }
    return isValid;
}

- (void)addError:(NSString *)error {
    [self.errors addObject:error];
}

- (BOOL)validatePassword {
    NSString *password = self.passwordField.text;
    NSString *passwordAgain = self.confirmPasswordField.text;
    NSString *passwordError = [NSString stringWithFormat:@"Password must be at least %d characters and must contain at least one number and one letter.", MIN_PASSWORD_LENGTH];
    
    if ([password length] < MIN_PASSWORD_LENGTH)
        [self addError:passwordError];
    else if (![password isEqualToString:passwordAgain])
        [self addError:@"Passwords don’t match."];
    else if ([password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound)
        [self addError:passwordError];
    else if ([password rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound)
        [self addError:passwordError];
    else
        return YES;
    
    return NO;
}

- (BOOL)validateInput {
    self.firstNameField.text = [self.firstNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self.firstNameField.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter First name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = kAlertViewTag_EnterFirstName;
        [alert show];
        [self.firstNameField becomeFirstResponder];
        return NO;
    }
    
    self.lastNameField.text = [self.lastNameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([self.lastNameField.text length] == 0) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:@"Please enter Last name" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self.lastNameField becomeFirstResponder];
        return NO;
    }
    
    int numInvalid = 0;
    [self.errors removeAllObjects];
    
    if (![self validateEmail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:self.errors[0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = kAlertViewTag_InvalidEmail;
        [alert show];
        [self.emailField becomeFirstResponder];
        numInvalid += 1;
    } else if (![self validatePassword]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password" message:self.errors[0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        alert.tag = kAlertViewTag_InvalidPassword;
        [alert show];
        [self.passwordField becomeFirstResponder];
        numInvalid += 1;
    }
    return numInvalid == 0;
}

- (BOOL)enableSignup:(BOOL)enable {
    self.signupButton.style = enable ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain;
    return enable;
}

- (BOOL)enableSignupIfComplete {
    int numEmpty = 0;
    for (UITextField *field in self.requiredFields) {
        if (field.text == nil || field.text.length == 0)
            numEmpty++;
    }
    if (![self validateEmail])
        numEmpty++;
    if (![self validatePassword])
        numEmpty++;
    
    return [self enableSignup: numEmpty == 0];
}

- (void)createUser:(NSString *)email
     withFirstName:(NSString *)firstname
      withLastName:(NSString *)lastname
      withPassword:(NSString *)password
 withPasswordAgain:(NSString *)passwordAgain {
    
    [self enableSignup:NO];
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
    BOOL isFetch = YES;
    NSDictionary *params = @{@"first" : firstname,
                             @"last" : lastname,
                             @"email" : email,
                             @"type" : isFetch ? @"conn" : @"host",
                             @"password" : password,
                             @"create-password-repeat" : passwordAgain };
    //                             @"terms-of-service" :
    // TBD: what are "type" and "_" params? How to handle "terms-of-service"?
    // https://staging.filethis.com/ftapi/ftapi?jsonp=jQuery16204539361447095871_1353966856904&first=f&last=l&email=drewmwilson%40mailinator.com&password=brian6&create-password-repeat=brian6&terms-of-service=on&op=webnewaccount&type=conn&_=1353966940108
    
    NSLog(@"Create user:%@, %@ %@", email, firstname, lastname);
    [[FTSession sharedSession] createUser:params onSuccess:^(id JSON) {
        if ([JSON[@"result"] isEqualToString:@"ERROR"]) {
            NSString *errorText = @"Cannot create account";
            id error = JSON[@"error"];
            if (error) {
                errorText = [@"Cannot create account." stringByAppendingFormat:@"\n%@",error[@"text"]];
            }
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Warning" message:errorText delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alertView show];
            return;
        }
        
        self.accountCreated = YES;
        [self enableUserInterface];
        [self enableSignupIfComplete];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"FileThis" message:NSLocalizedString(@"Your account has been created", nil) delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        alertView.tag = kAlertViewTag_AccountCreated;
        [alertView show];
    } onFailure:^ {
        [self enableUserInterface];
        [self enableSignupIfComplete];
    }];
}

- (void)enableUserInterface {
    [self.activityIndicator stopAnimating];
    self.activityIndicator.hidden = YES;
}

-(void) disableUserInterface {
    self.activityIndicator.hidden = NO;
    [self.activityIndicator startAnimating];
    
}

#pragma mark UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // FIXME: show text field
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (textField == self.firstNameField || textField == self.lastNameField || textField == self.emailField) {
            [self.scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
        } else if (textField == self.passwordField || textField == self.confirmPasswordField) {
            self.scrollView.contentOffset = CGPointMake(0, self.emailField.frame.origin.y - 20);
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self enableSignupIfComplete];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // validate fields after editing change takes affect
    [self performSelector:@selector(enableSignupIfComplete) withObject:nil afterDelay:0.0];
    return YES;
}

// ref http://stackoverflow.com/questions/1347779/how-to-navigate-through-textfields-next-done-buttons
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    int previousTag = textField.tag, numberOfRows = 100;
    if (previousTag <= numberOfRows) {
        UITextField *nextField=(UITextField *)[self.view viewWithTag:previousTag+1];
        if (nextField == nil) {
            // no next - so remove keyboard
//            [textField resignFirstResponder];
//            self.scrollView.contentOffset = CGPointMake(0, 0);
            [self createAccount:nil];
        } else {
            [nextField becomeFirstResponder];
        }
    }
    return YES;
}

#pragma  mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertViewTag_EnterFirstName) {
    } else if (alertView.tag == kAlertViewTag_EnterLastName) {
    } else if (alertView.tag == kAlertViewTag_InvalidEmail) {
    } else if (alertView.tag == kAlertViewTag_InvalidPassword) {
    } else if (alertView.tag == kAlertViewTag_AccountCreated) {
        //[self performSegueWithIdentifier:@"accountCreated" sender:nil];
        CustomPagerViewController *rootController = [self.navigationController.viewControllers objectAtIndex:0];
        [rootController signUpCompletedWithEmail:self.email password:self.password];
    }
}

#pragma mark - UIWebViewDelegate methods
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    
    //    NSURL *url = request.URL;
    //    NSString *urlString = url.absoluteString;
    //
    //    //Check if special link
    //    if ( [urlString isEqualToString: @"filethis://eula"]) {
    //        //Here present the new view controller
    //        UIViewController *controller = [[UIViewController alloc] init];
    //        [self presentViewController:controller animated:YES completion:nil];
    //
    //        return NO;
    //    } else
    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
        [[UIApplication sharedApplication] openURL:request.URL];
        return false;
    }
    return true;
}

#pragma  mark - Storyboard support
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"sequeing %@ from %@, source=%@, dest=%@", segue.identifier, sender, segue.sourceViewController, segue.destinationViewController);
    if ([[segue identifier] isEqualToString:@"cancelSignup"]) {
        
    }
}
@end
