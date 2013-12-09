//
//  NewConnectionViewController.m
//  FileThis
//
//  Created by Cuong Le on 11/20/13.
//
//

#import "ConnectionViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <Crashlytics/Crashlytics.h>

#import "UIAlertView+BlockExtensions.h"
#import "UIKitExtensions.h"

#import "SettingsViewController.h"
#import "SubscriptionViewController.h"

#import "ConnectionSettingsViewController.h"
#import "ConnectionViewController.h"
#import "ConnectionCredentialsViewController.h"
#import "ConnectionErrorViewController.h"
#import "AddConnectionViewController.h"

#import "FTMobileAppDelegate.h"
#import "FTSession.h"
#import "FTConnection.h"
#import "FTQuestion.h"
#import "QuestionsController.h"

#import "LoadingView.h"
#import "ConnectionCell.h"
#import "AddConnectionCell.h"
#import "Constants.h"

@interface ConnectionViewController () <UIActionSheetDelegate, UIAlertViewDelegate, UITableViewDataSource, UITableViewDelegate> {
}

@property (strong) IBOutlet UITableView *connectionsTable;
@property (strong) LoadingView *loadingView;
@property (strong) FTSession *session;
@property (weak) id settingsObserver;
@property (strong, nonatomic) NSString *editString;
@end

@implementation ConnectionViewController

static NSString * const kConnectionCellIdentifier = @"ConnectionCellIdentifier";
static NSString * const kAddConnectionCellIdentifier = @"AddConnectionCellIdentifier";

BOOL refreshed = NO;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.toolbarHidden = NO;
    self.navigationItem.hidesBackButton = YES;
    
    self.session = [FTSession sharedSession];
    
    // customize top navigation bar
    [self.navigationItem setTitle:NSLocalizedString(@"Connections", @"title for connections view")];
    UIBarButtonItem *editButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
    [self.navigationItem setLeftBarButtonItem:editButton];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
    [self.navigationItem setRightBarButtonItem:addButton];
    
    // customize bottom bar
    [self configureToolbar];
    
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(dataChangedNotification:) name:FTListConnections object:NULL];
    [nc addObserver:self selector:@selector(dataChangedNotification:) name:FTListInstitutions object:NULL];
    [nc addObserver:self selector:@selector(gotQuestions:) name:FTGotQuestions object:NULL];
    [nc addObserver:self selector:@selector(answeredQuestion:) name:FTAnsweredQuestion object:NULL];
    [nc addObserver:self selector:@selector(connectionDeleted:) name:FTConnectionDeleted object:NULL];
    [nc addObserver:self selector:@selector(connectionUpdated:) name:FTUpdateConnection object:NULL];
    [nc addObserver:self selector:@selector(refreshInstitution:) name:FTInstitutionalLogoLoaded object:NULL];
    [nc addObserver:self selector:@selector(askUpgrade:) name:FTPremiumFeatureException object:nil];
    [nc addObserver:self selector:@selector(missingDestination:) name:FTMissingCurrentDestination object:nil];
    [nc addObserver:self selector:@selector(createConnectionFailed:) name:FTCreateConnectionFailed object:nil];
    
    [nc addObserver:self selector:@selector(fixDestination:) name:FTFixCurrentDestination object:nil];
    [nc addObserver:self selector:@selector(destinationConfigured:) name:FTCurrentDestinationUpdated object:nil];
    
    float topPadding, bottomPadding;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        topPadding = kIOS7ToolbarHeight;
        bottomPadding = kIOS7BottomBarHeight;
    } else {
        topPadding =  bottomPadding = 0;
    }
    self.connectionsTable = [[UITableView alloc] initWithFrame:CGRectMake(0, topPadding, self.view.frame.size.width, self.view.frame.size.height - topPadding - bottomPadding)];
    self.connectionsTable.rowHeight = 60.0;
    self.connectionsTable.separatorColor = [UIColor colorWithRed:0.7 green:0.85 blue:0.98 alpha:1.0];
    self.connectionsTable.delegate = self;
    self.connectionsTable.dataSource = self;
    self.connectionsTable.allowsSelectionDuringEditing = YES;
    [self.view addSubview:self.connectionsTable];
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    [[NSNotificationCenter defaultCenter] removeObserver:self.settingsObserver];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"ConnectionViewController viewWillAppear:");
    [self.navigationController setToolbarHidden:NO];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    if ([[FTSession sharedSession] connectionsLoaded] == NO)
        self.loadingView = [LoadingView loadingViewInView:self.connectionsTable];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"ConnectionViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self checkLoadingView:nil];
    
    float topPadding, bottomPadding;
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        topPadding = kIOS7ToolbarHeight;
        bottomPadding = kIOS7BottomBarHeight;
    } else {
        topPadding =  bottomPadding = 0;
    }
    self.connectionsTable.frame = CGRectMake(0, topPadding, self.view.frame.size.width, self.view.frame.size.height-topPadding-bottomPadding);
    [self.connectionsTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return YES;
}


