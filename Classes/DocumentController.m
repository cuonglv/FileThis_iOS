//
//  DocumentController.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "DocumentController.h"
#import "CommonFunc.h"
#import "CommonVar.h"
#import "Layout.h"
#import "CabinetController.h"
#import "TagController.h"
#import "DocumentCell.h"
#import "DocumentDetailController.h"
#import "UploadController.h"
#import "SettingsController.h"

@implementation DocumentController
@synthesize myTableView;
@synthesize toolbar;
@synthesize lblCabinet, lblSearchTagTitle, lblSearchTextTitle;
@synthesize btnSelectCabinet, btnSelectTag;
@synthesize tfSearchTag, tfSearchText;
@synthesize arrDoc;

@synthesize iCabId, sTagIds;
@synthesize sSortBy;
@synthesize blnSortDescending;
@synthesize iDocPageSize;
@synthesize blnNeedToReloadDocInfo;

#pragma mark -
#pragma mark View lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        iCurrentDocCount = 0;
        lGetThumbThreadCount = 0;
        NSUserDefaults *dictPlist = [CommonVar dictPlist];
        iCabId = [[dictPlist valueForKey:@"LastCabId"] intValue];
        sSortBy = [dictPlist valueForKey:@"LastSortBy"];
        blnSortDescending = [[dictPlist valueForKey:@"LastSortDesc"] boolValue];
        sTagIds = [dictPlist valueForKey:@"LastSearchTagIds"];
        
        iDocPageSize = [CommonVar docPageSize];
        blnNeedToReloadDocInfo = YES;
        blnNeedToScrollToTop = YES; //must YES to init arrDocThumb
        blnIsShowingSortControl = NO;
        blnAllCabsLoaded = NO;
        blnAllTagsLoaded = NO;
        
        [NSThread detachNewThreadSelector:@selector(loadAllCabs) toTarget:self withObject:nil]; //load all cabs in a background thread
        [NSThread detachNewThreadSelector:@selector(loadAllTags) toTarget:self withObject:nil]; //load all tags in a background thread
        [NSThread detachNewThreadSelector:@selector(loadAccountInfo) toTarget:self withObject:nil]; //load account info in a background thread
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Documents";
    
    colorMyDarkBlue = kColorMyDarkBlue;
    myTableView.separatorColor = colorMyDarkBlue;
    
    btnPageMore.hidden = YES;
    
    lblCabinet.font = [UIFont boldSystemFontOfSize:kFontSizeXLarge];
    
    tfSearchTag = [[UITextField alloc] initWithFrame:CGRectMake(52, 3, vwSearchTags.frame.size.width - 56, 24)];
    tfSearchTag.borderStyle = UITextBorderStyleRoundedRect;
    tfSearchTag.font = [UIFont boldSystemFontOfSize:12];
    tfSearchTag.textColor = [UIColor blackColor];
    tfSearchTag.clearButtonMode= UITextFieldViewModeAlways;
    tfSearchTag.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    tfSearchTag.enabled = NO;
    [vwSearchTags addSubview:tfSearchTag];
    
    lblTagText = [Layout labelWithFrame:[Layout CGRectResize:tfSearchTag.frame newWidth:tfSearchTag.frame.size.width - 30] text:@"" font:[UIFont boldSystemFontOfSize:12] textColor:[UIColor blackColor] backColor:[UIColor clearColor]];
    [vwSearchTags addSubview:lblTagText];
    
    lblTagClear = [Layout labelWithFrame:CGRectMake(tfSearchTag.frame.origin.x + tfSearchTag.frame.size.width - 28, 0, 28, 28) text:@"" font:[UIFont boldSystemFontOfSize:12] textColor:[UIColor blackColor] backColor:[UIColor clearColor]];
    [vwSearchTags addSubview:lblTagClear];
    
    tfSearchText = [[UITextField alloc] initWithFrame:CGRectMake(52, 3, vwSearchText.frame.size.width - 56, 24)];
    tfSearchText.borderStyle = UITextBorderStyleRoundedRect;
    tfSearchText.font = [UIFont boldSystemFontOfSize:12];
    tfSearchText.textColor = [UIColor blackColor];
    tfSearchText.clearButtonMode= UITextFieldViewModeAlways;
    tfSearchText.autocorrectionType = UITextAutocorrectionTypeNo;
    tfSearchText.delegate = self;
    NSUserDefaults *dictPlist = [CommonVar dictPlist];
    tfSearchText.text = [dictPlist valueForKey:@"LastSearchText"];
    tfSearchText.contentVerticalAlignment = UIControlContentVerticalAlignmentBottom;
    tfSearchText.placeholder = @"Enter search text here";
    [vwSearchText addSubview:tfSearchText];
    
    //init spinner
    vwSort = [SortCriteriaView newWithSuperView:self.view delegate:self items:@[@"Name", @"Name Z..A", @"Kind", @"Kind Z..A", @"Size, smallest first", @"Size, largest first", @"Page count, lowest first", @"Page count, highest first", @"Tag count, lowest first", @"Tag count, highest first", @"Date added, newest first", @"Date added, oldest first", @"Date created, newest first", @"Date created, oldest first"]];
    vwSort.hidden = YES;

    vwAnimated = [MyAnimatedView newWithSuperview:self.view image:kImgSpinner];
    myTableView.allowsSelection = NO;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    blnExitThread = NO;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    //when return from other screen
    [imvCabinet setNeedsDisplay];
    if (blnNeedToReloadDocInfo) {
        iCurrentDocCount = 0;
    }
    [self loadData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [tfSearchText resignFirstResponder];
    blnExitThread = YES; //to stop loadthumb thread (if it is still running)
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
#pragma mark Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [arrDoc count];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[DocumentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier borderColor:colorMyDarkBlue];
    }
    
    // Configure the cell...
    DocumentCell *docCell = (DocumentCell *)cell;
    if (arrDoc) {
        if ([arrDoc count] > indexPath.row) {
            NSMutableDictionary *dict = arrDoc[[indexPath row]];
            docCell.lblName.text = [dict valueForKey:@"filename"];
            docCell.lblDate.text = [CommonFunc dateStringFromInt:[dict[@"added"] intValue]];
            docCell.lblTags.text = [CommonVar getTagNames:dict[@"tags"]];
            docCell.dictDoc = dict;
            
            docCell.imvThumb.hidden = YES;
            if (arrDocThumb) {
                if ([arrDocThumb count] > indexPath.row) {
                    UIImage *img = arrDocThumb[indexPath.row];
                    if (img) {
                        docCell.imvThumb.hidden = NO;
                        //NSLog(@"load img for cell: %i", indexPath.row);
                        docCell.imvThumb.image = img;
                    }
                }
            }
        }
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return (float)[CommonVar docThumbSmallHeight];
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
    // Navigation logic may go here. Create and push another view controller.
	/*
	 <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
	 [self.navigationController pushViewController:detailViewController animated:YES];
	 [detailViewController release];
	 */
    
    //[self viewDocumentMetadata:indexPath.row];
    //[myTableView deselectRowAtIndexPath:indexPath animated:NO];   
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    //[self viewDocumentMetadata:indexPath.row];
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
#pragma mark Load data
- (void)loadData {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    [vwAnimated startMyAnimation];
    
    blnExitThread = YES;
    while (lGetThumbThreadCount > 0) { //wait until all thread killed
        [NSThread sleepForTimeInterval:.5];
    }
    blnExitThread = NO;
    
    if (blnNeedToReloadDocInfo) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        //NSLog(@"DocCon - loadDataBegin",@"");
        if (blnNeedToScrollToTop) {
            if ([myTableView numberOfRowsInSection:0] > 0)
            {
                [myTableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] atScrollPosition:UITableViewScrollPositionTop animated:NO];
                [myTableView reloadData];
                [myTableView setNeedsDisplay];
            }
        }

        NSString *sTagFilter;
        if (sTagIds.length > 0) {
            sTagFilter = [NSString stringWithFormat:@"&tagIds=%@", sTagIds];
        }else {
            sTagFilter = @"";
        }
        
        sSearchText = tfSearchText.text;
        NSString *sSearchFilter = tfSearchText.text;
        if (sSearchFilter.length > 0) {
//            sSearchFilter = [sSearchFilter stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            sSearchFilter = [NSString stringWithFormat:@"&search=%@",[sSearchFilter stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        }
        
        //NSLog(@"DocCon - loadDataBegin2",@"");
        NSString *request = [[CommonVar requestURL] stringByAppendingFormat:@"doclist&cabid=%i&listtags=false%@%@&sortBy=%@&sortDescending=%@&start=%i&count=%i&sendTagIds=true",iCabId,sTagFilter,sSearchFilter,sSortBy,(blnSortDescending?@"true":@"false"),0,iCurrentDocCount + iDocPageSize];
        NSDictionary *dictDoc = [CommonFunc jsonDictionaryGET:request];
        
        NSDictionary *dictAccount = dictDoc[@"account"];
        int iSelectedDocCount = [[dictAccount valueForKey:@"selectedDocCount"] intValue];
        
        arrDoc = dictDoc[@"documents"];
        
        
        //Paging 
        iCurrentDocCount = [arrDoc count];
        btnPageMore.hidden = (iCurrentDocCount >= iSelectedDocCount);
        
        lblPageInfo.text = [NSString stringWithFormat:@"0 - %i of %i", iCurrentDocCount, iSelectedDocCount];
        
        while (!blnAllTagsLoaded) { //wait until all tags are loaded -> to display tags of each document (cell)
            [NSThread sleepForTimeInterval:.5];
        }

        [myTableView reloadData];
        [myTableView setNeedsDisplay];
        
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        blnNeedToReloadDocInfo = NO;    //finish loading documents' info
        
        if (blnNeedToScrollToTop) {
            
            //if need to reload data, then need to start new thread to reload thumbnails, too.
            arrDocThumb = [[NSMutableArray alloc] init];
            [NSThread detachNewThreadSelector:@selector(getServerThumbnails) toTarget:self withObject:nil];
            
        } else { //when press more button or back from other screen with no change, no need to reload thumbnails from beginning
            [NSThread detachNewThreadSelector:@selector(getServerThumbnails) toTarget:self withObject:nil];
        }
        blnNeedToScrollToTop = YES; //next time need scroll to top by default
        
        //remember the current filter criteria for furture
        NSUserDefaults *dictPlist = [CommonVar dictPlist];
        [dictPlist setValue:@(iCabId) forKey:@"LastCabId"];
        [dictPlist setValue:sSortBy forKey:@"LastSortBy"];
        [dictPlist setValue:@(blnSortDescending) forKey:@"LastSortDesc"];
        [dictPlist setValue:sTagIds forKey:@"LastSearchTagIds"];
        [dictPlist setValue:tfSearchText.text forKey:@"LastSearchText"];
        [CommonVar savePlist];


    } else {   //don't reload doc info, so reload thumb (continue...)
        [NSThread detachNewThreadSelector:@selector(getServerThumbnails) toTarget:self withObject:nil]; // continue load thumbs
    }
    [vwAnimated stopMyAnimation];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)getServerThumbnails {
    lGetThumbThreadCount++;
    if (blnExitThread) {
        lGetThumbThreadCount--;
        return;
    }
    int iIndex = [arrDocThumb count];
    if (iIndex < [arrDoc count]) {
        NSMutableDictionary *dict = arrDoc[iIndex];
        int iDocId = [[dict valueForKey:@"id"] intValue];
        int iLastModified;
        id idDateModified = [dict valueForKey:@"modified"];
        if (idDateModified) {
            iLastModified = [idDateModified intValue];
        } else {
            iLastModified = [[dict valueForKey:@"added"] intValue];
        }
        
        //NSLog(@"DocCon - getServerThumnails - doc id: %i, modified: %i", iDocId, iLastModified);
        UIImage *img = [CommonVar openThumb:iDocId size:ThumbnailSizeSmall modifiedDate:iLastModified];
        //NSLog(@"DocCon - getServerThumbnails - after open thumb: %@", [img description]);
        if (!img) {
            NSString *req = [[CommonVar requestURL] stringByAppendingFormat:@"thumb&id=%i&size=small", iDocId];
            //NSLog(@"Thumb request: %@", req);
            img = [CommonFunc serverGETImage:req];
            if (!img) {
                NSString *req2 = [[CommonVar requestURL] stringByAppendingFormat:@"thumb&id=%i&size=small&generic=1", iDocId];
                //NSLog(@"Thumb request: %@", req);
                img = [CommonFunc serverGETImage:req2];
            }
            [CommonVar saveThumb:img docId:iDocId size:ThumbnailSizeSmall modifiedDate:iLastModified];
        }
        //NSLog(@"DocCon - getServerThumbnails - before add img: %@ to arrDocThumb: %@", [img description], [arrDocThumb description]);
        [arrDocThumb addObject:img];
        //NSLog(@"DocCon - getServerThumbnails - after add img to arrDocThumb: %@", [arrDocThumb description]);
        
        /*NSArray *arrIndexPath = [myTableView indexPathsForVisibleRows];
        if (arrIndexPath) {
            if ([arrIndexPath count] > 0) {
                NSIndexPath *firstIndex = [arrIndexPath objectAtIndex:0];
                NSIndexPath *lastIndex = [arrIndexPath lastObject];
                if (iIndex >= firstIndex.row && iIndex <= lastIndex.row) {*/
                    DocumentCell *docCell = (DocumentCell *)[myTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:iIndex inSection:0]];
                    if (docCell) {
                        docCell.imvThumb.hidden = YES;
                        if (arrDocThumb) {
                            if ([arrDocThumb count] > iIndex) {
                                UIImage *imgThumb = arrDocThumb[iIndex];
                                if (imgThumb) {
                                    docCell.imvThumb.hidden = NO;
                                    //NSLog(@"DocCon - getServerThumnails - redraw cell thumb for row: %i", iIndex);
                                    docCell.imvThumb.image = imgThumb;
                                    [docCell.imvThumb setNeedsDisplay];
                                }
                            }
                        }
                    }
               /* } 
            }
        }*/
                
        [NSThread detachNewThreadSelector:@selector(getServerThumbnails) toTarget:self withObject:nil]; //recursion
    } else { //end recursion
        [myTableView reloadData];
        [myTableView setNeedsDisplay];
    }
    lGetThumbThreadCount--;
}

