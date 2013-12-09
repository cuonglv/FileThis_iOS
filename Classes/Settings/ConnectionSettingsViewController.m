//
//  ConnectionSettingsViewController.m
//  FileThis
//
//  Created by Drew Wilson on 1/22/13.
//
//

#import <Crashlytics/Crashlytics.h>
#import "UIKitExtensions.h"

#import "FTConnection.h"
#import "FTInstitution.h"
#import "FTSession.h"

#import "ConnectionSettingsViewController.h"

@interface ConnectionSettingsViewController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *institutionLogo;
@property (weak, nonatomic) IBOutlet UILabel *categoryName;
@property (weak, nonatomic) IBOutlet UILabel *institutionName;
@property (weak, nonatomic) IBOutlet UITextField *nickname;
@property (weak, nonatomic) IBOutlet UITextField *userId;
@property (weak, nonatomic) IBOutlet UITextField *passwordField;
@property (weak, nonatomic) IBOutlet UILabel *lastFetchedOutlet;
@property (weak, nonatomic) IBOutlet UISwitch *fetchAllDocumentsOutlet;
@property (weak, nonatomic) IBOutlet UILabel *lastCheckedOutlet;
@property (weak, nonatomic) IBOutlet UITextView *statusOutlet;
@property (weak, nonatomic) IBOutlet UILabel *fetchEveryOutlet;
@property (weak, nonatomic) IBOutlet UILabel *numDocumentsFetchedOutlet;

@end

@implementation ConnectionSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.hidesBottomBarWhenPushed = YES;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.navigationController setToolbarHidden:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    CLS_LOG(@"ConnectionSettingsViewController viewWillAppear:");
    // Observe keyboard hide and show notifications to resize the text view appropriately.
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldBeginEditing:) name:UITextFieldTextDidBeginEditingNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldEndEditing:) name:UITextFieldTextDidEndEditingNotification object:nil];

    [self configureView];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"ConnectionSettingsViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)configureView
{
    FTInstitution *institution = [[FTSession sharedSession] institutionWithId:self.connection.institutionId];
    [self.institutionLogo setImageWithURL:institution.logoURL placeholderImage:[FTInstitution placeholderImage] cached:YES];
    self.categoryName.text = institution.type;
    self.institutionName.text = institution.name;
    self.nickname.text = self.connection.name;
    self.userId.text = self.connection.username;
    self.lastFetchedOutlet.text = self.connection.lastFetched;
    self.fetchAllDocumentsOutlet.on = self.connection.fetchAll;
    self.lastCheckedOutlet.text = self.connection.lastChecked;
    self.statusOutlet.text = self.connection.detailedText;
    self.fetchEveryOutlet.text = self.connection.fetchFrequency;
    self.numDocumentsFetchedOutlet.text = [NSString stringWithFormat:@"%ld",
            self.connection.documentCount];
}

- (void)save
{
    // update writable values and save
    self.connection.name = self.nickname.text;
    self.userId.text = self.connection.username;
    self.connection.fetchAll = self.fetchAllDocumentsOutlet.on;
    if (self.passwordField.text.length != 0)
        self.connection.password = self.passwordField.text;

    [self.connection save];
}


//#pragma mark -
//#pragma mark Responding to keyboard events
//
//- (void)keyboardWillShow:(NSNotification *)notification {
//    // Reduce the size of the grid view so that it's not obscured by the keyboard.
//    NSDictionary *userInfo = [notification userInfo];
//    CGRect endKeyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
//    CGRect beginKeyboardRect = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    double duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey]
//                       doubleValue];
//    
//    int height = endKeyboardRect.size.height;
//    NSLog(@"beginR(%@) -> endR(%@)", NSStringFromCGRect(endKeyboardRect), NSStringFromCGRect(beginKeyboardRect));
//    
//    UIEdgeInsets insets = self.tableView.contentInset;
//    insets.bottom += height;
//
//    CGRect newFrame = self.tableView.frame;
//    newFrame.size.height -= height;
//
//    [UIView animateWithDuration:duration animations:^{
////        self.tableView.contentInset = insets;
//        NSLog(@"shrinking table frame from %@ to %@, scroll rect into view %@",
//              NSStringFromCGRect(self.tableView.frame), NSStringFromCGRect(newFrame), NSStringFromCGRect(self.activeTextField.frame));
//        self.tableView.frame = newFrame;
//        NSLog(@"size=%@, offset=%@, insets=%@",
//              NSStringFromCGSize(self.tableView.contentSize),
//              NSStringFromCGPoint(self.tableView.contentOffset),
//              NSStringFromUIEdgeInsets(self.tableView.contentInset));
//        CGRect r = [self.activeTextField convertRect:self.activeTextField.frame fromView:nil];
//        CGRect r2 = [self.tableView convertRect:r fromView:nil];
//        [self.tableView scrollRectToVisible:r2 animated:YES];
//    }];
//}
////    UIEdgeInsets e = UIEdgeInsetsMake(0, 0, height, 0);
////    [[self tableView] setScrollIndicatorInsets:e];
////    [[self tableView] setContentInset:e];
//
//- (void)keyboardWillHide:(NSNotification *)notification {
//    // Enlarge the grid view when keyboard disappears.
//    NSDictionary* userInfo = [notification userInfo];
//    CGRect beginKeyboardRect = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
//    
//    CGRect newFrame = self.tableView.frame;
//    newFrame.size.height += beginKeyboardRect.size.height;
//    
//    self.tableView.frame = newFrame;
//}

//#pragma mark - Table view data source
//
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//#warning Potentially incomplete method implementation.
//    // Return the number of sections.
//    return 0;
//}
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//#warning Incomplete method implementation.
//    // Return the number of rows in the section.
//    return 0;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"Cell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    
//    // Configure the cell...
//    
//    return cell;
//}
//
/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
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

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"highlighted row %d", indexPath.row);
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"should highlight row %d", indexPath.row);
    return NO;
}

//- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    NSLog(@"should highlight row %d", indexPath.row);
//}
//

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef DEBUG
    NSLog(@"selected row %d", indexPath.row);
#endif
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
#ifdef DEBUG
    NSLog(@"selected cell %@", cell);
#endif
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark UITextFieldDelegate methods

//- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField;        // return NO to disallow editing.
//- (void)textFieldDidBeginEditing:(UITextField *)textField;           // became first responder
//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField;          // return YES to allow editing to stop and to resign first responder status. NO to disallow the editing session to end
//- (void)textFieldDidEndEditing:(UITextField *)textField;             // may be called if forced even if shouldEndEditing returns NO (e.g. view removed from window) or endEditing:YES called
//
//- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;   // return NO to not change text
//
//- (BOOL)textFieldShouldClear:(UITextField *)textField;               // called when clear button pressed. return NO to ignore (no notifications)

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.nickname) {
        [self.userId becomeFirstResponder];
    } else if (textField == self.userId) {
        [self.passwordField becomeFirstResponder];
    } else
        [textField resignFirstResponder];
    return NO;
}

//- (void)textFieldBeginEditing:(NSNotification *)notification
//{
//    self.activeTextField = notification.object;
//    NSLog(@"begin editing on %@", self.activeTextField);
//}
//
//- (void)textFieldDidChange:(NSNotification *)notification
//{
//    self.activeTextField = notification.object;
//    NSLog(@"did change on %@", self.activeTextField);
//}
//
//- (void)textFieldEndEditing:(NSNotification *)notification
//{
//    self.activeTextField = notification.object;
//    NSLog(@"end editing on %@", self.activeTextField);
//}

@end
