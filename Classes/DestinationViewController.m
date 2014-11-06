//
//  DestinationViewController.m
//  FileThis
//
//  Created by Cuong Le on 12/11/13.
//
//

#import "DestinationViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "DestinationConfirmationViewController.h"
#import "FTSession.h"
#import "UIImageView+AFNetworking.h"
#import "AuthenticateDestinationViewController.h"
#import "CommonVar.h"
#import "FTMobileAppDelegate.h"
#import "CommonDataManager.h"
#import "CommonFunc.h"

#define kDestinationViewController_WarningAuthorizationTag  100

@interface DestinationViewController ()
@property (assign) BOOL authorizationError;
@end

@implementation DestinationViewController

static BOOL goFromFixIt = NO;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)initializeScreen {
    [super initializeScreen];
    
    self.selectedDestinationId = -1;
    self.titleLabel.text = @"Destination";
    self.descriptionLabel = [CommonLayout createLabel:CGRectMake(20, 20, 400, 30) fontSize:FontSizeLarge isBold:NO isItalic:YES textColor:kTextGrayColor backgroundColor:nil text:@"Please select a destination" superView:self.contentView];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.descriptionLabel.frame = CGRectMake(10, 0, 310, 50);
        self.descriptionLabel.font = [CommonLayout getFont:FontSizeSmall isBold:NO isItalic:YES];
    }
    
    float paddingLeft = 10.0;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        paddingLeft = 0;
    }
    self.myTable = [[UITableView alloc] initWithFrame:CGRectMake(paddingLeft, 50, self.view.frame.size.width - 2 * paddingLeft, self.view.frame.size.height - 50 - paddingLeft)];
    self.myTable.backgroundColor = [UIColor whiteColor];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        self.myTable.rowHeight = 60.0;
    else
        self.myTable.rowHeight = 80.0;
    
    self.myTable.separatorColor = kBorderLightGrayColor;
    self.myTable.delegate = self;
    self.myTable.dataSource = self;
    [self.contentView addSubview:self.myTable];
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"DestinationPickerViewController viewWillAppear:");
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestination:) name:FTCurrentDestinationUpdated object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateDestination:) name:FTFixCurrentDestination object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDestinations:) name:FTListDestinations object:nil];
    self.nextButton.enabled = NO;
    [self loadDestinations:nil];
    //[super viewWillAppear:animated]; //Removed by Loc
}

- (void)viewDidAppear:(BOOL)animated {
    if (goFromFixIt) {
        goFromFixIt = NO;
    } else if (self.authorizationError) {
        [CommonLayout showAlertMessageWithTitle:NSLocalizedString(@"ID_DESTINATION_NEEDS_ATTENTION", @"") content:[NSString stringWithFormat:NSLocalizedString(@"ID_DESTINATION_WARNING_MESSAGE", @""),[FTSession sharedSession].currentDestination.name] delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitle:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    CLS_LOG(@"DestinationPickerViewController viewWillDisappear:");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)relayout {
    [super relayout];
    [self.myTable setRightWithoutChangingLeft:self.contentView.frame.size.width-[self.myTable left] bottomWithoutChangingTop:self.contentView.frame.size.height-[self.myTable left]];
    [self.myTable reloadData];
}

- (BOOL)shouldHideToolBar {
    return YES;
}

#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.destinations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"menuCell";
    
    MyDestinationCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[[CommonFunc idiomClassWithName:@"MyDestinationCell"] alloc] initWithTable:self.myTable reuseIdentifier:cellIdentifier];
    }
    FTDestination *dest = self.destinations[indexPath.row];
    [cell configure:dest selected:[indexPath isEqual:self.checkedRow] authorizationError:self.authorizationError];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    int row = indexPath.row;
    FTDestination *dest = [self.destinations objectAtIndex:row];
    DestinationConfirmationViewController *confirm = [[CommonVar storyboard] instantiateViewControllerWithIdentifier:@"DestinationConfirm"];
    confirm.destinationId = dest.destinationId;
    [self.navigationController pushViewController:confirm animated:YES];
}

#pragma mark - Notification handlers
- (void)updateDestination:(NSNotification *)notification {
    [self loadDestinations:nil];
    [((FTMobileAppDelegate*)[UIApplication sharedApplication].delegate) clearData]; //to refresh later
    if ([[FTSession sharedSession] isUsingFTDestination]) {
        [[CommonDataManager getInstance] loadCommonData];
    }
}

#pragma mark - MyFunc
- (void)loadDestinations:(NSNotification *)notification {
    self.authorizationError = NO;
    self.destinations = [[NSMutableArray alloc] init];
    for (FTDestination* dest in [FTSession sharedSession].destinations) {
        if (self.selectedDestinationId != dest.destinationId)
            if ([dest.provider isEqualToString:@"this"] && [dest.type isEqualToString:@"locl"]) //not include FileThis Desktop (if this is not current selected destination)
                continue;
        
        [self.destinations addObject:dest];
    }
    
    FTDestinationConnection *desCon = [FTSession sharedSession].currentDestination;
    if (desCon) {
        self.selectedDestinationId = desCon.destinationId;
        if (desCon.needsAuthentication || desCon.needsRepair) {
            self.authorizationError = YES;
        }
    } else
        self.selectedDestinationId = -1;
    
    [self.myTable reloadData];
    
    // sync list with current selection
    if (self.selectedDestinationId >= 0) {
        [self.destinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (((FTDestination *)obj).destinationId == self.selectedDestinationId) {
                self.checkedRow = [NSIndexPath indexPathForRow:idx inSection:0];
                *stop = YES;
            }
        }];
    }
}

- (void)setCheckedRow:(NSIndexPath *)checkedRow {
    //NSIndexPath *oldIndexPath = _checkedRow;
    _checkedRow = checkedRow;
    //if (oldIndexPath != nil)
    //    [self.myTable reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    if (checkedRow != nil) {
        FTDestination *destination = [self.destinations objectAtIndex:checkedRow.row];
        self.selectedDestinationId = destination.destinationId;
        self.nextButton.enabled = YES;
        self.nextButton.style = UIBarButtonItemStyleDone;
        //if (_checkedRow.row >= 0 && _checkedRow.row < [self.destinations count])
        //    [self.myTable reloadRowsAtIndexPaths:@[_checkedRow] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        self.selectedDestinationId = -1;
        self.nextButton.enabled = NO;
        self.nextButton.style = UIBarButtonItemStylePlain;
    }
    [self.myTable reloadData];
}

+ (void)setGoFromFixIt:(BOOL)val {
    goFromFixIt = val;
}
@end
