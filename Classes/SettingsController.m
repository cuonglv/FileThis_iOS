//
//  SettingsController.m
//  FTMobile
//
//  Created by decuoi on 12/17/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "SettingsController.h"
#import <Crashlytics/Crashlytics.h>
#import "Layout.h"
#import "Constants.h"
#import "CommonVar.h"
#import "CommonFunc.h"

@implementation SettingsController

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        sClientEmail = nil;
        sAccountType = nil;
        sSpaceUsed = nil;
        sUploadEmailAddress = nil;
        vwAnimated = nil;
        blnIsFirstLoad = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    [self.navigationController setNavigationBarHidden:NO];
    //myTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //myTableView.separatorColor = [UIColor clearColor];
}


/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 }
 */

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (blnIsFirstLoad) {
        vwAnimated = [MyAnimatedView newWithSuperview:self.view image:kImgSpinner];
        [vwAnimated startMyAnimation];
        [self performSelector:@selector(loadData) withObject:nil afterDelay:0.0];
        blnIsFirstLoad = NO;
    } else { //back from Set Passcode
//        KeyValueCell *kvCell = (KeyValueCell*)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
//        [kvCell setCellValue:([CommonVar blnUsePasscode]?@"On":@"Off")];
    }
}

/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 3;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 4;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *CellIdentifier = [NSString stringWithFormat:@"%i %i", indexPath.section, indexPath.row];
    //NSLog(@"draw cell: %i %i", indexPath.section, indexPath.row);
    UITableViewCell *cell = (KeyValueCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        switch (indexPath.section * 100 + indexPath.row) {
            case 0:     //section 0, row 0
                cell = [[KeyValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier key:@"Email" value:sClientEmail isValueAtBottom:YES drawAccessory:NO];
                break;
            case 1:     //section 0, row 1
                cell = [[KeyValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier key:@"Account type" value:sAccountType isValueAtBottom:YES drawAccessory:NO];
                break;
            case 2:     //section 0, row 2
                cell = [[KeyValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier key:@"Space used" value:sSpaceUsed isValueAtBottom:YES drawAccessory:NO];
                break;
            case 3:     //section 0, row 3
                cell = [[KeyValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier key:@"FileThis email address" value:sUploadEmailAddress isValueAtBottom:YES drawAccessory:NO];
                break;
                
            case 100:   //section 1, row 0
//                cell = [[KeyValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier key:@"Passcode lock" value:([CommonVar blnUsePasscode]?@"On":@"Off") isValueAtBottom:NO drawAccessory:YES];
                break;
                
            case 200:   //section 2, row 0
                cell = [[KeyValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier key:@"Application version" value:[CommonVar appVersion] isValueAtBottom:NO drawAccessory:NO];
                break;
            
            default:
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
                break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0:
            return 50;
            break;
        default:
            return 38;
            break;
    }
    
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return @"Account";
            break;
        case 1:
            return @"Settings";
            break;
        case 2:
            return @"About";
            break;
        default:
            return @"";
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 24;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    SetPasscodeController *target;
    switch (indexPath.section * 100 + indexPath.row) {
        case 0:     //section 0, row 0
            break;
        case 1:     //section 0, row 1
            break;
        case 2:     //section 0, row 2
            break;
            
//        case 100:   //section 1, row 0
//            target = [[SetPasscodeController alloc] initWithNibName:@"SetPasscodeController" bundle:[NSBundle mainBundle]];
//            [self.navigationController pushViewController:target animated:YES];
//            break;
            
        case 200:   //section 2, row 0
            break;
        default:
            break;
    }
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
}



#pragma mark -
#pragma mark My Func
- (void)loadData {
    NSDictionary *dictAccountInfo = nil;
    while (!(dictAccountInfo = [CommonVar dictAccountInfo])) { //wait until Account Info loaded
        [NSThread sleepForTimeInterval:.5];
    }
    NSArray *arrUsers = [dictAccountInfo valueForKey:@"users"];
    NSDictionary *dictUser = arrUsers[0];
    sClientEmail = [dictUser valueForKey:@"email"];
    sAccountType = [dictAccountInfo valueForKey:@"accountType"];
    //NSLog(@"acc type: %@", sAccountType);
    unsigned long long lDocBytes = [[dictAccountInfo valueForKey:@"docBytes"] unsignedLongLongValue];
    sSpaceUsed = [CommonFunc getFileSizeString:lDocBytes];
    //NSLog(@"space used: %@", sSpaceUsed);
    sUploadEmailAddress = [dictAccountInfo valueForKey:@"uploadEmailAddr"];
    //NSLog(@"ft email: %@", sUploadEmailAddress);
    
    myTableView.delegate = self;
    myTableView.dataSource = self;
    [myTableView reloadData];
    [myTableView setNeedsDisplay];
    
    [vwAnimated stopMyAnimation];
}
@end

