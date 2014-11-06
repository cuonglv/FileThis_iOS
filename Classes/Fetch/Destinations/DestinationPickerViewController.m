//
//  DestinationsListViewController.m
//  FileThis
//
//  Created by Drew Wilson on 1/6/13.
//
//

#import <Crashlytics/Crashlytics.h>
#import "DestinationCell.h"
#import "DestinationPickerViewController.h"
#import "DestinationConfirmationViewController.h"
#import "FTSession.h"
#import "UIImageView+AFNetworking.h"
#import "AuthenticateDestinationViewController.h"

@interface DestinationPickerViewController ()
@property (copy) NSArray *destinations;
@property (copy, nonatomic) NSIndexPath *checkedRow;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *nextButton;
@end

@implementation DestinationPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //    self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)viewWillAppear:(BOOL)animated
{
    CLS_LOG(@"DestinationPickerViewController viewWillAppear: - current destination id: %i, name: %@", self.destination.destinationId, self.destination.name);
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    self.navigationItem.hidesBackButton = self.hidesBackButton;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadDestinations:) name:FTListDestinations object:nil];
    self.nextButton.enabled = NO;
    [self loadDestinations:nil];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    CLS_LOG(@"DestinationPickerViewController viewWillDisappear:");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// application actions
- (void)loadDestinations:(NSNotification *)notification
{
    self.destinations = [FTSession sharedSession].destinations;

    // sync list with current selection
    if (self.destination) {
        [self.destinations enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (((FTDestination *)obj).destinationId == self.destination.destinationId) {
                self.checkedRow = [NSIndexPath indexPathForRow:idx inSection:0];
                *stop = YES;
            }
        }];
    }
    [self.tableView reloadData];
}

- (IBAction)cancel:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelPickingDestination:(UIStoryboardSegue *)segue
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)donePickingDestination:(UIStoryboardSegue *)segue;
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.destinations.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"DestinationCandidate";
    DestinationCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    FTDestination *dest = self.destinations[indexPath.row];
    [cell configure: dest];
    if ([indexPath isEqual:self.checkedRow])
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return NSLocalizedString(@"Please select a destination",
                             @"instructions in Destination Picker");
}

//- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
//{
//    return NSLocalizedString(@"Some more text could go here",
//                             @"footer in Destination Picker");
//}
//
- (void)setCheckedRow:(NSIndexPath *)checkedRow {
    //NSIndexPath *oldIndexPath = _checkedRow;
    _checkedRow = checkedRow;
    //if (oldIndexPath != nil)
        //[self.tableView reloadRowsAtIndexPaths:@[oldIndexPath] withRowAnimation:UITableViewRowAnimationFade];
    if (checkedRow != nil) {
        self.destination = [self.destinations objectAtIndex:checkedRow.row];
        self.nextButton.enabled = YES;
        self.nextButton.style = UIBarButtonItemStyleDone;
        //[self.tableView reloadRowsAtIndexPaths:@[_checkedRow] withRowAnimation:UITableViewRowAnimationFade];
    } else {
        self.destination = nil;
        self.nextButton.enabled = NO;
        self.nextButton.style = UIBarButtonItemStylePlain;
    }
    
    [self.tableView reloadData];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"confirmDestination"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        int row = indexPath.row;
        FTDestination *dest = [self.destinations objectAtIndex:row];
        DestinationConfirmationViewController *confirm = segue.destinationViewController;
        confirm.destinationId = dest.destinationId;
    }
}

@end
