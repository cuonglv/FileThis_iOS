//
//  SettingsViewController.m
//  FileThis
//
//  Created by Drew Wilson on 1/7/13.
//

#import <Crashlytics/Crashlytics.h>

#import "KKPasscodeSettingsViewController.h"
#import "KKPasscodeLock.h"
#import "MBProgressHUD.h"

#import "SettingsViewController.h"
#import "SubscriptionViewController.h"
#import "UIKitExtensions.h"

#import "TimeoutSettingViewController.h"
#import "DestinationPickerViewController.h"
#import "FTSession.h"
#import "FTAccountSettings.h"

@interface SettingsViewController () <KKPasscodeSettingsViewControllerDelegate,  UITextFieldDelegate,UINavigationControllerDelegate>

@property (strong, nonatomic) IBOutlet UITextField *firstNameField;
@property (strong, nonatomic) IBOutlet UITextField *lastNameField;
@property (strong, nonatomic) IBOutlet UITextField *emailField;
@property (strong, nonatomic) IBOutlet UILabel *memberSinceLabel;
@property (strong, nonatomic) IBOutlet UILabel *lastLoginLabel;

@property (strong, nonatomic) IBOutlet UILabel *servicePlan;

@property (strong, nonatomic) IBOutlet UISwitch *emailSuccessesSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *emailFailuresSwitch;
@property (strong, nonatomic) IBOutlet UISwitch *emailCampaignSwitch;
@property (strong, nonatomic) IBOutlet UILabel *destinationName;
@property (strong, nonatomic) IBOutlet UIButton *destinationLogo;
@property (strong, nonatomic) IBOutlet UILabel *destinationStatus;

@property (strong, nonatomic) IBOutlet UILabel *versionOutlet;
@property (strong, nonatomic) IBOutlet UILabel *hostName;
@property (strong, nonatomic) IBOutlet UILabel *autoRenewsLabel;
@property (strong, nonatomic) IBOutlet UILabel *passcodeTitleLabel;
@property (strong, nonatomic) IBOutlet UILabel *passcodeEnabledLabel;
@property (strong, nonatomic) IBOutlet UIButton *openDestinationButton;

@property (strong) NSArray *fieldsToFade;

@property (strong, nonatomic) MBProgressHUD *loadingView;

@end

@implementation SettingsViewController

-(void)awakeFromNib {
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.versionOutlet.text = [self versionString];
    self.fieldsToFade = @[self.firstNameField, self.lastNameField, self.emailField,
                          self.memberSinceLabel, self.lastLoginLabel,
                          self.servicePlan,
                          self.destinationName, self.destinationLogo, self.destinationStatus,
                          self.openDestinationButton];
    for (id field in self.fieldsToFade)
        NSAssert(field != nil, @"field is initialized");

    self.destinationLogo.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    self.openDestinationButton.enabled = NO;
    self.openDestinationButton.alpha = self.openDestinationButton.enabled ? 1.0 : 0.5;
    NSString *disabledTitle = NSLocalizedString(@"Please configure destination", @"open dest app button title when missing destination");
    [self.openDestinationButton setTitle:disabledTitle forState:UIControlStateDisabled];
}

- (void)configureDestinationView {
    FTDestinationConnection *currentDestination = [FTSession sharedSession].currentDestination;
    if (currentDestination) {
        self.destinationName.text = currentDestination.name;
        FTDestination *destination = [FTDestination destinationWithId:currentDestination.destinationId];
        
        UIImage *cachedImage = [[NSURLCache sharedURLCache] cachedImageForURL:destination.logoUrl];
        if (cachedImage)
            [self.destinationLogo setImage:cachedImage forState:UIControlStateNormal];
        else
            [self.destinationLogo.imageView setImageWithURL:destination.logoUrl placeholderImage:[FTDestination placeholderImage] cached:YES];
        
        self.destinationStatus.text = currentDestination.statusString;

        // configure launch destination button
        self.openDestinationButton.enabled = [currentDestination canLaunchApplication];
        self.openDestinationButton.alpha = self.openDestinationButton.enabled ? 1.0 : 0.5;
        NSString *formatString = NSLocalizedString(@"Open %@", @"button title to open destination application");
        NSString *destinationName = currentDestination.name;
        NSString *title = [NSString stringWithFormat:formatString, destinationName];
        [self.openDestinationButton setTitle:title forState:UIControlStateNormal];
        [self.openDestinationButton setTitle:title forState:UIControlStateHighlighted];
        [self.openDestinationButton setTitle:title forState:UIControlStateSelected];
        
        formatString = NSLocalizedString(@"%@ not installed", @"open destination button displayed when app not installed");
        NSString *disabledTitle = [NSString stringWithFormat:formatString, currentDestination.name];
        [self.openDestinationButton setTitle:disabledTitle forState:UIControlStateDisabled];
        
    } else {
        self.destinationName.text = @"";
        self.destinationStatus.text = @"";
        self.destinationLogo.imageView.image = [FTDestination placeholderImage];
    }
}

