//
//  SubscriptionViewController.m
//  FileThis
//
//  Created by Drew Wilson on 1/15/13.
//
//

#import <StoreKit/StoreKit.h>

#import "MBProgressHUD.h"
#import "UIAlertView+BlockExtensions.h"
#import "UIKitExtensions.h"

#import "AppleStoreObserver.h"
#import "FTSession.h"
#import "SubscriptionViewController.h"
#import "SubscriptionCell.h"
#import "SettingsViewController.h"

@interface SubscriptionViewController () <SKPaymentTransactionObserver>

@property (weak, nonatomic) IBOutlet UILabel *yourCurrentAccountLabel;
@property (weak, nonatomic) IBOutlet UILabel *fetchFrequencyLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberConnectionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *storageQuotaLabel;

@property (weak, nonatomic) NSString *yourCurrentAccountString;
@property (weak, nonatomic) NSString *fetchFrequencyString;
@property (weak, nonatomic) NSString *numberConnectionsString;

@property (weak, nonatomic) NSString  *frequency;
@property (nonatomic) NSInteger        maxConnections;
@property (weak, nonatomic) NSString  *maxStorage;
@property (weak, nonatomic) IBOutlet UIView *upgradeOptionsView;
@property (weak, nonatomic) IBOutlet UIView *manageAppleSubscriptionView;
@property (weak, nonatomic) IBOutlet UIView *manageFileThisSubscriptionView;

@property (weak, nonatomic) IBOutlet UIButton *premiumMonthlyButton;
@property (weak, nonatomic) IBOutlet UIButton *premiumAnnuallyButton;
@property (weak, nonatomic) IBOutlet UIButton *ultimateMonthlyButton;
@property (weak, nonatomic) IBOutlet UIButton *ultimateAnnuallyButton;

@property (strong, nonatomic) NSMutableDictionary *buttonsToProducts;
@property (strong, nonatomic) MBProgressHUD *loadingView;
@property BOOL isPurchasing;

@end


/*
 
 We have two different subscriptions:
 Premium
 Ultimate
 
 users can subscribe monthly or yearly
 A user can only one have one subscription active at a time.
 
 Once a user has a subscription, they can only manage it via 
 iTunes Store, so we redirect them to their Manage Subscriptions page.
 
 If a user has a web-created subscription, we redirect them to
 their web-account. WHY? WHY NOT RECREATE ACCOUNT UI HERE?
 
 If a user has no subscription, we offer the 2 subscription types 
 available as either monthly or annual subscriptions.
 
 So this all boils down to:
 
 If a user has an Apple subscription:
    - show "Manage Subscriptions" button
 else if user has FileThis subscription
    show message explaining and link to web site
 else
    show subscriptions
 
*/


