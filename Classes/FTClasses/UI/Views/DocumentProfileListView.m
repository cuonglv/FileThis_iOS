//
//  DocumentProfileListView.m
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "DocumentProfileListView.h"
#import "DocumentProfileObject.h"
#import "FTMobileAppDelegate.h"
#import "DocumentGroupHeaderView.h"
#import "CommonDataManager.h"
#import "ProfileDataManager.h"
#import "DocumentDataManager.h"
#import "FTMobileAppDelegate.h"
#import "EventManager.h"
#import "LoadingView.h"
#import "CommonFunc.h"
#import "CacheManager.h"
#import "TagDataManager.h"
#import "UIImage+Resize.h"

#define HEIGHT_FOR_ROW  80
#define HEIGHT_FOR_HEADER_SECTION  40
#define MAX_ROWS_IN_SECTION 5
#define NUM_TAGS_IN_ROW 8

@implementation DocumentProfileListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.arrDocumentProfiles = [[NSMutableArray alloc] init];
        self.selectedSections = [[NSMutableArray alloc] init];
        self.selectedCells = [[NSMutableDictionary alloc] init];
        self.selectedIndexes = [[NSMutableDictionary alloc] init];
        self.loadingView = [[LoadingView alloc] init];
        
        // Initial select first section
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSArray *arr = [userDefault objectForKey:kSelectedSectionProfileList];
        if (!arr)
        {
            [self.selectedSections addObject:@"0"];
        }
        else
        {
            self.selectedSections = [[NSMutableArray alloc] initWithArray:arr];
        }
        
        // Initialization code
        self.tbDocumentProfile = [[UITableView alloc] initWithFrame:frame];
        self.tbDocumentProfile.delegate = self;
        self.tbDocumentProfile.dataSource = self;
        self.tbDocumentProfile.allowsSelection = NO;
        [self addSubview:self.tbDocumentProfile];
        [self.tbDocumentProfile setSeparatorColor:kWhiteLightGrayColor];
        
        //Add header (pull to refresh) to tableview
        self.headerViewRefresh = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tbDocumentProfile.bounds.size.height, self.tbDocumentProfile.bounds.size.width, self.tbDocumentProfile.bounds.size.height)];
        [self.tbDocumentProfile addSubview:self.headerViewRefresh];
        
        //Observe for thumb download event
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDownloadThumb:) name:NotificationDownloadThumb object:nil];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)dealloc {
    //Observe for thumb download event
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([DocumentDataManager getInstance].delegateDownloadImage == self)
        [DocumentDataManager getInstance].delegateDownloadImage = nil;
}

- (void)loadData {
    if (![[CommonDataManager getInstance] isCommonDataAvailableWithKey:DATA_COMMON_KEY]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView startLoadingInView:self];
        });
        [[CommonDataManager getInstance] reloadCommonDataWithKey:DATA_COMMON_KEY];
    } else {
        [self loadDocumentsInProfile];
    }
}

- (void)loadDocumentsInProfile {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
        [self.loadingView startLoadingInView:self];
    });
    
    // Load data
    [self.arrDocumentProfiles removeAllObjects];
    NSArray *allDocumentProfiles = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentProfiles]];
    for (DocumentProfileObject *documentProfileObj in allDocumentProfiles) {
        if ([documentProfileObj.arrDocuments count] > 0) {
            if (![self.arrDocumentProfiles containsObject:documentProfileObj]) {
                [self.arrDocumentProfiles addObject:documentProfileObj];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
        [self.tbDocumentProfile reloadData];
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_FINISHED_DISPLAYING_DOCUMENT_LIST];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
    });
}

- (void)clearData {
    [self.arrDocumentProfiles removeAllObjects];
    [self.tbDocumentProfile reloadData];
}

