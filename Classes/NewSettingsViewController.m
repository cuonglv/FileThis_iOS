//
//  NewSettingsViewController.m
//  FileThis
//
//  Created by Cuong Le on 12/13/13.
//
//

#import <Crashlytics/Crashlytics.h>
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

#import "NewSettingsViewController.h"
#import "KKPasscodeSettingsViewController.h"
#import "KKPasscodeLock.h"
#import "MBProgressHUD.h"

#import "SubscriptionViewController.h"
#import "UIKitExtensions.h"

#import "TimeoutSettingViewController.h"
#import "DestinationPickerViewController.h"
#import "FTSession.h"
#import "FTAccountSettings.h"

#import "CommonLayout.h"
#import "UserDataManager.h"

#import "FTMobileAppDelegate.h"
#import "WizardViewController.h"

#import "InviteFriendViewController.h"
#import "UsageViewController.h"
#import "ReferralObject.h"

@interface NewSettingsViewController () <KKPasscodeSettingsViewControllerDelegate,  UITextFieldDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *myTable;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UILabel *memberSinceLabel;
@property (weak, nonatomic) IBOutlet UILabel *lastLoginLabel;

@property (weak, nonatomic) IBOutlet UILabel *servicePlan;

@property (weak, nonatomic) IBOutlet UISwitch *emailSuccessesSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *emailFailuresSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *emailCampaignSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *autoTagAddedSwitch;

@property (weak, nonatomic) IBOutlet UILabel *versionOutlet;
@property (weak, nonatomic) IBOutlet UILabel *hostName;
@property (weak, nonatomic) IBOutlet UILabel *autoRenewsLabel;
@property (weak, nonatomic) IBOutlet UILabel *passcodeTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *passcodeEnabledLabel;


@property (strong, nonatomic) IBOutlet UITableViewCell *cell00, *cell01, *cell02, *cell03, *cell04, *cell05, *cell06, *cell10, *cell20, *cell21, *cell22, *cell30;

@property (strong, nonatomic) IBOutlet UITableViewCell *cellGeneral00; //Loc Cao
@property (strong, nonatomic) IBOutlet UITableViewCell *cellSecurityChangePass; //Loc Cao
@property (strong, nonatomic) IBOutlet UITableViewCell *cellInviteFriend;
@property (strong, nonatomic) IBOutlet UILabel *lblCellInviteFriend;

@property (strong) NSArray *fieldsToFade;

@property (strong, nonatomic) MBProgressHUD *progessView;
@property (nonatomic, strong) UIButton *wizardButton;

@end

@implementation NewSettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleLabel.text = @"Settings";
    
    [self addTopRightImageBarButton:[UIImage imageNamed:@"info_icon_white.png"] width:(IS_IPHONE ? 40 : 50) target:self selector:@selector(handleWizardButton)];
    
    self.versionOutlet.text = [self versionString];
    
    FTDestinationConnection *dest = [FTSession sharedSession].currentDestination;
    if (dest.name && ([dest.name isEqualToString:@"FileThis Cloud"])) {
        self.lblCellInviteFriend.text = NSLocalizedString(@"ID_USAGE", @"");
    } else {
        self.lblCellInviteFriend.text = NSLocalizedString(@"ID_INVITE_FRIEND", @"");
    }
    
    NSArray *arrClasses = [NSArray arrayWithObjects:[UILabel class], [UITextField class], nil];
    
    //Change font for all cells
    UIFont *font = [CommonLayout getFont:16 isBold:NO];
    
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell00];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell01];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell02];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell03];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell04];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell05];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell06];
    
    
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell10];
    
    
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell20];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell21];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell22];
    
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cell30];
    
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cellGeneral00];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cellSecurityChangePass];
    [CommonLayout setFont:font forClassesInList:arrClasses inView:self.cellInviteFriend];
    
    //Change text color
    UIColor *color = kTextGrayColor;
    
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell00];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell01];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell02];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell03];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell04];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell05];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell06];
    
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell10];
    
    
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell20];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell21];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell22];
    
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cell30];
    
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cellGeneral00];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cellSecurityChangePass];
    [CommonLayout setTextColor:color forClassesInList:arrClasses inView:self.cellInviteFriend];
    
    self.firstNameField.textColor = kTextOrangeColor;
    self.lastNameField.textColor = kTextOrangeColor;
    self.emailField.textColor = kTextOrangeColor;
}