- (NSString *)versionString {
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionStr = [NSString stringWithFormat:@"v%@ (%@)",
                            [appInfo objectForKey:@"CFBundleShortVersionString"],
                            [appInfo objectForKey:@"CFBundleVersion"]];
    return versionStr;
}

- (void)viewWillAppear:(BOOL)animated
{
    CLS_LOG(@"SettingsViewController viewWillAppear:");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestination:) name:FTCurrentDestinationUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestination:) name:FTFixCurrentDestination object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedSettings:) name:FTGetAccountInfo object:nil];

    [self.navigationController setToolbarHidden:YES animated:animated];
    
    if ([FTSession sharedSession].settings != nil)
        [self fadeIn];

    [self reload:animated];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"SettingsViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark Actions

- (IBAction)launchDestination:(UIButton *)destinationButton {
    FTDestinationConnection *currentDestination = [FTSession sharedSession].currentDestination;
    [currentDestination launchApplication];
    NSLog(@"launch destination %@", self.destinationName.text);
}

// animate settings
- (void)fadeIn {
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionCrossDissolve;
    [UIView animateWithDuration:1.0 delay:0.0 options:options
                     animations:^{
                         for (UIView *v in self.fieldsToFade) {
                             v.alpha = 1.0;
                         }
                         [self applyAccountSettings];
                         [self configureDestinationView];
                         [self.loadingView hide:NO];
                     }
                     completion:nil];
}

- (void)fadeOut:(BOOL)animate {
    dispatch_block_t clearValues = ^(){
        for (UIView *v in self.fieldsToFade) {
            NSAssert(v != nil, @"field != nil");
            v.alpha = 0.0;
        }
        if (self.loadingView == nil) {
            self.loadingView = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            self.loadingView.labelText = NSLocalizedString(@"Loading Data", @"loading settings data");
        } else {
            [self.loadingView show:NO];
        }
    };
    
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionCrossDissolve;
    if (animate) {
        [UIView animateWithDuration:1.0 delay:0.0 options:options
                         animations:clearValues
                         completion:nil];
    } else {
        (clearValues)();
    }
}

- (void)reload:(BOOL)animate {
    [[FTSession sharedSession] getAccountPreferences:^(FTAccountSettings *settings) {
        [self fadeOut:animate];
        [self fadeIn];
    }];
}

- (void)save {
    [self finishEditing];
    [[FTSession sharedSession].settings save];
}

- (void)finishEditing
{
    // force any active text fields to resign so that editing
    // changes will be saved by didEndEditing.
    if ([self.firstNameField isFirstResponder])
        [self.firstNameField resignFirstResponder];
    else if ([self.lastNameField isFirstResponder])
        [self.lastNameField resignFirstResponder];
    else if ([self.emailField isFirstResponder])
        [self.emailField resignFirstResponder];
}

- (BOOL)applyAccountSettings {
    FTAccountSettings *settings = [FTSession sharedSession].settings;
    if (!settings)
        return NO;
    
    self.firstNameField.text = settings.firstName;
    self.lastNameField.text = settings.lastName;
    self.emailField.text = settings.email;
    self.memberSinceLabel.text = settings.memberSince;
    self.lastLoginLabel.text = settings.lastLogin;
    self.servicePlan.text = settings.localizedServicePlan;
    NSString *autoRenewsOn = settings.autoRenewsOn;
    if (autoRenewsOn)
        self.autoRenewsLabel.text = autoRenewsOn;
    self.emailSuccessesSwitch.on = settings.emailSuccesses;
    self.emailFailuresSwitch.on = settings.emailFailures;
    self.emailCampaignSwitch.on = settings.emailCampaign;
    self.hostName.text = [FTSession hostName];
    
    BOOL on = [KKPasscodeLock sharedLock].isPasscodeRequired;
    self.passcodeEnabledLabel.text = on ? NSLocalizedString(@"On", "boolean value on") :
                                     NSLocalizedString(@"Off", "boolean value off");
    [self.loadingView hide:YES];
    return YES;
}

#pragma mark Notification handlers