#pragma mark -
#pragma mark Cabinet info
- (void)setCabId:(int)cabId name:(NSString *)cabName type:(NSString *)cabType { //call by Select Cab screen
    iCabId = cabId;
    lblCabinet.text = [NSString stringWithFormat:@"        %@    ", cabName];
    if ([cabType isEqualToString:@"alll"]) {
        imvCabinet.image = kImgCabAll;
    } else if ([cabType isEqualToString:@"vitl"]) {
        imvCabinet.image = kImgCabVital;
    } else if ([cabType isEqualToString:@"basc"]) {
        imvCabinet.image = kImgCabBasic;
    } else {
        imvCabinet.image = kImgCabComputed;
    }
    //lblCabinet.backgroundColor = [CommonFunc getCabColorByType:cabType];
}

#pragma mark -
#pragma mark UITextField delegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    blnExitThread = YES; //to stop loadthumb thread if it is still running
    lblCabinet.userInteractionEnabled = NO;
    btnSelectCabinet.userInteractionEnabled = NO;
    vwSearchTags.userInteractionEnabled = NO;
    myTableView.userInteractionEnabled = NO;
    myTabBar.userInteractionEnabled = NO;
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == tfSearchText) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        tfSearchText.text = [tfSearchText.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        [tfSearchText endEditing:YES];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (textField == tfSearchText) {
        if (![tfSearchText.text isEqualToString:sSearchText]) { //user enter new search text
            iCurrentDocCount = 0;
            blnNeedToReloadDocInfo = YES;
        }
        [self loadData];
        lblCabinet.userInteractionEnabled = YES;
        btnSelectCabinet.userInteractionEnabled = YES;
        vwSearchTags.userInteractionEnabled = YES;
        myTableView.userInteractionEnabled = YES;
        myTabBar.userInteractionEnabled = YES;
    }
}

