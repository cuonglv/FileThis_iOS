//
//  CabinetController.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "CabinetController.h"
#import "Constants.h"
#import "CommonFunc.h"
#import "CommonVar.h"
#import "DocumentController.h"
#import "Layout.h"

@implementation CabinetController
@synthesize myTableView, arrCabinets;
@synthesize blnViewOnly;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        blnViewOnly = NO; //default
        arrCabinets = nil; //default
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
    myTableView.separatorColor = kColorMyDarkBlue;
    if (blnViewOnly) {
        self.title = @"Cabinets";
        myTableView.allowsSelection = NO;
    } else {
        self.title = @"Select Cabinet";
        myTableView.allowsSelection = YES;
        //self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:[[UIView alloc] initWithFrame:CGRectZero]]; //hide the left bar button
    }

    vwAnimated = [MyAnimatedView newWithSuperview:self.view image:kImgSpinnerWhite];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [vwAnimated startMyAnimation];
    
    if (!arrCabinets)
        arrCabinets = [CommonVar arrAllCabs];
    
    [myTableView reloadData];
    
    if (!blnViewOnly) {
        //First, select the current Cabinet of Document List
        DocumentController *docCon = (DocumentController*)[CommonVar docCon];
        for (int i = 0,count=[arrCabinets count]; i < count; i++) {
            NSDictionary *dict = arrCabinets[i];
            if ([[dict valueForKey:@"id"] intValue] == docCon.iCabId) {
                [myTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0] animated:YES scrollPosition:UITableViewScrollPositionNone];
                break;
            }
        }
    }
    
    [vwAnimated stopMyAnimation];
}
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}*/

/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}*/

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
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [arrCabinets count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    if (!arrCabinets) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[CabinetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        return cell;
    } else {
        // Configure the cell...
        NSDictionary *dict = [arrCabinets[[indexPath row]] copy];
        NSString *sType = [dict valueForKey:@"type"];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:sType];
        if (cell == nil) {
            //NSLog(@"new cell %i", indexPath.row);
            UIImage *img;
            if ([sType isEqualToString:@"alll"]) {
                img = kImgCabAll;
            } else if ([sType isEqualToString:@"vitl"]) {
                img = kImgCabVital;
            } else if ([sType isEqualToString:@"basc"]) {
                img = kImgCabBasic;
            } else {
                img = kImgCabComputed;
            }
            cell = [[CabinetCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:sType backgroundImg:img];
        }
        
        CabinetCell *cabCell = (CabinetCell *)cell;
        //NSLog(@"%i",indexPath.row);
        cabCell.lblName.text = [NSString stringWithFormat:@" %@", [dict valueForKey:@"name"]];
        //[cabCell setCabType:sType];
        
        id iDocCount = [dict valueForKey:@"docCount"];
        [cabCell setCount:(iDocCount?[iDocCount intValue]:-1)];
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //NSDictionary *dict = [arrCabinets objectAtIndex:[indexPath row]];
    //int cabid = [[dict objectForKey:@"id"] intValue];
    
    
//   [self.navigationController pushViewController:controller animated:YES];
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
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [myTableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
    DocumentController *docCon = (DocumentController*)[CommonVar docCon];
    NSDictionary *dict = arrCabinets[indexPath.row];
    if (dict) {
        int iSelectedCabId = [[dict valueForKey:@"id"] intValue];
        if (docCon.iCabId != iSelectedCabId) { //really select a different cabinet -> reset Search criteria
            docCon.sTagIds = @"";
            docCon.tfSearchTag.text = @"";
            docCon.tfSearchText.text = @"";
            docCon.blnNeedToReloadDocInfo = YES;
            [docCon setCabId:iSelectedCabId name:[dict valueForKey:@"name"] type:[dict valueForKey:@"type"]];
        }
    }
    [self performSelector:@selector(quit) withObject:nil afterDelay:0.2];   //must delay to see check
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kCabCellHeight;
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
- (void)quit {
    [self.navigationController popViewControllerAnimated:YES];
}
@end