// called whenever "current destination updated" notification received
- (void)updateDestination:(NSNotification *)notification {
    NSArray *destinationFields = @[self.destinationLogo, self.destinationName, self.destinationStatus];
    [UIView animateWithDuration:0.5 animations:^{
        for(UIView *v in destinationFields)
            v.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self configureDestinationView];
        [UIView animateWithDuration:0.5 animations:^{
            for(UIView *v in destinationFields)
                v.alpha = 1.0;
        }];
    }];
}

- (void)updatedSettings:(NSNotification *)notification {
    [self fadeOut:YES];
    [self fadeIn];
}

#pragma mark - Table view delegate

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // resuseIdentifier isn't set
    if ([cell.reuseIdentifier isEqualToString:@"passcode"]) {
        KKPasscodeSettingsViewController *vc = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];        
//        [self.navigationController pushViewController:[[SetPasscodeController alloc] initWithNibName:nil bundle:nil] animated:YES];
    } else if ([cell.reuseIdentifier isEqualToString:@"myAccount"]) {
        SubscriptionViewController *subscriptionView = [[SubscriptionViewController alloc] initWithNibName:nil bundle:nil];
        subscriptionView.useBackButton = YES;
        [self.navigationController pushViewController:subscriptionView animated:YES];
    }
    else {
        switch (cell.tag) {
            case 8:
                NSLog(@"pick destination");
                [self performSegueWithIdentifier:@"pickDestination" sender:nil];
                break;
            case 9:
                NSLog(@"set auto timeout");
                [self performSegueWithIdentifier:@"pickTimeout" sender:nil];
                break;
            case 10: {
                KKPasscodeSettingsViewController *vc = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
                vc.delegate = self;
                [self.navigationController pushViewController:vc animated:YES];
//                [self.navigationController pushViewController:[[SetPasscodeController alloc] initWithNibName:nil bundle:nil] animated:YES];
                break;
            }
        }
    }
    
    return NO;
}
#pragma mark KKPasscodeSettingsViewControllerDelegate

- (void)didSettingsChanged:(KKPasscodeSettingsViewController*)viewController {
    NSLog(@"settings changed");
}


- (IBAction)emailCampaignChanged:(UISwitch *)sender {
    [FTSession sharedSession].settings.emailCampaign = sender.on;
}

- (IBAction)emailFailuresChanged:(UISwitch *)sender {
    [FTSession sharedSession].settings.emailFailures = sender.on;
}

- (IBAction)emailSuccessChanged:(UISwitch *)sender {
    [FTSession sharedSession].settings.emailSuccesses = sender.on;
}

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
    if ([identifier isEqualToString:@"openStore"]) {
        if ([SKPaymentQueue canMakePayments]) {
            // Display a store to the user.
        } else {
            // Warn the user that purchases are disabled.
            NSString *m = NSLocalizedString(@"Payments are disabled for this application. You cannot change the account subscription.", @"Settings displays this to user if payments are disabled");
            [[[UIAlertView alloc] initWithTitle:@"FileThis"
                     message:m delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            return NO;
        }
    }
    return YES;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pickDestination"]) {
        DestinationPickerViewController *vc = segue.destinationViewController;
        int destId = [FTSession sharedSession].currentDestination.destinationId;
        FTDestination *dest = [FTDestination destinationWithId:destId];
        vc.destination = dest;
    }
}

- (IBAction)done:(UIStoryboardSegue *)segue
{
    NSLog(@"done");
}

- (IBAction)destinationConfigured:(UIStoryboardSegue *)segue
{
    [self fadeOut:YES];
    [self reload:YES];
}

//- (IBAction)upgrade:(id)sender {
//    if (self.settings.isApplePayment) {
//        [self performSegueWithIdentifier:@"subscribe" sender:self];
//    } else {
//        NSString *message = NSLocalizedString(@"You cannot change your account from here. Please update your account status through our web interface, where it was created.", nil);
//        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FileThis Account" message:message delegate:self cancelButtonTitle:@"Sorry" otherButtonTitles: nil];
//        [alert show];
//    }
//}
//
#pragma mark UITextFieldDelegate

// may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
- (void)textFieldDidEndEditing:(UITextField *)textField {    
    if (textField == self.firstNameField) {
        [FTSession sharedSession].settings.firstName = textField.text;
    } else if (textField == self.lastNameField) {
        [FTSession sharedSession].settings.lastName = textField.text;
    } else if (textField == self.emailField) {
        [FTSession sharedSession].settings.email = textField.text;
    }
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.firstNameField) {
        [self.lastNameField becomeFirstResponder];
    } else if (textField == self.lastNameField) {
        [self.emailField becomeFirstResponder];
    } else if (textField == self.emailField) {
        [self.emailField resignFirstResponder];
    }
    return YES;
}

@end
