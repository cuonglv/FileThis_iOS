//
//  AddConnectionViewController.m
//  FileThis
//
//  Created by Drew on 5/1/12.
//  Copyright (c) 2012 filethis.com. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "AddConnectionViewController.h"
#import "InstitutionCollectionViewCell.h"
#import "FTSession.h"
#import "FTInstitution.h"
#import "FTMobileAppDelegate.h"
#import "ConnectionCredentialsViewController.h"
#import "Constants.h"   //Cuong
#import "CommonLayout.h"

@interface AddConnectionViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *institutionsCollection;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstrant;
@property (weak, nonatomic) IBOutlet UISegmentedControl *segmentScope;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;


@property (strong, nonatomic) ConnectionCredentialsViewController *credentialsViewController;
@property (strong, nonatomic) UIPopoverController *popover;
@property (strong) NSArray *allInstitutions;
@property (strong) NSMutableArray *activeInstitutions;
@property (strong) NSArray *latestInstitutions;
@property (strong) NSArray *popularInstitutions;
@property (strong) NSArray *financialInstitutions;
@property (strong) NSArray *utilitiesInstitutions;
@end

@implementation AddConnectionViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        NSIndexSet *indices = [[FTSession sharedSession].institutions
    indexesOfObjectsPassingTest:
        ^BOOL(FTInstitution *institution, NSUInteger idx, BOOL *stop) {
                return institution.enabled;
        }];
        self.allInstitutions = [[FTSession sharedSession].institutions objectsAtIndexes:indices];
        // create a filtered list that will contain institutions for the search results table.
        self.activeInstitutions = [NSMutableArray arrayWithArray:self.allInstitutions];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshInstitution:) name:FTInstitutionalLogoLoaded object:NULL];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
    UIBarButtonItem *buttonItem =
    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                  target:self action:@selector(cancel:)];
    self.navigationItem.leftBarButtonItem = buttonItem;
    UINib *nib = [UINib nibWithNibName:@"InstitutionCollectionViewCell" bundle:nil];
    [self.institutionsCollection registerNib:nib forCellWithReuseIdentifier:@"InstitutionCell"];
    
    // Observe keyboard hide and show notifications to resize the text view appropriately.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { //Cuong
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {  //iPad
            //self.searchBar.center = CGPointMake(self.searchBar.center.x, self.searchBar.center.y + 20.0);
            //self.institutionsCollection.frame = CGRectMake(self.institutionsCollection.frame.origin.x, self.institutionsCollection.frame.origin.y + 20.0, self.institutionsCollection.frame.size.width, self.institutionsCollection.frame.size.height - 20.0);
        } else {    //iPhone
            if (self.topLayoutConstrant.constant < 20.0) {
                self.topLayoutConstrant.constant = 20.0;
                [self.view layoutSubviews];
            }
        }
    }
    self.searchBar.tintColor = kTextOrangeColor;
    
    //Apply font for controls
    self.btnCancel.titleLabel.font = [CommonLayout getFont:16 isBold:YES];
    float fontSize = 15;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        fontSize = 13;
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[CommonLayout getFont:fontSize isBold:NO] forKey:NSFontAttributeName];
    [self.segmentScope setTitleTextAttributes:attributes forState:UIControlStateNormal];
}

- (UITextField*)findTextFieldInSubviewsOfView:(UIView*)superView {
    for (UIView* subView in superView.subviews) {
        if ([subView isKindOfClass:[UITextField class]])
             return (UITextField*)subView;
        
        UITextField *subTextField = [self findTextFieldInSubviewsOfView:subView];
        if (subTextField)
            return subTextField;
    }
    return nil;
}

- (UIButton*)findButtonWithTitle:(NSString*)buttonTitle inSubviewsOfView:(UIView*)superView {
    for (UIView* subView in superView.subviews) {
        if ([subView isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton*)subView;
            if ([[button titleForState:UIControlStateNormal] isEqualToString:buttonTitle])
                return button;
        }
        UIButton *subButton = [self findButtonWithTitle:buttonTitle inSubviewsOfView:subView];
        if (subButton)
            return subButton;
    }
    return nil;
}

- (void)viewDidUnload
{
    self.popover = nil;
    self.credentialsViewController = nil;
    self.activeInstitutions = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    CLS_LOG(@"AddConnectionViewController viewWillAppear:");
    self.navigationController.navigationBarHidden = YES;
    // enable Cancel button
    for (UIView *v in self.searchBar.subviews) {
        if ([v isKindOfClass:[UIControl class]]) {
            ((UIControl *)v).enabled = YES;
        }
    }
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
//    UITextField *searchBarTextField = [self findTextFieldInSubviewsOfView:self.searchBar];
    //    [searchBarTextField setWidth:100];
    //    searchBarTextField.backgroundColor = [UIColor yellowColor];
    //    [self.view layoutSubviews];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { //Cuong
        UIButton *searchBarCancelButton = [self findButtonWithTitle:@"Cancel" inSubviewsOfView:self.searchBar];
        if (searchBarCancelButton) {
            searchBarCancelButton.hidden = YES;
            
            [CommonLayout createTextButton:searchBarCancelButton.frame font:searchBarCancelButton.titleLabel.font text:@"Cancel" textColor:[searchBarCancelButton titleColorForState:UIControlStateNormal] touchTarget:self touchSelector:@selector(cancel:) superView:self.searchBar];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"AddConnectionViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview. 
    [super didReceiveMemoryWarning];
}

#pragma mark Orientation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    BOOL shouldnot = (toInterfaceOrientation & UIInterfaceOrientationMaskLandscape);
	return shouldnot;
}

- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
//{
//    [self.institutionsCollection performBatchUpdates:nil completion:nil];
//}


#pragma mark Properties
- (void)setCancelReceiver:(id)receiver withAction:(SEL)action {
    self.cancelReceiver = receiver;
    self.cancelAction = action;
}
- (void)setDoneReceiver:(id)receiver withAction:(SEL)action {
    self.doneReceiver = receiver;
    self.doneAction = action;
}

#pragma mark Action methods

- (IBAction)handleConnect:(ConnectionCredentialsViewController *)credentialsView {
    NSString *username = credentialsView.usernameText;
    NSString *password = credentialsView.passwordText;
    FTInstitution *institution = credentialsView.institution;

    [institution connectWithTicket:[FTSession sharedSession].ticket withUsername:username withPassword:password];
    
    [self.popover dismissPopoverAnimated:YES];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.doneReceiver performSelector:self.doneAction withObject:self];
#pragma clang diagnostic pop
}

- (IBAction)cancel:(id)sender {
    [self.popover dismissPopoverAnimated:YES];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self.doneReceiver performSelector:self.cancelAction withObject:nil];
#pragma clang diagnostic pop
}

- (IBAction)cancelCredentials:(id)sender {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        [self.popover dismissPopoverAnimated:YES];
    else
        [self.navigationController popViewControllerAnimated:YES];
 }

/*
 If the requesting table view is the search display controller's table view, return the count of
 the filtered list, otherwise return the count of the main list.
 */
-(NSArray *)institutionsForTableView:(UIView *)tableView {
    return self.activeInstitutions;
}

/*
    If the requesting table view is the search display controller's table view,
    configure the cell using the filtered content, otherwise use the main list.
 */
- (FTInstitution *)institutionForIndexPath:(NSIndexPath *)indexPath inTableView:(UIView *)tableView {
    return [self institutionsForTableView:tableView][indexPath.row];
}

#pragma mark -
#pragma mark Responding to keyboard events

- (void)keyboardWillShow:(NSNotification *)notification {
    // Reduce the size of the grid view so that it's not obscured by the keyboard.
    /*NSDictionary *userInfo = [notification userInfo];
    
    CGRect endKeyboardRect = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGRect newFrame = self.institutionsCollection.frame;
    newFrame.size.height -= endKeyboardRect.size.height;
    
    self.institutionsCollection.frame = newFrame;*/
    [self.institutionsCollection reloadData];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    // Enlarge the grid view when keyboard disappears.
    /*NSDictionary* userInfo = [notification userInfo];
    CGRect beginKeyboardRect = [userInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    
    CGRect newFrame = self.institutionsCollection.frame;
    newFrame.size.height += beginKeyboardRect.size.height;
    
    self.institutionsCollection.frame = newFrame;*/
    [self.institutionsCollection reloadData];
}

#pragma  mark - Notification listeners
- (void)refreshInstitution:(NSNotification *)notification {
    FTInstitution *refreshedInstitution = notification.object;
    //NSLog(@"refreshing cell for %@", refreshedInstitution);
    if (self.institutionsCollection != nil) {
        for (UICollectionViewCell *c in [self.institutionsCollection visibleCells]) {
            InstitutionCollectionViewCell *cell = (InstitutionCollectionViewCell *)c;
            if (cell.institution.institutionId == refreshedInstitution.institutionId) {
                [self.institutionsCollection reloadData];
                return;
            }
        }
    }
}

#pragma mark - UISearchBarDelegate methods

// called when cancel button pressed
- (void)searchBarCancelButtonClicked:(UISearchBar *) searchBar {
    [self cancel:searchBar];
}

// called when text changes (including clear)
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText;
{
    NSLog(@"searching for “%@”", searchText);
    NSString *scope = searchBar.scopeButtonTitles[searchBar.selectedScopeButtonIndex];
    [self filterContentForSearchText:searchText scope:scope];
}

 // called when search results button pressed
- (void)searchBarResultsListButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarResultsListButtonClicked: %@", searchBar);
}