#pragma mark UITableViewDataSource methods
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [[FTSession sharedSession] countConnections] + 1;
}

// TODO: ref LazyTableImages sample code <http://developer.apple.com/library/ios/#samplecode/LazyTableImages>
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSUInteger row = [indexPath row];
    UITableViewCell *result;
    
    if (row < [[FTSession sharedSession] countConnections])
    {
        //NSLog(@"ConnectionViewController - tableView:cellForRowAtIndexPath: %i", indexPath.row);
        ConnectionCell *cell = [tableView dequeueReusableCellWithIdentifier:kConnectionCellIdentifier];
        if (cell == nil) {
            cell = [[ConnectionCell alloc] initWithTableView:self.connectionsTable reuseIdentifier:kConnectionCellIdentifier];
        }
        FTConnection *connectionInfo = [[FTSession sharedSession] connectionAtIndex:row];
        [cell setConnection:connectionInfo withEditing:tableView.isEditing];
        cell.host = self;
        result = cell;
    } else {
        NSUInteger diff = row - [[FTSession sharedSession] countConnections];
        AddConnectionCell *cell = (AddConnectionCell*)[tableView dequeueReusableCellWithIdentifier:kAddConnectionCellIdentifier];
        if (cell == nil) {
            cell = [[AddConnectionCell alloc] initWithTableView:tableView reuseIdentifier:kAddConnectionCellIdentifier];
        }
        
        switch (diff) {
            case 0:
                break;
            case 2:
                break;
        }
        result = cell;
    }
    
    return result;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // try to delete
        if ([self.session deleteNthInstitutionConnection:indexPath.row]) {
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [tableView deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    if (tableView.isEditing == YES) {
        // refresh
        [self refreshConnection:indexPath withTableView:(UITableView *)tableView];
    } else {
        [self refreshConnection:indexPath withTableView:(UITableView *)tableView];
//        NSUInteger row = [indexPath row];
//        FTConnection *connection = [[FTSession sharedSession] connectionAtIndex:row];
//        if ([connection hasError] || [connection hasQuestion])
//        {
//            
//        } else {
//            NSLog(@"TODO: display details window");
//        }
//
    }
}

- (IBAction)accessoryButtonTapped:(id)sender withEvent:(id)event
{
	NSSet *touches = [event allTouches];
	UITouch *touch = [touches anyObject];
	CGPoint currentTouchPosition = [touch locationInView:self.connectionsTable];
	NSIndexPath *indexPath = [self.connectionsTable indexPathForRowAtPoint: currentTouchPosition];
	if (indexPath != nil)
	{
		[self tableView:self.connectionsTable accessoryButtonTappedForRowWithIndexPath: indexPath];
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    //NSLog(@"touched row %d", indexPath.row);
    NSUInteger row = [indexPath row];
    if ([self isConnectionCell:indexPath]) {
        FTConnection *connection = [[FTSession sharedSession] connectionAtIndex:row];
        if (tableView.isEditing) {
            [self performSegueWithIdentifier:@"editConnection" sender:connection];
        } else if (connection.hasQuestion) {
            ConnectionCell *cell = (ConnectionCell *)[tableView cellForRowAtIndexPath:indexPath];
            [self askQuestionsForConnectionCell:cell];
        } else if (connection.hasError) {
            ConnectionCell *cell = (ConnectionCell *)[tableView cellForRowAtIndexPath:indexPath];
            [self displayConnectionError:cell];
        }
    } else {
        NSUInteger diff = row - [[FTSession sharedSession] countConnections];
        switch (diff) {
            case 0:
                [self add:self];
                break;
            case 2:
                break;
        }
    }
    return NO;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self isConnectionCell:indexPath])
        return YES;
    else  // disable editing for our static "Add Connection" row
        return NO;
}

