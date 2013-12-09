//
//  TagController.m
//  FTMobile
//
//  Created by decuoi on 12/2/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "TagController.h"
#import "Layout.h"
#import "CommonVar.h"
#import "CommonFunc.h"
#import "TagCell.h"
#import "DocumentController.h"

@implementation TagController
@synthesize blnViewOnly;
@synthesize arrTagsInfo;
@synthesize sSearchFilter;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        imgCheck = [UIImage imageNamed:@"checkmark15x16.png"];
        blnViewOnly = NO; //default
        
        sSearchFilter = @"";
        marrTagsChecked = [[NSMutableArray alloc] init];
        marrTagsUnchecked = [[NSMutableArray alloc] init];
        marrTagIdsChecked = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    myTableView.separatorColor = kColorMyDarkBlue;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    if (blnViewOnly) {
        self.title = @"Tags";
        myTableView.allowsSelection = NO;
    } else {
        self.title = @"Select Tags";
    
        DocumentController *docCon = (DocumentController*)[CommonVar docCon];
        NSString *sTagIds = docCon.sTagIds;
        if ([sTagIds length] > 0) {
            NSArray *arrTagIds = [sTagIds componentsSeparatedByString:@","];
            for (NSString *sTagId in arrTagIds) {
                int iTagId = [sTagId intValue];
                //NSLog(@"Tag id: %i", iTagId);
                NSString *sTagName = [CommonVar getTagName:iTagId];
                TagData *newTagData = [[TagData alloc] initWithId:iTagId name:sTagName count:0];
                [self insertTagData:newTagData toCheckedArray:YES];
            }
            //[arrTagIds release];
        }
        //[sTagIds release];
    }
    myTableView.blnViewOnly = blnViewOnly;

    [self.navigationController setNavigationBarHidden:NO];
    myTableView.allowsSelection = NO;
    
    vwAnimated = [MyAnimatedView newWithSuperview:self.view image:kImgSpinnerWhite];
    //NSLog(@"TagCon - viewDidLoad - end", @"");
}


/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //NSLog(@"TagCon - viewDidAppear", @"");
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {    
    if (!blnViewOnly) {
        NSMutableString *sTagIds = [[NSMutableString alloc] initWithString:@""];
        NSMutableString *sTagNames = [[NSMutableString alloc] initWithString:@""];
        
        for (TagData *tagData in marrTagsChecked) {
            if (sTagIds.length == 0) {
                [sTagIds appendFormat:@"%i", tagData.iTagId];
                [sTagNames appendString:tagData.sTagName];
            } else {
                [sTagIds appendFormat:@",%i", tagData.iTagId];
                [sTagNames appendFormat:@", %@", tagData.sTagName];
            }
        }
        
        DocumentController *docCon = (DocumentController*)[CommonVar docCon];
        if (![docCon.sTagIds isEqualToString:sTagIds]) {    //selected tag list has been changed
            docCon.sTagIds = sTagIds;
            docCon.tfSearchTag.text = sTagNames;
            docCon.blnNeedToReloadDocInfo = YES;
        }
        
    }
    
    [super viewWillDisappear:animated];
}

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
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (blnViewOnly)
        return [arrTagsInfo count];
    else
        return [marrTagsChecked count] + [marrTagsUnchecked count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"TagCon - drawcell at index: %i", indexPath.row);
    static NSString *CellIdentifier = @"Cell";
    
    TagCell *cell = (TagCell*)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[TagCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier imageCheck:imgCheck];
    }
    
    // Configure the cell...
    if (blnViewOnly) {  //Currently View Tag Info of a Document
        if (arrTagsInfo) {
            NSMutableDictionary *dict = arrTagsInfo[indexPath.row];
            cell.lblName.text = [NSString stringWithFormat:@" %@", [dict valueForKey:@"name"]];
            id iCount = [dict valueForKey:@"docCount"];
            [cell setCount:(iCount?[iCount intValue]:-1)];
        }
        
    } else { //Currently Select Tags
        int iTagsCheckedCount = [marrTagsChecked count];
        if (indexPath.row < iTagsCheckedCount + [marrTagsUnchecked count]) {
            TagData *tagData;
            if (indexPath.row < iTagsCheckedCount) {   // this is checked tag
                tagData = marrTagsChecked[indexPath.row];
                [cell setCheck:YES];
            } else  {    // this is unchecked tag
                tagData = marrTagsUnchecked[indexPath.row - iTagsCheckedCount];
                [cell setCheck:NO];
            }
            [cell setTagData:tagData];
            //[cell displayCheck];
        }
    }

    return cell;
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
    //TagCell *cell = [myTableView cellForRowAtIndexPath:indexPath];
    //cell.accessoryType = (cell.blnChecked ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kTagCellHeight;
}



