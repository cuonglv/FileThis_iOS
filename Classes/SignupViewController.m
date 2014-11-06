//
//  SignupViewController.m
//  FileThis
//
//  Created by Drew Wilson on 11/13/12.
//
//

#import <Crashlytics/Crashlytics.h>
#import "UIKitExtensions.h"
#import "FTSession.h"
#import "SignupViewController.h"
#import "RootViewController.h"
#import "FormLayoutView.h"
#import "Constants.h"

#define MIN_PASSWORD_LENGTH 6

@interface SignupViewController () <UIWebViewDelegate, UITableViewDelegate>
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

//@property (strong, nonatomic) IBOutlet UIView *emptyView;  //Cuong
@property (strong, nonatomic) IBOutlet UITableView *tableView;  //Cuong


@property (weak, nonatomic) IBOutlet UIBarButtonItem *signupButton;

@property (strong, nonatomic) IBOutlet FormLayoutView *formBackground;
@property (strong) NSMutableArray *errors;
@property (strong) NSArray *requiredFields;
@property BOOL accountCreated;

@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:self.view.window];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:self.view.window];
    self.errors = [[NSMutableArray alloc] init];
    self.requiredFields = @[self.firstNameField, self.lastNameField, self.emailField,
                            self.passwordField, self.confirmPasswordField];
    
    [self enableSignupIfComplete];

    [super viewDidLoad];
    
    //self.view.frame = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y + 50, self.view.frame.size.width, self.view.frame.size.height - 50);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    CLS_LOG(@"SignupViewController viewWillAppear:");
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.firstNameField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"SignupViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

- (IBAction)createAccount:(id)sender {
    if ([self validateInput]) {
        [self createUser:self.email
           withFirstName:self.firstName
            withLastName:self.lastName
            withPassword:self.password
       withPasswordAgain:self.confirmPassword];
    }
}

- (void)unload
{
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                            name:UIKeyboardWillShowNotification object:nil];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                            name:UIKeyboardWillHideNotification object:nil];
}

-(void)dealloc
{
    [self unload];
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
    if ([password length] < MIN_PASSWORD_LENGTH)
        [self addError:[NSString stringWithFormat:@"Password must be at least %d characters.", MIN_PASSWORD_LENGTH]];
    else if (![password isEqualToString:passwordAgain])
        [self addError:@"Passwords don’t match."];
    else if ([password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound)
        [self addError:@"Password must contain at least one number."];
    else if ([password rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound)
        [self addError:@"Password must contain at least one letter."];
    else
        return YES;
    
    return NO;
}

- (BOOL)validateInput
{
    int numInvalid = 0;
    [self.errors removeAllObjects];
    
    if (![self validateEmail]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Email" message:self.errors[0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        numInvalid += 1;
    } else if (![self validatePassword]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Invalid Password" message:self.errors[0] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        numInvalid += 1;
    }
    return numInvalid == 0;
}

- (BOOL)enableSignup:(BOOL)enable
{
    self.signupButton.style = enable ? UIBarButtonItemStyleDone : UIBarButtonItemStylePlain;
    return enable;
}

- (BOOL)enableSignupIfComplete
{
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
        self.accountCreated = YES;
        [self enableUserInterface];
        [self enableSignupIfComplete];
        NSString *message = NSLocalizedString(@"Your account has been created", nil);
        [[[UIAlertView alloc] initWithTitle:@"FileThis" message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
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

#pragma mark UIKeyboard notifications

// http://stackoverflow.com/questions/5265559/get-uitableview-to-scroll-to-the-selected-uitextfield-and-avoid-being-hidden-by
- (void)keyboardWillShow:(NSNotification *)sender
{
    CGSize kbSize = [[[sender userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 0, kbSize.height, 0);
        [self.tableView setContentInset:edgeInsets];
        [self.tableView setScrollIndicatorInsets:edgeInsets];
    }];
}

- (void)keyboardWillHide:(NSNotification *)sender
{
    NSTimeInterval duration = [[[sender userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets edgeInsets = UIEdgeInsetsZero;
        [self.tableView setContentInset:edgeInsets];
        [self.tableView setScrollIndicatorInsets:edgeInsets];
    }];
}

#pragma mark UITextFieldDelegate methods

- (void)textFieldDidBeginEditing:(UITextField *)textField {
    // FIXME: show text field
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
        if (nextField == nil)
        {
            // no next - so remove keyboard
            [textField resignFirstResponder];
        } else {
            [nextField becomeFirstResponder];
        }
    }
    return YES;
}

#pragma  mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (![self validateEmail]) {
        [self.emailField becomeFirstResponder];
    } else if (![self validatePassword]) {
        [self.passwordField becomeFirstResponder];
    } else if (self.accountCreated) {
        [self performSegueWithIdentifier:@"accountCreated" sender:nil];
    }
}

#pragma mark - UIWebViewDelegate methods
-(BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
        navigationType: (UIWebViewNavigationType)navigationType {

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

#pragma mark UITableViewDelegate methods

const CGFloat kFooterHeight = 120.0;

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        return kIOS7ToolbarHeight + 5.0;
    }
    return 0.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return kFooterHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
	CGRect f = CGRectMake(0.0, 0.0, self.tableView.bounds.size.width, kFooterHeight);
    UIWebView *eulaFooterView = [[UIWebView alloc] initWithFrame:f];

	NSString *path = [[NSBundle mainBundle] pathForResource:@"SignupFooter" ofType:@"html"];
	NSFileHandle *readHandle = [NSFileHandle fileHandleForReadingAtPath:path];
	NSString *htmlString = [[NSString alloc] initWithData:
                            [readHandle readDataToEndOfFile] encoding:NSUTF8StringEncoding];

    [eulaFooterView loadHTMLString:htmlString baseURL:nil];
    eulaFooterView.delegate = self;
	eulaFooterView.backgroundColor = [UIColor clearColor];
	eulaFooterView.opaque = NO;
    return eulaFooterView;
}

#pragma  mark - Storyboard support


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"sequeing %@ from %@, source=%@, dest=%@", segue.identifier, sender, segue.sourceViewController, segue.destinationViewController);
    if ([[segue identifier] isEqualToString:@"cancelSignup"]) {
        
    }
}

@end