- (BOOL)isConnectionCell:(NSIndexPath *)path {
    return (path.row < [[FTSession sharedSession] countConnections]);
}

- (NSString *)lastUpdatedString {
    NSString        *dateString = [NSDateFormatter localizedStringFromDate:[NSDate date]
                                    dateStyle:NSDateFormatterNoStyle timeStyle:NSDateFormatterShortStyle];
    return [NSString stringWithFormat:@"Last updated at %@", dateString];
}

// TODO: cache UIBarButtonItem
- (UIBarButtonItem *) lastUpdatedBarButton {
    CGFloat width = 260.0f;
    CGFloat height = 21.0f;
    CGRect  frame = CGRectMake(0.0 , 11.0f, width, height);
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:frame];
    [titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
    [titleLabel setBackgroundColor:[UIColor clearColor]];
    //    [titleLabel setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [titleLabel setTextColor:[UIColor darkTextColor]];
    } else {
        [titleLabel setTextColor:[UIColor lightTextColor]];
    }
    
    [titleLabel setText:[self lastUpdatedString]];
    [titleLabel setTextAlignment:NSTextAlignmentCenter];
    
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
    return barButton;
}

//- (void) addLastUpdated {
//    NSMutableArray *items = [[self.toolbar items] mutableCopy];
//    [items insertObject:[self lastUpdatedBarButton] atIndex:2];
//    [self.toolbar setItems:items animated:NO];
//}
//
//- (void)configureToolbar {
//    NSMutableArray *items = [[self.toolbar items] mutableCopy];
//    if (items == nil) {
//        items = [[NSMutableArray alloc] init];
//    }
//    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh:)];
//    [items addObject:item];
//
//    UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//    [items addObject:spacer];
//
//    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0 , 11.0f, self.view.frame.size.width, 21.0f)];
//    [titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:10]];
//    [titleLabel setBackgroundColor:[UIColor clearColor]];
////    [titleLabel setTextColor:[UIColor colorWithRed:157.0/255.0 green:157.0/255.0 blue:157.0/255.0 alpha:1.0]];
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        [titleLabel setTextColor:[UIColor darkTextColor]];
//    } else {
//        [titleLabel setTextColor:[UIColor lightTextColor]];
//    }
//
//    [titleLabel setText:@"Last updated sometime."];
//    [titleLabel setTextAlignment:NSTextAlignmentCenter];
//
//    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithCustomView:titleLabel];
//    [items addObject:title];
//
//    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//        UIBarButtonItem *spacer2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
//        [items addObject:spacer2];
//
//        item = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(add:)];
//        [items addObject:item];
//    }
//
//    [self.toolbar setItems:items animated:NO];
//}

-(IBAction)tbd:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Not Yet Implemented"
                                                    message:@"Sorry. iPhone interface for adding is not yet done."
                                                   delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (IBAction)login:(UIStoryboardSegue *)segue
{
}