@implementation SubscriptionViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidLoad {
    [self.navigationController setToolbarHidden:YES];
    self.loadingView = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    self.manageAppleSubscriptionView.hidden = YES;
    self.manageFileThisSubscriptionView.hidden = YES;
    self.yourCurrentAccountLabel.hidden = YES;
    self.fetchFrequencyLabel.hidden = YES;
    self.storageQuotaLabel.hidden = YES;
    self.numberConnectionsLabel.hidden = YES;
    
    // extract format strings
    self.yourCurrentAccountString = self.yourCurrentAccountLabel.text;
    self.fetchFrequencyString = self.fetchFrequencyLabel.text;
    self.numberConnectionsString = self.numberConnectionsLabel.text;
    
    self.buttonsToProducts = [NSMutableDictionary dictionary];
    BOOL ok = [self prepareButton:self.ultimateMonthlyButton forPlan:@"ultimate" withTitle:@"month"];
    if (ok && self.ultimateAnnuallyButton != nil)
        ok = [self prepareButton:self.ultimateAnnuallyButton forPlan:@"ultimate" withTitle:@"annual"];
    if (ok && self.premiumAnnuallyButton != nil)
        ok = [self prepareButton:self.ultimateAnnuallyButton forPlan:@"premium" withTitle:@"annual"];
    if (ok && self.premiumMonthlyButton != nil)
        ok = [self prepareButton:self.ultimateAnnuallyButton forPlan:@"premium" withTitle:@"month"];

    if (!ok) {
        NSString *message = NSLocalizedString(@"Cannot connect to iTunes Store.",nil);
        [[[UIAlertView alloc] initWithTitle:@"FileThis" message:message
            completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                // EXIT
                [self.navigationController popViewControllerAnimated:YES];
            }
            cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [self applyAccountSettings];

    [[SKPaymentQueue defaultQueue] addTransactionObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActive:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    //    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notified:) name:nil object:nil];

    // bring LoadingData HUD to front of list to avoid
    // being hidden by inserted views
    [self.view bringSubviewToFront:self.loadingView];
}

-(void)viewWillDisappear:(BOOL)animated {
    [[SKPaymentQueue defaultQueue] removeTransactionObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applyAccountSettings {
    // configure for user's account
    FTAccountSettings *settings = [FTSession sharedSession].settings;
    if (settings) {
        NSString *plan = settings.localizedServicePlan;
        if ([plan rangeOfString:@"Basic"].location != NSNotFound) {
            self.frequency = NSLocalizedString(@"once a week", @"");
            self.maxConnections = 6;
            self.maxStorage = NSLocalizedString(@"500MB", @"");
        } else if ([plan rangeOfString:@"Premium"].location != NSNotFound) {
            self.frequency = NSLocalizedString(@"once a week", @"");
            self.maxConnections = 12;
            self.maxStorage = NSLocalizedString(@"1GB", @"");
        } else if ([plan rangeOfString:@"Ultimate"].location != NSNotFound) {
            self.frequency = NSLocalizedString(@"every day", @"");
            self.maxConnections = 30;
            self.maxStorage = NSLocalizedString(@"10GB", @"");
        }
        BOOL hasAppleSubscription = settings.isSubscriber && settings.isApplePayment;
        BOOL hasFileThisSubscription = settings.isSubscriber && !hasAppleSubscription;
        BOOL showUpgrades = !hasFileThisSubscription && !hasAppleSubscription;
        
        self.manageAppleSubscriptionView.hidden = !hasAppleSubscription;
        self.manageFileThisSubscriptionView.hidden = !hasFileThisSubscription;
        
        if (self.yourCurrentAccountString)
            self.yourCurrentAccountLabel.text = [NSString stringWithFormat:self.yourCurrentAccountString, plan];
        if (self.fetchFrequencyString)
            self.fetchFrequencyLabel.text = [NSString stringWithFormat:self.fetchFrequencyString, self.frequency];
        if (self.numberConnectionsString)
            self.numberConnectionsLabel.text = [NSString stringWithFormat:self.numberConnectionsString, self.maxConnections];
        
        if (showUpgrades) {
            CGRect frame = self.upgradeOptionsView.frame;
            frame.size.width = self.view.frame.size.width;
            frame.origin.y += 170;
            self.upgradeOptionsView.frame = frame;
            [self.view addSubview:self.upgradeOptionsView];
            CGRect buttonFrame = self.ultimateMonthlyButton.titleLabel.frame;
            buttonFrame.size.width = frame.size.width;
            self.ultimateMonthlyButton.titleLabel.frame = buttonFrame;
            
            if (self.ultimateAnnuallyButton) {
                buttonFrame = self.ultimateAnnuallyButton.titleLabel.frame;
                buttonFrame.size.width = frame.size.width;
                self.ultimateAnnuallyButton.titleLabel.frame = buttonFrame;
            }
        }
        
        [self hideLoadingView];
    } else {
        self.loadingView.labelText = NSLocalizedString(@"Loading Data", @"loading data for subscription view");
        [self showLoadingView];
        self.manageAppleSubscriptionView.hidden = YES;
        self.manageFileThisSubscriptionView.hidden = YES;
    }
    
    self.yourCurrentAccountLabel.hidden = !settings;
    self.fetchFrequencyLabel.hidden = !settings;
    self.storageQuotaLabel.hidden = !settings;
    self.numberConnectionsLabel.hidden = !settings;
}

- (BOOL)prepareButton:(UIButton *)button forPlan:(NSString *)plan withTitle:(NSString *)title {
    for (SKProduct *product in [AppleStoreObserver sharedObserver].products) {
        NSString *d = product.productIdentifier;
        BOOL titleMatches = [d rangeOfString:title options:NSCaseInsensitiveSearch].location != NSNotFound;
        BOOL planMatches = [d rangeOfString:plan options:NSCaseInsensitiveSearch].location != NSNotFound;
        if (titleMatches && planMatches) {
            NSString *key = [NSString stringWithFormat:@"%d", button.hash];
            self.buttonsToProducts[key] = product;
            title = NSLocalizedString(title, @"button title in subscription window");
            button.titleLabel.text = [NSString stringWithFormat:@"%@ %@", product.localizedPrice, title];
            return YES;
        }
    }
    return NO;
}

#pragma mark Notification handlers for loading view

// remove Buy's Progress View when alert resigns application
- (void)willResignActive:(NSNotification *)notification {
    [self hideLoadingView];
}

// display Buy's loading view if during purchase
- (void)didBecomeActive:(NSNotification *)notification {
    if (self.isPurchasing)
        [self showLoadingView];
}

- (void)hideLoadingView {
    [self.loadingView hide:YES];
}

- (void)showLoadingView {
    [self.loadingView show:YES];
}

- (void)notified:(NSNotification *)notification {
    NSLog(@"NOTE: %@", notification.name);
}

- (void)dismiss {
    [self hideLoadingView];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark SKPaymentTransactionObserver delegate methods

// Sent when the transaction array has changed (additions or state changes).  Client should check state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions {
    BOOL done = NO;
    BOOL dismiss = NO;
    for (SKPaymentTransaction *transaction in transactions) {
        if (transaction.transactionState == SKPaymentTransactionStatePurchased) {
            dismiss = YES;
            done = YES;
            // save pending purchase in account settings for display in Settings view 
            FTAccountSettings *settings = [FTSession sharedSession].settings;
            [settings applyPayment:transaction];
        } else if (transaction.transactionState == SKPaymentTransactionStateFailed) {
            done = YES;
        }
    }
    
    if (done) {
        self.isPurchasing = NO;
        [self hideLoadingView];
    }
    
    if (dismiss)
        [self performSelectorOnMainThread:@selector(dismiss) withObject:nil waitUntilDone:NO];
}

/*
 You can link directly to the Manage Subscriptions page in the App Store without having to write your own manage subscriptions page. To do so, link to this URL: 
    https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions
 */

- (IBAction)manageAppleSubscription:(id)sender {
    NSString *s = @"https://buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions";
//#if SANDBOX
//    s = @"https://sandbox.itunes.apple.com/WebObjects/MZFinance.woa/wa/manageSubscriptions";
//#endif
    NSURL *manageSubscriptionsURL = [NSURL URLWithString:s];
    if (![[UIApplication sharedApplication] openURL:manageSubscriptionsURL]) {
        NSString *m = NSLocalizedString(@"I'm sorry I can't do that because an unexpected error has occurred", @"error opening manage Apple Subscription url");
        [[[UIAlertView alloc] initWithTitle:@"FileThis Error" message:m completionBlock:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}

- (IBAction)upgradeButtonPressed:(UIButton *)button {
    NSString *key = [NSString stringWithFormat:@"%d", button.hash];
    SKProduct *product = self.buttonsToProducts[key];
    SKPayment *payment = [SKPayment paymentWithProduct:product];
    NSLog(@"Purchasing %d subscription to %@...", payment.quantity, product.productIdentifier);
    self.loadingView.labelText = NSLocalizedString(@"Contacting iTunes Store", @"delay while payment connects to iTunes Store");
    self.isPurchasing = YES;
    [self showLoadingView];
    [[SKPaymentQueue defaultQueue] addPayment:payment];
}

#pragma mark Upgrade Actions

- (IBAction)premiumAnnually:(UIButton *)sender {
    [self upgradeButtonPressed:sender];
}
- (IBAction)premiumMonthly:(UIButton *)sender {
    [self upgradeButtonPressed:sender];
}
- (IBAction)ultimateMonthly:(UIButton *)sender {
    [self upgradeButtonPressed:sender];
}
- (IBAction)ultimateAnnually:(UIButton *)sender {
    [self upgradeButtonPressed:sender];
}

@end