- (void)relayout {
    [super relayout];
    self.myTable.frame = self.contentView.frame;
    [self.myTable reloadData];
}

- (NSString *)versionString {
    NSDictionary *appInfo = [[NSBundle mainBundle] infoDictionary];
    NSString *versionStr = [NSString stringWithFormat:@"v%@ (%@)",
                            [appInfo objectForKey:@"CFBundleShortVersionString"],
                            [appInfo objectForKey:@"CFBundleVersion"]];
    return versionStr;
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"SettingsViewController viewWillAppear:");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestination:) name:FTCurrentDestinationUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestination:) name:FTFixCurrentDestination object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatedSettings:) name:FTGetAccountInfo object:nil];
    
    [self.navigationController setToolbarHidden:YES animated:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    
    if ([FTSession sharedSession].settings != nil)
        [self fadeIn];
    
    [self reload:animated];
    
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"SettingsViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

-(void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
    
    [self save];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (BOOL)shouldRelayoutBeforeViewAppear {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return NO;
    return [super shouldRelayoutBeforeViewAppear];
}

#pragma mark - Actions
- (void)fadeIn {
    UIViewAnimationOptions options = UIViewAnimationOptionTransitionCrossDissolve;
    [UIView animateWithDuration:1.0 delay:0.0 options:options
                     animations:^{
                         for (UIView *v in self.fieldsToFade) {
                             v.alpha = 1.0;
                         }
                         [self applyAccountSettings];
                         [self.progessView hide:NO];
                     }
                     completion:nil];
}

- (void)fadeOut:(BOOL)animate {
    dispatch_block_t clearValues = ^(){
        for (UIView *v in self.fieldsToFade) {
            NSAssert(v != nil, @"field != nil");
            v.alpha = 0.0;
        }
        if (self.progessView == nil) {
            self.progessView = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
            self.progessView.labelText = NSLocalizedString(@"Loading Data", @"loading settings data");
        } else {
            [self.progessView show:NO];
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
    self.autoTagAddedSwitch.on = settings.autoClassify;
    self.hostName.text = [FTSession hostName];
    
    BOOL on = [KKPasscodeLock sharedLock].isPasscodeRequired;
    self.passcodeEnabledLabel.text = on ? NSLocalizedString(@"On", "boolean value on") :
    NSLocalizedString(@"Off", "boolean value off");
    [self.progessView hide:YES];
    return YES;
}

#pragma mark - Notification handlers
- (void)updateDestination:(NSNotification *)notification {
    BOOL isFileThisDestination = NO;
    FTDestinationConnection *dest = [FTSession sharedSession].currentDestination;
    if (dest.name && ([dest.name isEqualToString:@"FileThis Cloud"])) {
        isFileThisDestination = YES;
    }
    
    NSString *s = NSLocalizedString(@"ID_INVITE_FRIEND", @"");
    if (isFileThisDestination) {
        s = NSLocalizedString(@"ID_USAGE", @"");
    }
    dispatch_async(dispatch_get_main_queue(), ^{
        self.lblCellInviteFriend.text = s;
    });
}

- (void)updatedSettings:(NSNotification *)notification {
    [self fadeOut:YES];
    [self fadeIn];
}

#pragma mark - Table view delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0: //User account
            return 8;
            break;
        case 1: //General
            return 1;
        case 2: //Security
            return 2;
            break;
        case 3: //Notification
            return 3;
            break;
        default: //About
            return 1;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: //User account
            switch (indexPath.row) {
                case 0:
                    return self.cell00;
                case 1:
                    return self.cell01;
                case 2:
                    return self.cell02;
                case 3:
                    return self.cell03;
                case 4:
                    return self.cell04;
                case 5:
                    return self.cell05;
                case 6:
                    return self.cellInviteFriend;
                default:
                    return self.cell06;
            }
        case 1: //General
            return self.cellGeneral00;
        case 2: // Security
            switch (indexPath.row) {
                case 0:
                    return self.cell10;
                default:
                    return self.cellSecurityChangePass;
            }
            
        case 3: //Notification
            switch (indexPath.row) {
                case 0:
                    return self.cell20;
                case 1:
                    return self.cell21;
                default:
                    return self.cell22;
            }
        case 4: //About
            return self.cell30;
        default:
            return self.cell30;
    }
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    // resuseIdentifier isn't set
    if ([cell.reuseIdentifier isEqualToString:@"passcode"]) {
        KKPasscodeSettingsViewController *vc = [[KKPasscodeSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
        vc.delegate = self;
        [self.navigationController pushViewController:vc animated:YES];
    } else if ([cell.reuseIdentifier isEqualToString:@"myAccount"]) {
        SubscriptionViewController *target = [[SubscriptionViewController alloc] initWithNibName:@"SubscriptionViewController" bundle:[NSBundle mainBundle]];
        target.useBackButton = YES;
        [self.navigationController pushViewController:target animated:YES];
    } else if ([cell.reuseIdentifier isEqualToString:@"inviteFriend"]) {
        FTDestinationConnection *dest = [FTSession sharedSession].currentDestination;
        if (dest.name && ([dest.name isEqualToString:@"FileThis Cloud"])) {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"button_usage_press" label:@"usage" value:nil] build]];
            
            UsageViewController *target = [[UsageViewController alloc] initWithNibName:@"UsageViewController" bundle:[NSBundle mainBundle]];
            target.useBackButton = YES;
            [self.navigationController pushViewController:target animated:YES];
        } else {
            id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
            [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"ui_action" action:@"button_invite_press" label:@"invite a friend" value:nil] build]];
            
            InviteFriendViewController *target = [[InviteFriendViewController alloc] initWithNibName:@"InviteFriendViewController" bundle:[NSBundle mainBundle]];
            target.useBackButton = YES;
            [self.navigationController pushViewController:target animated:YES];
        }
    } else if ([cell.reuseIdentifier isEqualToString:@"changePassword"]) {
         ChangePasswordPopup *target = [[ChangePasswordPopup alloc] initWithNibName:@"ChangePasswordPopup" bundle:[NSBundle mainBundle]];
        target.delegate = self;
        target.modalPresentationStyle = UIModalPresentationFormSheet;
        target.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            target.modalPresentationStyle = UIModalPresentationFullScreen;
        }
        
        [self.navigationController presentViewController:target animated:YES completion:^{
        }];
        target.view.superview.backgroundColor = [UIColor clearColor];
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