- (IBAction)cancel:(UIStoryboardSegue *)segue
{
#ifdef DEBUG
    NSLog(@"cancelled %@ from %@ to %@", segue.identifier, segue.sourceViewController, segue.destinationViewController);
    NSLog(@"navigation stack:%@", self.navigationController.viewControllers);
#endif
}

- (IBAction)save:(UIStoryboardSegue *)segue
{
    if ([segue.identifier isEqualToString:@"saveConnection"]) {
        ConnectionSettingsViewController *vc = segue.sourceViewController;
        [vc save];
    } else if ([segue.identifier isEqualToString:@"saveAccountSettings"]) {
        SettingsViewController *c = segue.sourceViewController;
        [c save];
    }
}

- (void)configureToolbar {
    NSString *title = NSLocalizedString(@"Account", @"button title");
    UIBarButtonItem *accountButton = [[UIBarButtonItem alloc]
                                      initWithTitle:title style:UIBarButtonItemStyleBordered
                                      target:self action:@selector(settings:)];
    title = NSLocalizedString(@"Logout", @"button title");
    UIBarButtonItem *logoutButton = [[UIBarButtonItem alloc]
                                     initWithTitle:title style:UIBarButtonItemStyleBordered
                                     target:self action:@selector(logout:)];
    UIBarButtonItem *flexibleSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *documentsButton;
    NSArray *items = @[accountButton, flexibleSpace, logoutButton];
    if ([FTSession sharedSession].currentDestination != nil && [[FTSession sharedSession].currentDestination canLaunchToDocuments]) {
        title = NSLocalizedString(@"Documents", @"Documents button title");
        documentsButton = [[UIBarButtonItem alloc]
                           initWithTitle:title style:UIBarButtonItemStyleBordered
                           target:self action:@selector(launchToDocuments:)];
        UIBarButtonItem *flexibleSpace2 = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        items = @[accountButton, flexibleSpace, documentsButton, flexibleSpace2, logoutButton];
    }
    
    [self setToolbarItems:items];
}

- (IBAction)destinationConfigured:(NSNotification *)notification
{
    [self configureToolbar];
}

- (IBAction)refresh:(id)sender {
    [self removeLoadingView];
    [self.connectionsTable reloadData];
    [self.connectionsTable setNeedsDisplay]; // repaint
}

#pragma mark - Actions
- (IBAction)add:(id)sender {
    AddConnectionViewController *addVC = [[AddConnectionViewController alloc] initWithNibName:nil bundle:nil];
    [addVC setCancelReceiver:self withAction:@selector(cancelAdd:)];
    [addVC setDoneReceiver:self withAction:@selector(didAdd:)];
    addVC.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:addVC animated:YES];
}

- (IBAction)edit:(UIBarButtonItem *)sender {
    BOOL editing = !self.connectionsTable.editing;
    [self.connectionsTable setEditing:editing animated:YES];
    
    NSString *animationType = kCATransitionFade;
    NSString *animationSubtype = kCATransitionFromLeft;
    if (!editing) {
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
        animationSubtype = kCATransitionFromLeft;
    }
    else
    {
        self.navigationItem.leftBarButtonItem =
        [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(edit:)];
        animationSubtype = kCATransitionFromRight;
    }
    
	// Set up the animation
	CATransition *animation = [CATransition animation];
	[animation setType:animationType];
	[animation setSubtype:animationSubtype];
    
//	[[self.tableView layer] addAnimation:animation forKey:@"layerAnimation"];
    
}

- (IBAction)settings:(id)sender {
    [self performSegueWithIdentifier:@"editAccountSettings" sender:sender];
}

- (IBAction)logout:(id)sender {
    [[FTSession sharedSession] logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)launchToDocuments:(id)sender {
    [[FTSession sharedSession].currentDestination launchApplication];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"LoginSeque"]) {
        [[FTSession sharedSession] logout];
    } else if ([segue.identifier isEqualToString:@"editConnection"]) {
        ConnectionSettingsViewController *vc = segue.destinationViewController;
        NSAssert1([[sender class] isSubclassOfClass: [FTConnection class]], @"should be FTConnection not %@", [sender class]);
        vc.connection = sender;
    }
}