#pragma mark -
- (int)insertTagData:(TagData*)newTagData toCheckedArray:(BOOL)toCheckedArray { //including sort by Name asc
    //NSLog(@"InsertTagData", @"");
    NSMutableArray *marr = (toCheckedArray ? marrTagsChecked : marrTagsUnchecked);
    int i = 0;
    while (i < [marr count]) {
        TagData *tagData = marr[i];
        if ([tagData.sTagName compare:newTagData.sTagName] == NSOrderedDescending) {
            break; //found correct position to insert
        }
        i++;
    }
    [marr insertObject:newTagData atIndex:i];
    //NSLog(@"InsertTagData end return %i", i);
    return i;
}

- (void)removeTagChecked:(int)index { //including sort by Name asc
    [marrTagsChecked removeObjectAtIndex:index];
}

- (void)loadData {
    //NSLog(@"Begin load data", @"");
    [vwAnimated startMyAnimation];
    //make request send to server
    NSString *sTagFilter;
    
    if ([marrTagsChecked count] == 0) {
        sTagFilter = @"";
    } else {
        TagData *tagData = marrTagsChecked[0];
        sTagFilter = [NSString stringWithFormat:@"&tagIds=%i", tagData.iTagId];
        for (int i = 1, count = [marrTagsChecked count]; i<count; i++) {
            tagData = marrTagsChecked[i];
            sTagFilter = [sTagFilter stringByAppendingFormat:@",%i", tagData.iTagId];
        }
    }
    //NSLog(@"tag filter: %@", sTagFilter);
    
    //NSLog(@"All tags: %@", [[CommonVar mdictAllTags] description]);
    
    DocumentController *docCon = (DocumentController*)[CommonVar docCon];
    NSDictionary *dictTags = [CommonFunc jsonDictionaryGET:[[CommonVar requestURL] stringByAppendingFormat:@"doctaglist&cabId=%i%@%@", docCon.iCabId, sTagFilter, sSearchFilter]];
    NSArray *arrTags = [dictTags valueForKey:@"tags"];
    
    marrTagsUnchecked = [[NSMutableArray alloc] init];
    int iCountTagCheckedFound = 0, iTotalTagChecked = [marrTagsChecked count];
    
    NSString *sTagName = nil;
    for (NSDictionary *dictTag in arrTags) {
        int iTagId = [[dictTag valueForKey:@"id"] intValue];
        
        if (iCountTagCheckedFound < iTotalTagChecked) { //if found enough checked tags, this would be unchecked tag
            BOOL blnIsTagChecked = NO;
            
            for (TagData *tagData in marrTagsChecked) {
                if (tagData.iTagId == iTagId) {
                    //this is checked tag, just need to update doc count of tag
                    //NSLog(@"Found checked tag: %i %i", iTagId, [[dictTag valueForKey:@"docCount"] intValue]);
                    tagData.iDocCount = [[dictTag valueForKey:@"docCount"] intValue];
                    iCountTagCheckedFound++;
                    blnIsTagChecked = YES;
                    break;
                }
            }
            if (blnIsTagChecked)
                continue;
        }
        
        //Now, this is unchecked tag, need to insert into Unchecked tag array
        sTagName = [CommonVar getTagName:iTagId];
        if (sTagName) {
            TagData *tagDataUnchecked = [[TagData alloc] initWithId:iTagId name:sTagName count:[[dictTag valueForKey:@"docCount"] intValue]];
            [self insertTagData:tagDataUnchecked toCheckedArray:NO];
        }
    }
    
    [myTableView reloadData];
    [myTableView setNeedsDisplay];
    [vwAnimated stopMyAnimation];
}
@end