- (NSString *)NSStringFromScopeIndex:(NSInteger)scopeInteger {
    switch (scopeInteger) {
        case 0:
            return FTInstitutionTypeAll;
            break;
        case 1:
            return FTInstitutionTypeLatest;
            break;
        case 2:
            return FTInstitutionTypePopular;
            break;
        case 3:
            return  FTInstitutionTypeFinancial;
            break;
        case 4:
            return FTInstitutionTypeUtilities;
            break;
    }
    return FTInstitutionTypeAll;
}

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope {
    NSString *scope = [self NSStringFromScopeIndex:selectedScope];
    NSLog(@"searchBar:selectedScopeButtonIndexDidChange:%d/%@", selectedScope,scope);
    [self filterContentForSearchText:searchBar.text scope:scope];
}

#pragma mark - SegmentControl delegate
- (IBAction)segmentScopeValueChanged:(UISegmentedControl*)sender {
    [self searchBar:self.searchBar selectedScopeButtonIndexDidChange:sender.selectedSegmentIndex];
}

#pragma mark - Content Filtering

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
	/*
	 Update the filtered array based on the search text and scope.
	 */
	[self.activeInstitutions removeAllObjects]; // First clear the filtered array.
    /*
     Search the main list for institutions whose type matches the scope (if selected) and whose name matches searchText; add items that match to the filtered array.
     */
    BOOL skipScope = [scope isEqualToString:FTInstitutionTypeAll];
    BOOL skipName = searchText == nil || searchText.length == 0;
    [self.allInstitutions enumerateObjectsUsingBlock:
        ^(id institution, NSUInteger index, BOOL *stop) {
            if ((skipScope || [institution matchesType:scope]) &&
                (skipName || [institution matchesByName:searchText]))
            {
                [self.activeInstitutions addObject:institution];
            }
        }];
    NSLog(@"Filtered list has %d objects out of %d total for %@/%@", [self.activeInstitutions count],[self.allInstitutions count], scope, searchText);

    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.popover dismissPopoverAnimated:YES];
//        [self.popover dismissPopoverAnimated:YES];
        // NOTE: we could restore the previous selection (and the popup)
        // if the new list contains the previous selection, but this is too much work.
        // For now, just make the user reselect.
        //
//        NSArray *selection = [self.institutionsCollection indexPathsForSelectedItems];
//        if (selection.count > 0) {
//            NSIndexPath     *indexPath = [selection objectAtIndex:0];
//            FTInstitution   *institution = [self institutionForIndexPath:indexPath inTableView:self.institutionsCollection];
//            if (![self.activeInstitutions containsObject:institution]) {
//                [self.popover dismissPopoverAnimated:YES];
//            }
//        }
    }

    [self.institutionsCollection reloadData];
}

#pragma mark UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.activeInstitutions count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InstitutionCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"InstitutionCell"
                            forIndexPath:indexPath];
    NSAssert(collectionView == self.institutionsCollection, @"unknown collection view");
    FTInstitution *institution = [self institutionForIndexPath:indexPath inTableView:collectionView];
    [cell setInstitution:institution];

    return cell;
}

#pragma mark UICollectionViewDelegate methods

- (BOOL)collectionView:(UICollectionView *)collectionView shouldHighlightItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didHighlightItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"highlighted %@", indexPath);
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldShowMenuForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
//    NSLog(@"selected %@ containing %@", indexPath, cell);
#ifdef DEBUG
    NSLog(@"selected %@", indexPath);
#endif
    FTInstitution *institution = [self institutionForIndexPath:indexPath inTableView:collectionView];
    if (!self.credentialsViewController) {
        _credentialsViewController = [[ConnectionCredentialsViewController alloc] initWithNibName:nil bundle:nil];
        [_credentialsViewController setReceiver:self withAction:@selector(handleConnect:)];
        [_credentialsViewController setReceiver:self withCancelAction:@selector(cancelCredentials:)];
    }
    [self.credentialsViewController setInstitution:institution];

    CGRect selectedCellFrame = [cell.superview convertRect:cell.frame toView:self.view];
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (!self.popover) {
            // Setup the popover for use in the detail view.
            UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:self.credentialsViewController];
            self.popover = [[UIPopoverController alloc] initWithContentViewController:nc];
            self.popover.popoverContentSize = CGSizeMake(320., 320);
            self.popover.delegate = self;
            self.popover.passthroughViews = @[self.institutionsCollection,
                                              self.searchBar];
            NSLog(@"popping from rect %@", NSStringFromCGRect(selectedCellFrame));
        }
        [self.popover presentPopoverFromRect:selectedCellFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else {
        [self.navigationController pushViewController:self.credentialsViewController animated:YES];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    [self performSelector:@selector(dismissPopoverIfNoSelection:) withObject:self afterDelay:0.0];
}

- (IBAction)dismissPopoverIfNoSelection:(id)sender {
    NSArray *selection = [self.institutionsCollection indexPathsForSelectedItems];
    if (selection.count == 0) {
        [self.popover dismissPopoverAnimated:YES];
    } else {
//        NSLog(@"supressing dismissal");
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    InstitutionCollectionViewCell *disappearingCell = (InstitutionCollectionViewCell *) cell;
    [disappearingCell cancel];
}

@end