#pragma mark - Callbacks

- (void)cancelAdd:(AddConnectionViewController *)addConnectionViewController {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didAdd:(AddConnectionViewController *)addConnectionViewController {
    //    [self.navigationController popToViewController:self animated:YES];
    [(FTMobileAppDelegate*)[UIApplication sharedApplication].delegate resetConnectionViewController];
}

- (void)removeLoadingView
{
    if (self.loadingView) {
        [self.loadingView removeView];
        self.loadingView = NULL;
    }
}

- (void)checkLoadingView:(id)sender
{
    if (self.loadingView != NULL) {
        // check to see if session has got back connections
        if ([[FTSession sharedSession] connectionsLoaded]) {
            [self removeLoadingView];
        } else {
            [self performSelector:@selector(checkLoadingView:) withObject:nil afterDelay:0.5];
        }
    }
}

- (void)dataChangedNotification:(NSNotification *)notification {
    if (!refreshed) {
#ifdef DEBUG
        NSLog(@"Connections loaded in %f seconds. ", CFAbsoluteTimeGetCurrent() - gStartTime);
#endif
        refreshed = YES;
    }
#ifdef DEBUG
    NSLog(@"%@ changed. Refreshing table", notification.name);
#endif
    [self performSelectorOnMainThread:@selector(refresh:) withObject:nil waitUntilDone:NO];
}

- (IBAction)questionCancelled:(FTQuestion *)question {
#ifdef DEBUG
    NSLog(@"question %@ cancelled", question);
#endif
}

- (IBAction)questionAnswered:(FTQuestion *) question forConnection:(FTConnection *) connection {
}


#pragma mark - Connection Settings
-(void)editConnection:(FTConnection *)connection {
    UIStoryboard *storyboard = [UIApplication sharedApplication].delegate.window.rootViewController.storyboard;
    ConnectionSettingsViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ConnectionSettings"];
    vc.connection = connection;
    vc.modalPresentationStyle = UIModalPresentationFormSheet;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma  mark - Notification listeners
// TODO: does this belong in FTSession?
- (void)gotQuestions:(NSNotification *)notification {
    NSArray *questions = notification.object;
    for (FTQuestion *question in questions) {
        FTConnection *connection = [self.session findConnectionById:question.connectionId];
        NSAssert1(connection != nil, @"couldn't find connection with id=%d?", question.connectionId);
        [connection addQuestion:question];
    }
}

- (void)answeredQuestion:(NSNotification *)notification {
    [[FTSession sharedSession] requestConnectionsList];
}

- (void)removeConnection:(FTConnection *)connection {
    assert([NSThread isMainThread]);
    NSInteger numConnections = self.session.countConnections;
    for (NSInteger row = 0; row != numConnections; row++) {
        FTConnection *c = [self.session connectionAtIndex:row];
        if (connection.connectionId == c.connectionId)
        {
            [self.session removeConnectionAtIndex:row];
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
            NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
            [self.connectionsTable deleteRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
            return;
        }
    }
    
    NSAssert(NO, @"Couldn't find row containing connection to delete. Connection=%@", connection.key);
}

- (void)connectionDeleted:(NSNotification *)notification {
    FTConnection *connection = notification.object;
    [self performSelectorOnMainThread:@selector(removeConnection:) withObject:connection waitUntilDone:NO];
}

- (void)connectionUpdated:(NSNotification *)notification {
    FTConnection *connection = notification.object;
    NSMutableArray *indices = [NSMutableArray arrayWithCapacity:[FTSession sharedSession].connections.count];
    [[FTSession sharedSession].connections
        enumerateObjectsUsingBlock: ^(FTConnection *conn, NSUInteger idx, BOOL *stop) {
            if (connection.connectionId == conn.connectionId) {
                [indices addObject:[NSIndexPath indexPathForItem:idx inSection:0]];
            }
        }];
    NSAssert([NSThread isMainThread], @"running on main thread");
    [self.connectionsTable reloadRowsAtIndexPaths:indices withRowAnimation:UITableViewRowAnimationFade];
}

- (void)refreshInstitution:(NSNotification *)notification {
    FTInstitution *refreshedInstitution = notification.object;
    int c = [[FTSession sharedSession] countConnections];
    while (c-- > 0) {
        FTConnection *connection = [[FTSession sharedSession] connectionAtIndex:c];
        NSAssert1(connection.institutionId != 0,
                  @"connection.institutionId is 0? %@",
                  connection);
        if (connection.institutionId == refreshedInstitution.institutionId) {
            NSArray *indexPaths = @[ [NSIndexPath indexPathForRow:c inSection:0] ];
            [self.connectionsTable reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationFade];
        }
    }
}

- (void)askToUpgrade:(NSString *)title withMessage:(NSString *)message withButton:(NSString *)buttonTitle {
    dispatch_block_t block = ^{
        [[[UIAlertView alloc] initWithTitle:title message:message completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
            if (buttonIndex == 1) {
                // if User has Premium, they cannot upgrade to Ultimate.
                // Have them send Brian and email for now.
                //                    TFLog(@"User %@ has ");
                // If user is Basic, then take them to upgrade page...
                SubscriptionViewController *subscriptionView = [[SubscriptionViewController alloc] init];
                [self.navigationController pushViewController:subscriptionView animated:YES];
            }
        } cancelButtonTitle:@"Cancel" otherButtonTitles:buttonTitle, nil] show];
    };
    runOnMainQueueWithoutDeadlocking(block);
}

- (void)askUpgrade:(NSNotification *)sender
{
    NSString *message = sender.object[@"errorMessage"];
    NSString *title = NSLocalizedString(@"Cannot Add Connection", @"alert title");
    NSString *button = NSLocalizedString(@"Upgrade", @"button title");
    [self askToUpgrade:title withMessage:message withButton:button];
}

- (void)missingDestination:(NSNotification *)notification {
    NSString *title = NSLocalizedString(@"Configure Destination", @"alert title when missing destination");
    NSString *m = NSLocalizedString(@"please configure your destination", @"missing destination");
    dispatch_block_t b = ^{
        [[[UIAlertView alloc] initWithTitle:title message:m
            completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                if (buttonIndex == 1) {
                    [self performSegueWithIdentifier:@"pickDestination" sender:self];
                }
            }
          cancelButtonTitle:@"Cancel" otherButtonTitles:@"Configure", nil] show];
    };
    runOnMainQueueWithoutDeadlocking(b);
}

- (void)fixDestination:(NSNotification *)notification {
    FTDestinationConnection *currentDestination = notification.object;
    NSString *title = NSLocalizedString(@"Configure Destination", @"alert title for fix destination");
    
    NSString *message = nil;
    if (currentDestination.needsAuthentication)
        message = [NSString stringWithFormat:@"We cannot connect to your %@ account. Please reauthenticate your account.", currentDestination.name];
    else {
        message = [NSString stringWithFormat:@"We cannot connect to your %@ account. %@. Please reauthenticate your account.", currentDestination.name, currentDestination.errorDescription];
    }
    
    dispatch_block_t block = ^{
        [[[UIAlertView alloc] initWithTitle:title message:message
            completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                if (buttonIndex == 1) {
                    [self performSegueWithIdentifier:@"pickDestination" sender:self];
                }
            }
            cancelButtonTitle:@"Cancel" otherButtonTitles:@"Fix it", nil] show];
    };
    runOnMainQueueWithoutDeadlocking(block);
}