#pragma mark -
#pragma mark Touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"DocCon - touchesEnded",@"");
    if (blnIsShowingSortControl)
        return;
    
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.view];
        if ([Layout isPointOutsideControl:point forControl:tfSearchText]) {
            if ([tfSearchText isEditing]) {
                [tfSearchText endEditing:YES];
                return;
            }
        }
        
        if (![Layout isPointOutsideControl:point forControl:lblCabinet]) {
            [self handleSelectCabinet];
        } else {
            point = [touch locationInView:vwSearchTags];
            if (![Layout isPointOutsideControl:point forControl:lblTagText]) {
                [self handleSelectTag];
            } else if (![Layout isPointOutsideControl:point forControl:lblTagClear]) { 
                //clear tags
                if ([sTagIds length] > 0) {
                    iCurrentDocCount = 0;
                    sTagIds = @"";
                    tfSearchTag.text = @"";
                    blnNeedToReloadDocInfo = YES;
                    [self loadData];
                }
            }
        }
        
        return;
    }
}

#pragma mark -
#pragma mark UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if (item == tbiSort) {
        [self performSelector:@selector(handleSortBarBtn) withObject:nil afterDelay:0.2];   //must delay to see item's selected style
    } else if (item == tbiUpload) {
        [self performSelector:@selector(handleUploadBarBtn) withObject:nil afterDelay:0.2];   //must delay to see item's selected style
    } else if (item == tbiSettings) {
        [self performSelector:@selector(handleSettingsBarBtn) withObject:nil afterDelay:0.2];   //must delay to see item's selected style
    } else if (item == tbiLogout) {
        [self performSelector:@selector(handleLogoutBarBtn) withObject:nil afterDelay:0.2];   //must delay to see item's selected style
    }
    
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)handleUploadBarBtn {
    UploadController *target = [[UploadController alloc] initWithNibName:@"UploadController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:target animated:YES];
    [myTabBar setSelectedItem:nil];
}

- (void)handleSettingsBarBtn { 
    SettingsController *target = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:target animated:YES];
    [myTabBar setSelectedItem:nil];
}