- (void)layoutSubviews
{
    self.tbDocumentProfile.frame = self.bounds;
    [self.loadingView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

#pragma mark - Setter
- (void)setLoadingData:(BOOL)loading {
    _loadingData = loading;
    if (!_loadingData)
    {
        [self.headerViewRefresh egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbDocumentProfile];
    }
}

#pragma mark - documentgroupheaderdelegate
- (void)didViewAllButtonTouched:(id)sender documentGroup:(id)documentGroup {
    DocumentProfileObject *documentProfile = (DocumentProfileObject *)documentGroup;
    
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate goToDocumentGroupViewController:documentProfile];
}

- (NSIndexPath *)indexPathOfDocument:(DocumentObject *)document {
    for (DocumentProfileObject *documentProfile in self.arrDocumentProfiles) {
        if ([documentProfile.arrDocuments containsObject:document]) {
            return [NSIndexPath indexPathForItem:document inSection:[self.arrDocumentProfiles indexOfObject:documentProfile]];
        }
    }
    
    return nil;
}

#pragma mark - uitableviewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.arrDocumentProfiles count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.selectedSections containsObject:[NSString stringWithFormat:@"%d", section]]) {
        DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:section];
        if ([documentProfile.arrDocuments count] > MAX_ROWS_IN_SECTION) return MAX_ROWS_IN_SECTION;
        return [documentProfile.arrDocuments count];
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:indexPath.section];
//    DocumentObject *document = [documentProfile.arrDocuments objectAtIndex:indexPath.row];
//    
//    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate goToDocumentDetail:document documents:documentProfile.arrDocuments];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEIGHT_FOR_HEADER_SECTION;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // If our cell is selected, return double height
	if([self cellIsSelected:indexPath]) {
		return [self calculateHeightForIndexPath:indexPath];
	}
	
	// Cell isn't selected so return single height
    DocumentCabinetObject *documentCabinet = [self.arrDocumentProfiles objectAtIndex:indexPath.section];
    DocumentObject *document = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
    CGFloat heightForTagView = [self getHeightForTagView:document];
    float y = 40;
    return MAX(HEIGHT_FOR_ROW, y + heightForTagView);
	//return HEIGHT_FOR_ROW + heightForTagView;
}

- (CGFloat)getHeightForTagView:(DocumentObject *)document {
    float widthConstraint = self.tbDocumentProfile.frame.size.width - 135;
    int row = [TagListView getRowCountForDocument:document byWidth:widthConstraint];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (row > 3)
            row = 3;
    }
    
    return row * TAG_VIEW_HEIGHT;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.arrDocumentProfiles count] == 0 || section >= [self.arrDocumentProfiles count]) return nil;
    
    DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:section];
    DocumentGroupHeaderView *headerView = [[DocumentGroupHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEIGHT_FOR_HEADER_SECTION) documentGroup:documentProfile];
    
    BOOL isExpand = [self.selectedSections containsObject:[NSString stringWithFormat:@"%d", section]];
    [headerView updateIcon:isExpand];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSectionTouched:)];
    gesture.accessibilityValue = [NSString stringWithFormat:@"%d", section];
    [headerView addGestureRecognizer:gesture];
    
    headerView.delegate = self;
    return headerView;
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
	NSNumber *selectedIndex = [self.selectedIndexes objectForKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
	return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

- (int)calculateHeightForIndexPath:(NSIndexPath *)indexPath
{
    DocumentCabinetObject *documentCabinet = [self.arrDocumentProfiles objectAtIndex:indexPath.section];
    DocumentObject *document = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
    
    DocumentCell *selectedCell = [self.selectedCells objectForKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    CGFloat heightForTagView = [self getHeightForTagView:document];
    int height = HEIGHT_FOR_ROW + selectedCell.documentInfoView.frame.size.height + heightForTagView;
    return height;
}

- (void)handleSectionTouched:(id)sender {
    NSString *section = ((UITapGestureRecognizer *)sender).accessibilityValue;
    if (![self.selectedSections containsObject:section]) {
        [self.selectedSections addObject:section];
    } else {
        [self.selectedSections removeObject:section];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:self.selectedSections forKey:kSelectedSectionProfileList];
    
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, [self.arrDocumentProfiles count])];
    [self.tbDocumentProfile reloadSections:mutableIndexSet withRowAnimation:UITableViewRowAnimationFade];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DocumentCell *cell = nil;
    static NSString *cellFollowingIdentifier = @"DocumentProfileCell";
	cell = [self.tbDocumentProfile dequeueReusableCellWithIdentifier:cellFollowingIdentifier];
    
    // Get data object from array
    if (indexPath.section >= [self.arrDocumentProfiles count]) return cell;
    DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:indexPath.section];
    
    if (indexPath.row >= [documentProfile.arrDocuments count]) return cell;
    DocumentObject *documentObj = [documentProfile.arrDocuments objectAtIndex:indexPath.row];
    
	if (cell == nil) {
		cell = [[DocumentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellFollowingIdentifier tableView:tableView];
		cell.accessoryType  = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    cell.delegate = self;
    
    //[DocumentDataManager getInstance].delegateDownloadImage = self;
    //[[DocumentDataManager getInstance] loadThumbnailForImageView:cell.imvThumb docObj:documentObj];
    if ([[CommonDataManager getInstance] isDocumentThumbDataAvailable:documentObj]) {
        //[documentObj.docThumbImage setToImageView:cell.imvThumb];
    } else {
        [[DocumentDataManager getInstance] downloadThumbnailForDocument:documentObj];
    }
    
    [cell updateCellWithObject:documentObj];
    cell.tagListView.delegate = self;
    cell.documentInfoView.tagListView.delegate = self;
    
	return cell;
}

#pragma mark - DocumentCellDelegate
- (void)didButtonInfoTouched:(id)sender for:(DocumentObject *)docObj {
    DocumentCell *selectedCell = (DocumentCell *)sender;
    NSIndexPath *indexPath = [self.tbDocumentProfile indexPathForCell:selectedCell];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.pathDocumentInfoViewed = indexPath; //Store last viewed document indexpath
        if ([self.delegateCell respondsToSelector:@selector(didButtonInfoTouched:for:)]) {
            [self.delegateCell didButtonInfoTouched:sender for:docObj];
        }
        return;
    }
    
    // Toggle 'selected' state
	BOOL isSelected = ![self cellIsSelected:indexPath];
	
	// Store cell 'selected' state keyed on indexPath
	NSNumber *selectedValue = [NSNumber numberWithBool:isSelected];
	[self.selectedIndexes setObject:selectedValue forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    [self.selectedCells setObject:selectedCell forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    
	// This is where magic happens...
    [self.tbDocumentProfile beginUpdates];
	[self.tbDocumentProfile endUpdates];
}

- (void)didCloseButtonTouched:(id)sender for:(DocumentObject *)docObj {
    DocumentCell *selectedCell = (DocumentCell *)sender;
    NSIndexPath *indexPath = [self.tbDocumentProfile indexPathForCell:selectedCell];
    
    // Store cell 'selected' state keyed on indexPath
	NSNumber *selectedValue = [NSNumber numberWithBool:NO];
	[self.selectedIndexes setObject:selectedValue forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    [self.selectedCells setObject:selectedCell forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    
	// This is where magic happens...
    [self.tbDocumentProfile beginUpdates];
	[self.tbDocumentProfile endUpdates];
}

- (void)didSaveButtonTouched:(id)sender for:(DocumentObject *)docObj {
    BOOL res = [[DocumentDataManager getInstance] updateDocumentInfo:docObj];
    if (res) {
        [self.tbDocumentProfile reloadData];
        
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_EDIT_DOC];
        [event setContent:docObj];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
    }
}

- (void)documentCell:(DocumentCell *)cell willUpdateDocumentValue:(DocumentObject *)newDoc withProperties:(NSArray *)properties {
    BOOL res = [[DocumentDataManager getInstance] updateDocumentInfo:newDoc];
    if (res) {
        NSIndexPath *indexpath = [self.tbDocumentProfile indexPathForCell:cell];
        if (indexpath) {
            DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:indexpath.section];
            DocumentObject *updateObj = (DocumentObject*)[CommonFunc findObjectWithValue:newDoc.id bykey:@"id" fromArray:documentProfile.arrDocuments];
            if (updateObj) {
                [updateObj updateProperties:properties fromObject:newDoc];
                [self.tbDocumentProfile reloadData];
                Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_EDIT_DOC];
                [event setContent:updateObj];
                [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
            }
        }
    } else {
        [self.tbDocumentProfile reloadData];
    }
}

- (void)tagViewDidEditTouched:(id)sender forDocument:(DocumentObject *)docObj {
    DocumentCell *selectedCell = (DocumentCell *)sender;
    NSIndexPath *indexPath = [self.tbDocumentProfile indexPathForCell:selectedCell];
    
    DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:indexPath.section];
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate goToDocumentDetail:docObj documents:documentProfile.arrDocuments actionType:ACTIONTYPE_EDIT_TAGS];
}