- (void)createConnectionFailed:(NSNotification *)notification {
    NSString *title = NSLocalizedString(@"Cannot Add Connection", "alert title when create connection fails");
    NSString *exception = notification.userInfo[@"errorType"];
    if ([exception isEqualToString:FTAccountExpiredException]) {
        NSString *message;
        message = NSLocalizedString(@"Cannot add connection because subscription expired.", @"error message");
        NSString *button = NSLocalizedString(@"Subscribe", @"button title after failing to add connection because account expired");
        [self askToUpgrade:title withMessage:message withButton:button];
    } else {
        NSString *m;
        NSString *sequeIdentifier = nil;
        NSString *otherButtonTitle = nil;
        if ([exception isEqualToString:FTDestinationNotReadyException]) {
            m = NSLocalizedString(@"Adding a new connection failed because you haven't configured your cloud file storage. Please configure your preferred service.", nil);
            otherButtonTitle = @"Configure";
            sequeIdentifier = @"pickDestination";
        } else {
            m = [NSString stringWithFormat:@"Adding a new connection failed for an unexpected reason: %@", notification.userInfo[@"errorMessage"]];
        }
        
        dispatch_block_t block = ^{
            [[[UIAlertView alloc] initWithTitle:title message:m
                                completionBlock:^(NSUInteger buttonIndex, UIAlertView *alertView) {
                                    if (buttonIndex == 1) {
                                        [self performSegueWithIdentifier:sequeIdentifier sender:self];
                                    }
                                }
                              cancelButtonTitle:@"Cancel" otherButtonTitles:otherButtonTitle, nil] show];
        };
        runOnMainQueueWithoutDeadlocking(block);
    }
}