//Loc Cao
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return NSLocalizedString(@"USER ACCOUNT", "user account section");
        case 1:
            return NSLocalizedString(@"GENERAL", "general section");
        case 2:
            return NSLocalizedString(@"SECURITY", "security section");
        case 3:
            return NSLocalizedString(@"EMAIL NOTIFICATIONS", "notifications section");
        default:
            return NSLocalizedString(@"ABOUT", "about section");
    }
}

#pragma mark KKPasscodeSettingsViewControllerDelegate
- (void)didSettingsChanged:(KKPasscodeSettingsViewController*)viewController {
    NSLog(@"settings changed");
}

#pragma mark -
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

#pragma mark - Switch events
- (IBAction)emailCampaignChanged:(UISwitch *)sender {
    [FTSession sharedSession].settings.emailCampaign = sender.on;
}

- (IBAction)emailFailuresChanged:(UISwitch *)sender {
    [FTSession sharedSession].settings.emailFailures = sender.on;
}

- (IBAction)emailSuccessChanged:(UISwitch *)sender {
    [FTSession sharedSession].settings.emailSuccesses = sender.on;
}

- (IBAction)automaticTagAddChanged:(UISwitch *)sender {
    [FTSession sharedSession].settings.autoClassify = sender.on;
}

#pragma mark - ChangePasswordPopupDelegate
- (void)didChooseChangePassword:(NSString*)oldPassword withNewPassword:(NSString*)newPassword
{
    UserDataManager *dataManager = [UserDataManager getInstance];
    
    NSString *msg = @"Unknown error";
    NSDictionary *result = [dataManager updatePassword:oldPassword withNewPassword:newPassword];
    if ([result isKindOfClass:[NSDictionary class]])
    {
        NSString *errorType = [result objectForKey:@"errorType"];
        if (!errorType)
        {
            msg = @"Update password successfully";
        }
        else
        {
            NSString *content = [result objectForKey:@"errorMessage"];
            if (content)
            {
                msg = content;
            }
        }
    }
    [CommonLayout showAlertMessageWithTitle:nil content:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitle:nil];
}

#pragma mark - Wizard
- (void)handleWizardButton {
    WizardViewController *vc = [[WizardViewController alloc] initWithWizardIndex:0 initialViewControllerBeforeWizard:self];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