- (void)didTouchCell:(id)sender documentObject:(DocumentObject *)docObj {
    DocumentCell *documentCell = sender;
    NSIndexPath *indexPath = [self.tbDocumentProfile indexPathForCell:documentCell];
    DocumentCabinetObject *documentCabinet = [self.arrDocumentProfiles objectAtIndex:indexPath.section];
    DocumentObject *document = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
    
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate goToDocumentDetail:document documents:documentCabinet.arrDocuments];
}

#pragma mark - DownloadThumbnailProtocol
- (void)didDownloadImage:(UIImage*)image forDocument:(DocumentObject*)doc {
    //NSArray *rows = self.tbDocumentProfile.indexPathsForVisibleRows;
    //[self.tbDocumentProfile reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationNone];
     NSArray *cells = [self.tbDocumentProfile visibleCells];
     for (DocumentCell *cell in cells) {
         [cell refreshThumbnail];
     }
}

#pragma mark - UIScrollViewDelegate Methods
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.headerViewRefresh egoRefreshScrollViewWillBeginDragging:scrollView];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.headerViewRefresh egoRefreshScrollViewDidScroll:scrollView];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.headerViewRefresh egoRefreshScrollViewDidEndDragging:scrollView];
}

#pragma mark - Download Thumb notification
- (void)didDownloadThumb:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.window) //Is visible on screen
            [self didDownloadImage:nil forDocument:nil];
    });
}

@end