#pragma mark -
#pragma mark Button
- (void)handleSortBarBtn {
    blnExitThread = YES; //to stop loadthumb thread if it is still running

    //select right item
    int iIndex = 0; //"name"
    if ([sSortBy isEqualToString:@"kind"]) {
        iIndex = 2;
    } else if ([sSortBy isEqualToString:@"size"]) {
        iIndex = 4;
    } else if ([sSortBy isEqualToString:@"pageCount"]) {
        iIndex = 6;
    } else if ([sSortBy isEqualToString:@"tagCount"]) {
        iIndex = 8;
    } else if ([sSortBy isEqualToString:@"dateAdded"]) {
        iIndex = 10;
    } else if ([sSortBy isEqualToString:@"dateCreated"]) {
        iIndex = 12;
    }
    if (blnSortDescending)
        iIndex++;
    
    [vwSort setSelectedIndex:iIndex];
    
    [self enableSortControl:YES];
    [myTabBar setSelectedItem:nil];
}

- (void)handleLogoutBarBtn {
    [self logout];
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)handleSelectCabinet {
    while (!blnAllCabsLoaded) { //wait until all cabs loaded
        [NSThread sleepForTimeInterval:.5];
    }
    CabinetController *target = [[CabinetController alloc] initWithNibName:@"CabinetController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:target animated:YES];
}
- (IBAction)handleSelectTag {
    //[Layout alertInfo:@"Settings feature: coming soon" delegate:nil];
    TagController *target = [[TagController alloc] initWithNibName:@"TagController" bundle:[NSBundle mainBundle]];
    NSString *sSearchFilter = tfSearchText.text;
    if (sSearchFilter.length > 0) {
        sSearchFilter = [NSString stringWithFormat:@"&search=%@",[sSearchFilter stringByReplacingOccurrencesOfString:@" " withString:@"+"]];
        target.sSearchFilter = sSearchFilter;
    } else {
        target.sSearchFilter = @"";
    }

    [self.navigationController pushViewController:target animated:YES];
}


#pragma mark -
#pragma mark Sort Criteria
- (void)didCancelSortingCriteria {
    [self enableSortControl:NO];
    blnNeedToReloadDocInfo = NO;
    blnNeedToScrollToTop = NO;
    [self loadData];
}

- (void)didSelectSortingCriteria {
    NSString *sNewSortBy;
    BOOL blnNewSortDescending;
    switch ([vwSort getSelectedIndex]) {
        case 0:
            sNewSortBy = @"name"; blnNewSortDescending = NO;
            break;
        case 1:
            sNewSortBy = @"name"; blnNewSortDescending = YES;
            break;
        case 2:
            sNewSortBy = @"kind"; blnNewSortDescending = NO;
            break;
        case 3:
            sNewSortBy = @"kind"; blnNewSortDescending = YES;
            break;
        case 4:
            sNewSortBy = @"size"; blnNewSortDescending = NO;
            break;
        case 5:
            sNewSortBy = @"size"; blnNewSortDescending = YES;
            break;
        case 6:
            sNewSortBy = @"pageCount"; blnNewSortDescending = NO;
            break;
        case 7:
            sNewSortBy = @"pageCount"; blnNewSortDescending = YES;
            break;
        case 8:
            sNewSortBy = @"tagCount"; blnNewSortDescending = NO;
            break;
        case 9:
            sNewSortBy = @"tagCount"; blnNewSortDescending = YES;
            break;
        case 10:
            sNewSortBy = @"dateAdded"; blnNewSortDescending = NO;
            break;
        case 11:
            sNewSortBy = @"dateAdded"; blnNewSortDescending = YES;
            break;
        case 12:
            sNewSortBy = @"dateCreated"; blnNewSortDescending = NO;
            break;
        case 13:
            sNewSortBy = @"dateCreated"; blnNewSortDescending = YES;
            break;
        default:
            sNewSortBy = @"name"; blnNewSortDescending = NO;
            break;
    }
    if (![self.sSortBy isEqualToString:sNewSortBy] || self.blnSortDescending != blnNewSortDescending) {
        self.blnNeedToReloadDocInfo = YES;
        iCurrentDocCount = 0;
        self.sSortBy = sNewSortBy;
        self.blnSortDescending = blnNewSortDescending;
        [self loadData];
    }
    
    [self enableSortControl:NO];
}

- (void)enableSortControl:(BOOL)showSortControl {
    blnIsShowingSortControl = showSortControl;
    lblCabinet.userInteractionEnabled = !showSortControl;
    btnSelectCabinet.userInteractionEnabled = !showSortControl;
    vwSearchTags.userInteractionEnabled = !showSortControl;
    vwSearchText.userInteractionEnabled = !showSortControl;
    myTableView.userInteractionEnabled = !showSortControl;
    myTabBar.userInteractionEnabled = !showSortControl;
    vwSort.hidden = !showSortControl;
}

- (void)loadAllCabs {
    @autoreleasepool {
        [CommonVar loadAllCabs];
        NSDictionary *dictCab = [CommonVar getCab:iCabId];
        if (dictCab) {
            [self setCabId:iCabId name:[dictCab valueForKey:@"name"] type:[dictCab valueForKey:@"type"]];
        } else {
            [self setCabId:-1001 name:@"All" type:@"alll"];
        }
        blnAllCabsLoaded = YES;
    }
}

- (void)loadAllTags {
    @autoreleasepool {
        [CommonVar loadAllTags];
        NSUserDefaults *dictPlist = [CommonVar dictPlist];
        sTagIds = [dictPlist valueForKey:@"LastSearchTagIds"];
        NSString *sTagNames = @"";
        if (sTagIds) {
            if ([sTagIds length] > 0) {
                NSArray *arrTagIds = [sTagIds componentsSeparatedByString:@","];
                for (NSString *sTagId in arrTagIds) {
                    int iTagId = [sTagId intValue];
                    if ([sTagNames length] == 0) {
                        sTagNames = [CommonVar getTagName:iTagId];
                    } else {
                        sTagNames = [sTagNames stringByAppendingFormat:@", %@", [CommonVar getTagName:iTagId]];
                    }
                }
            }
        }
        tfSearchTag.text = sTagNames;
        blnAllTagsLoaded = YES;
    }
}

- (void)loadAccountInfo {
    @autoreleasepool {
        [CommonVar loadAccountInfo];
    }
}

#pragma mark -
#pragma mark Paging
- (IBAction)handleBtnPageMore {
    blnNeedToReloadDocInfo = YES;
    blnNeedToScrollToTop = NO;  //when press more (page) button, no need to scroll to top at all
    [self loadData];
}

#pragma mark -
#pragma mark Logout
- (void)logout {
    NSString *sTicket = [CommonVar ticket];
    [CommonVar setTicket:@""];
    [CommonVar savePlist];
    [NSThread detachNewThreadSelector:@selector(logoutInBackground:) toTarget:self withObject:sTicket];
}
- (void)logoutInBackground:(NSString*)ticket {
    @autoreleasepool {
        NSURL *URL = [NSURL URLWithString:[kServer stringByAppendingFormat:@"op=userlogout&ticket=%@", ticket]];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy: NSURLCacheStorageNotAllowed timeoutInterval: 30];
        [request setHTTPMethod:@"GET"];
        NSURLResponse *response = nil;
        NSError *err = nil;
        
        //NSLog(@"Logout request: %@", URL);
        [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    //NSLog(@"Logout response: %@", [response description]);
    }
}
@end