- (void)refreshConnection:(NSIndexPath *)indexPath withTableView:(UITableView *)tableView {
    NSUInteger row = [indexPath row];
    FTConnection *connection = [[FTSession sharedSession] connectionAtIndex:row];
    
    if ([connection hasQuestion]) {
    
    } else if ([connection hasError]) {
#ifdef DEBUG
        NSLog(@"put up dialog asking question...");
#endif
    } else {
        [connection refetch];
    }
}

- (void)displayConnectionError:(ConnectionCell *)cell
{
    FTConnection *connection = cell.connection;
    ConnectionErrorViewController *errorAlert = [[ConnectionErrorViewController alloc] initWithNibName:nil bundle:nil];
    [errorAlert setConnection:connection];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        errorAlert.popover = [[UIPopoverController alloc] initWithContentViewController:errorAlert];
        errorAlert.popover.delegate = errorAlert;
#ifdef DEBUG
        NSLog(@"error alert is %@", NSStringFromCGRect(errorAlert.view.frame));
#endif
        errorAlert.popover.popoverContentSize = CGSizeMake(320., 400);
        CGRect r = cell.frame;
        [errorAlert.popover presentPopoverFromRect:r inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        errorAlert.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        errorAlert.modalPresentationStyle = UIModalPresentationFullScreen;
        [self presentViewController:errorAlert animated:YES completion:nil];
    }
    
    //
    //    NSString *s2 = NSLocalizedString(@"We are unable to log in to your account. Please log in to your account %@ and make sure you are able to see your documents and then try again.", @"displayed when connection has error");
    //    FTInstitution *institution = [[FTSession sharedSession] institutionWithId:connection.institutionId];
    //    NSString *message = [NSString stringWithFormat:s2, institution.homePageAddress];
    //    NSString *title = [NSString stringWithFormat:@"%@", connection.name];
    //    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
    //    // @"Delete Connection", @"Try Again",
    //    [alert show];
}

-(IBAction)askQuestionsForConnectionCell:(ConnectionCell *)cell {
    FTConnection *connection = cell.connection;
    if ([connection.questions count] != 0) {
        
        //            // Setup the popover for use in the detail view.
        //            _popover = [[UIPopoverController alloc] initWithContentViewController:content];
        //            _popover.popoverContentSize = CGSizeMake(320., 548.);
        //            _popover.delegate = self;
        //
        //            self.credentialsViewController = content;
        CGRect rowRect = cell.frame;
//        rowRect.origin.x = rowRect.size.width - 120;
//        rowRect.origin.y += rowRect.size.height / 2;
        rowRect.size.width = cell.nameLabel.frame.origin.x - cell.frame.origin.x;
        
        [QuestionsController askQuestions:connection.questions
                       fromViewController:self
                                 fromRect:rowRect
                            forConnection:connection
                               withAction:@selector(questionAnswered:forConnection:)
                         withCancelAction:@selector(questionCancelled:)];
    } else if (connection.hasError) {
        [self displayConnectionError:cell];
    }
}

