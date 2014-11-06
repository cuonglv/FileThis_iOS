//
//  ConnectionCredentialsViewController.m
//  FileThis
//
//  Created by Drew Wilson on 11/5/12.
//
//

#import <Crashlytics/Crashlytics.h>
#import "ConnectionCredentialsViewController.h"
#import "UIImageView+AFNetworking.h"
#import "UIKitExtensions.h"
#import "Constants.h"   //Cuong

@interface ConnectionCredentialsViewController () <UITextFieldDelegate> {
    id _receiver;
	SEL _action;
    SEL _cancelAction;
}

@property (strong, nonatomic) IBOutlet UIImageView *logo;
@property (strong, nonatomic) IBOutlet UITextView *institutionName;
@property (strong, nonatomic) IBOutlet UITextField *username;
@property (strong, nonatomic) IBOutlet UITextField *password;
@property (strong, nonatomic) UIBarButtonItem *connectButton;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint; //Cuong
@end

@implementation ConnectionCredentialsViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)setReceiver:(id) receiver withAction:(SEL)action {
    _receiver = receiver;
    _action = action;
}

- (void)setReceiver:(id) receiver withCancelAction:(SEL)action {
    _receiver = receiver;
    _cancelAction = action;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
    self.institutionName.text = _institution.name;
    [self.logo setImageWithURL:_institution.logoURL placeholderImage:[FTInstitution placeholderImage]];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { //Cuong
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (self.topLayoutConstraint.constant < kIOS7ToolbarHeight + 10) {
                self.topLayoutConstraint.constant = kIOS7ToolbarHeight + 10;
                [self.view layoutSubviews];
            }
        }
    }
}

- (void)viewDidUnload {
    [self setLogo:nil];
    [self setUsername:nil];
    [self setPassword:nil];
    [self setInstitutionName:nil];
    [self setInstitution:nil];
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"ConnectionCredentialsViewController viewWillAppear:");
    self.navigationController.navigationBarHidden = NO;
    
    self.connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Connect" style:UIBarButtonItemStyleDone target:self action:@selector(connect:)];
    self.navigationItem.rightBarButtonItem = self.connectButton;
    self.connectButton.enabled = NO;
    UIBarButtonItem *button = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = button;
    self.title = NSLocalizedString(@"Add Connection", @"Title for creating connection window");
    
    [self.username becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"ConnectionCredentialsViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL shouldnot = (toInterfaceOrientation & UIInterfaceOrientationMaskLandscape);
	return shouldnot;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

#pragma mark Actions
- (IBAction)connect:(id)sender {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_receiver performSelector:_action withObject:self];
#pragma clang diagnostic pop
}

- (IBAction)cancel:(id)sender {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [_receiver performSelector:_cancelAction withObject:self];
#pragma clang diagnostic pop
}

-(void)setInstitution:(FTInstitution *)institution {
    _institution = institution;
    self.institutionName.text = institution.name;
    [self.logo setImageWithURL:institution.logoURL placeholderImage:[FTInstitution placeholderImage]];
    if (self.institution.info != nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FileThis" message:self.institution.info
                                               delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
}

- (NSString *)usernameText {
    return self.username.text;
}

- (NSString *)passwordText {
    return self.password.text;
}

#pragma mark UITextFieldDelegate methods

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.username) {
        [self.password becomeFirstResponder];
    } else if (textField == self.password) {
        if ( ([self.username.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)
            && (([self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0)) ) {
            [self performSelectorOnMainThread:@selector(connect:) withObject:textField waitUntilDone:NO];
        } else {
            [self.username becomeFirstResponder];
        }
    }
    return YES;
}

// auto-disable add button if there is no username or password
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {

    BOOL enable = NO;
    if (textField == self.username)
        enable = self.passwordText.length != 0;
    else
        enable = self.usernameText.length != 0;
    
    if (enable) {
        int length = textField.text.length + string.length - range.length;
        enable = length != 0;
        NSLog(@"length=%d, replacement string=%@", length, string);
    }
    
    self.connectButton.enabled = enable;
    return YES; // change the text
}

@end