-(IBAction)popViewController:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(IBAction)dismissViewController:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

//#pragma mark -
//#pragma mark IASKSettingsDelegate protocol
//- (void)settingsViewControllerDidEnd:(IASKAppSettingsViewController*)sender {
//    if (sender == [self.navigationController topViewController])
//        [self.navigationController popViewControllerAnimated:YES];
//    else
//        [self dismissViewControllerAnimated:YES completion:nil];
//}
//
//- (UIView *)settingsViewController:(id<IASKViewController>)settingsViewContoller
//                         tableView:(UITableView *)tableView
//           viewForHeaderForSection:(NSInteger)section
//{
//    NSString* key = [settingsViewContoller.settingsReader keyForSection:section];
//	if ([key isEqualToString:@"ConnectionLogo"])
//    {
//        NSString *s = [settingsViewContoller.settingsReader dataSource][section][kIASKSectionHeaderIndex][@"ImageName"];
//        NSString *imageName = s != nil ? s : @"Icon.png";
//		UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
//		imageView.contentMode = UIViewContentModeCenter;
//		return imageView;
//	} else if ([key isEqualToString:@"IASKCustomHeaderStyle"]) {
//        UILabel* label = [[UILabel alloc] initWithFrame:CGRectZero];
//        label.backgroundColor = [UIColor clearColor];
//        label.textAlignment = NSTextAlignmentCenter;
//        label.textColor = [UIColor redColor];
//        label.shadowColor = [UIColor whiteColor];
//        label.shadowOffset = CGSizeMake(0, 1);
//        label.numberOfLines = 0;
//        label.font = [UIFont boldSystemFontOfSize:16.f];
//
//        //figure out the title from settingsbundle
//        label.text = [settingsViewContoller.settingsReader titleForSection:section];
//
//        return label;
//    }
//	return nil;
//}


#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
#ifdef DEBUG
    NSLog(@"button #%d clicked in alert", buttonIndex);
#endif
}

#pragma mark - UIActionSheetDelegate methods

// Called when a button is clicked. The view will be automatically dismissed after this call returns
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
#ifdef DEBUG
    NSLog(@"button #%d clicked in action sheet", buttonIndex);
#endif
}

//// Called when we cancel a view (eg. the user clicks the Home button). This is not called when the user clicks the cancel button.
//// If not defined in the delegate, we simulate a click in the cancel button
//- (void)actionSheetCancel:(UIActionSheet *)actionSheet;
//
//- (void)willPresentActionSheet:(UIActionSheet *)actionSheet;  // before animation and showing view
//- (void)didPresentActionSheet:(UIActionSheet *)actionSheet;  // after animation
//
//- (void)actionSheet:(UIActionSheet *)actionSheet willDismissWithButtonIndex:(NSInteger)buttonIndex; // before animation and hiding view
//- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex;  // after animation


#pragma mark - Debugging methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef DEBUG
    NSLog(@"touches began(%@) with %@", touches, event);
#endif
    [super touchesBegan:touches withEvent:event];  //let the tableview handle cell selection
    //    [self.nextResponder touchesBegan:touches withEvent:event]; // give the controller a chance for handling touch events
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef DEBUG
    NSLog(@"touchesEnded(%@) with %@", touches, event);
#endif
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
#ifdef DEBUG
    NSLog(@"touches cancelled(%@) with %@", touches, event);
#endif
    [super touchesCancelled:touches withEvent:event];
}

@end
