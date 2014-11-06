//
//  DocumentCabinetListView.m
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "DocumentCabinetListView.h"
#import "DocumentCabinetObject.h"
#import "FTMobileAppDelegate.h"
#import "DocumentGroupHeaderView.h"
#import "CommonDataManager.h"
#import "CabinetDataManager.h"
#import "DocumentDataManager.h"
#import "FTMobileAppDelegate.h"
#import "EventManager.h"
#import "LoadingView.h"
#import "CacheManager.h"
#import "CommonFunc.h"
#import "EventManager.h"
#import "TagDataManager.h"
#import "UIImage+Resize.h"

#define kThumbQueue dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)

#define HEIGHT_FOR_ROW  80
#define HEIGHT_FOR_HEADER_SECTION  40
#define MAX_ROWS_IN_SECTION 5

@implementation DocumentCabinetListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.arrDocumentCabinets = [[NSMutableArray alloc] init];
        self.selectedSections = [[NSMutableArray alloc] init];
        self.selectedIndexes = [[NSMutableDictionary alloc] init];
        self.selectedCells = [[NSMutableDictionary alloc] init];
        self.documentCabinetHeaders = [[NSMutableDictionary alloc] init];
        self.loadingView = [[LoadingView alloc] init];
        
        // Initial select first section
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSArray *arr = [userDefault objectForKey:kSelectedSectionCabinetList];
        if (!arr)
        {
            [self.selectedSections addObject:@"0"];
        }
        else
        {
            self.selectedSections = [[NSMutableArray alloc] initWithArray:arr];
        }
        
        // Initialization code
        self.tbDocumentCabinet = [[UITableView alloc] initWithFrame:frame];
        self.tbDocumentCabinet.delegate = self;
        self.tbDocumentCabinet.dataSource = self;
        self.tbDocumentCabinet.allowsSelection = NO;
        [self addSubview:self.tbDocumentCabinet];
        [self.tbDocumentCabinet setSeparatorColor:kWhiteLightGrayColor];
        
        //Add header (pull to refresh) to tableview
        self.headerViewRefresh = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tbDocumentCabinet.bounds.size.height, self.tbDocumentCabinet.bounds.size.width, self.tbDocumentCabinet.bounds.size.height)];
        [self.tbDocumentCabinet addSubview:self.headerViewRefresh];
        
        //Observe for thumb download event
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDownloadThumb:) name:NotificationDownloadThumb object:nil];
    }
    return self;
}

- (void)dealloc {
    //Observe for thumb download event
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([DocumentDataManager getInstance].delegateDownloadImage == self)
        [DocumentDataManager getInstance].delegateDownloadImage = nil;
}

- (void)loadData {
    [self.selectedCells removeAllObjects];
    [self.selectedIndexes removeAllObjects];
    
    if (![[CommonDataManager getInstance] isCommonDataAvailableWithKey:DATA_COMMON_KEY]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView startLoadingInView:self];
        });
        self.loadingView.threadObj = [[CommonDataManager getInstance] reloadCommonDataWithKey:DATA_COMMON_KEY];
    } else {
        [self loadDocumentsInCab];
    }
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
	NSNumber *selectedIndex = [self.selectedIndexes objectForKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
	return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

- (void)loadDocumentsInCab {
    //[[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(loadDocumentsInCab:threadObj:) argument:@""];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
        [self.loadingView startLoadingInView:self];
    });
    
    // Load data
    NSLog(@"FileThis - loadDocumentsInCab - Start");
    [self.arrDocumentCabinets removeAllObjects];
    NSArray *allDocumentCabinets = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentCabinets]];
    for (DocumentCabinetObject *documentCabObj in allDocumentCabinets) {
        if ([documentCabObj.cabinetObj.docCount intValue] > 0 || [documentCabObj.cabinetObj.id intValue] < 0) {
            if (![self.arrDocumentCabinets containsObject:documentCabObj]) {
//                NSLog(@"FileThis - Not contain object %@", documentCabObj.cabinetObj.name);
                [self.arrDocumentCabinets addObject:documentCabObj];
            } else {
//                NSLog(@"FileThis - contain object %@", documentCabObj.cabinetObj.name);
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
//        NSLog(@"FileThis - self.arrDocumentCabinets count = %d", [self.arrDocumentCabinets count]);
        [self.loadingView stopLoading];
        [self.tbDocumentCabinet reloadData];
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_FINISHED_DISPLAYING_DOCUMENT_LIST];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
    });
}

- (void)addDocumentCabinetAndSort:(DocumentCabinetObject *)documentCab {
    [self.arrDocumentCabinets addObject:documentCab];
    [self sortDocumentCabinetList];
}

- (void)sortDocumentCabinetList {
    [CommonFunc sortDocumentCabinets:self.arrDocumentCabinets];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Setter
- (void)setLoadingData:(BOOL)loading {
    _loadingData = loading;
    if (!_loadingData)
    {
        [self.headerViewRefresh egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbDocumentCabinet];
    }
}

#pragma mark - Overriden methods
- (void)layoutSubviews
{
    self.tbDocumentCabinet.frame = self.bounds;
    [self.loadingView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

#pragma mark - documentgroupheaderdelegate
- (void)didViewAllButtonTouched:(id)sender documentGroup:(id)documentGroup {
    DocumentCabinetObject *documentCabinet = (DocumentCabinetObject *)documentGroup;
    
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate goToDocumentGroupViewController:documentCabinet];
}

- (NSIndexPath *)indexPathOfDocument:(DocumentObject *)document {
    for (DocumentCabinetObject *documentCab in self.arrDocumentCabinets) {
        if ([documentCab.arrDocuments containsObject:document]) {
            return [NSIndexPath indexPathForItem:document inSection:[self.arrDocumentCabinets indexOfObject:documentCab]];
        }
    }
    
    return nil;
}

#pragma mark - uitableviewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.arrDocumentCabinets count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([self.selectedSections containsObject:[NSString stringWithFormat:@"%d", section]]) {
        if (section >= [self.arrDocumentCabinets count]) return 0;
        
        DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:section];
        if (documentCabinet.arrDocuments == nil) return 0;
        if ([documentCabinet.arrDocuments count] > MAX_ROWS_IN_SECTION) return MAX_ROWS_IN_SECTION;
        return [documentCabinet.arrDocuments count];
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
//    DocumentObject *document = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
//    
//    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate goToDocumentDetail:document documents:documentCabinet.arrDocuments];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEIGHT_FOR_HEADER_SECTION;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section >= [self.arrDocumentCabinets count]) return 0;
    DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
    
    if (indexPath.row >= [documentCabinet.arrDocuments count]) return 0;
    
    // If our cell is selected, return double height
	if([self cellIsSelected:indexPath]) {
		return [self calculateHeightForIndexPath:indexPath];
	}
	
	// Cell isn't selected so return single height
    CGFloat heightForTagView = 0;
    if (indexPath.row < documentCabinet.arrDocuments.count) {
        DocumentObject *document = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
        heightForTagView = [self getHeightForTagView:document];
    }
    float y = 40;
    return MAX(HEIGHT_FOR_ROW, y + heightForTagView);
	//return HEIGHT_FOR_ROW + heightForTagView;
}

- (CGFloat)getHeightForTagView:(DocumentObject *)document {
    float widthConstraint = self.tbDocumentCabinet.frame.size.width - 135;
    int row = [TagListView getRowCountForDocument:document byWidth:widthConstraint];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (row > 3)
            row = 3;
    }
    
    return row * TAG_VIEW_HEIGHT;
}

- (int)calculateHeightForIndexPath:(NSIndexPath *)indexPath
{
    DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
    DocumentObject *document = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
    
    DocumentCell *selectedCell = [self.selectedCells objectForKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    CGFloat heightForTagView = [self getHeightForTagView:document];
    int height = HEIGHT_FOR_ROW + selectedCell.documentInfoView.frame.size.height +heightForTagView;
    return height;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if ([self.arrDocumentCabinets count] == 0 || section >= [self.arrDocumentCabinets count]) return nil;
    
    DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:section];
    DocumentGroupHeaderView *headerView = [[DocumentGroupHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, HEIGHT_FOR_HEADER_SECTION) documentGroup:documentCabinet];
    
    if ([documentCabinet.cabinetObj.id intValue] < 0 || [documentCabinet.cabinetObj.type isEqualToString:kCabinetVitalRecordType]) {
        [headerView.lblCabinetName setTextColor:kMaroonColor];
    } else {
        [headerView.lblCabinetName setTextColor:kDarkGrayColor];
    }
    
    BOOL isExpand = [self.selectedSections containsObject:[NSString stringWithFormat:@"%d", section]];
    [headerView updateIcon:isExpand];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSectionTouched:)];
    gesture.accessibilityValue = [NSString stringWithFormat:@"%d", section];
    [headerView addGestureRecognizer:gesture];
    
    if (![self.documentCabinetHeaders objectForKey:documentCabinet.cabinetObj.id]) {
        [self.documentCabinetHeaders setObject:headerView forKey:documentCabinet.cabinetObj.id];
    }
    
    headerView.delegate = self;
    return headerView;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DocumentCell *cell = nil;
    static NSString *cellFollowingIdentifier = @"DocumentCabinetCell";
	cell = [self.tbDocumentCabinet dequeueReusableCellWithIdentifier:cellFollowingIdentifier];
    
    // Get data object from array
	if (cell == nil) {
		cell = [[DocumentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellFollowingIdentifier tableView:tableView];
		cell.accessoryType  = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    cell.delegate = self;
    
    if (indexPath.section >= [self.arrDocumentCabinets count]) return cell;
    DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
    
    if (indexPath.row >= [documentCabinet.arrDocuments count]) return cell;
    DocumentObject *documentObj = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
    
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

- (void)handleSectionTouched:(id)sender {
    NSString *section = ((UITapGestureRecognizer *)sender).accessibilityValue;
    if (![self.selectedSections containsObject:section]) {
        [self.selectedSections addObject:section];
    } else {
        [self.selectedSections removeObject:section];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:self.selectedSections forKey:kSelectedSectionCabinetList];
    
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, [self.arrDocumentCabinets count])];
    [self.tbDocumentCabinet reloadSections:mutableIndexSet withRowAnimation:UITableViewRowAnimationFade];
}

- (void)clearData {
    [self.arrDocumentCabinets removeAllObjects];
    [self.tbDocumentCabinet reloadData];
}

#pragma mark - DocumentCellDelegate
- (void)didButtonInfoTouched:(id)sender for:(DocumentObject *)docObj {
    DocumentCell *selectedCell = (DocumentCell *)sender;
    NSIndexPath *indexPath = [self.tbDocumentCabinet indexPathForCell:selectedCell];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.pathDocumentInfoViewed = indexPath;
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
    [self.tbDocumentCabinet beginUpdates];
	[self.tbDocumentCabinet endUpdates];
}

- (void)didCloseButtonTouched:(id)sender for:(DocumentObject *)docObj {
    DocumentCell *selectedCell = (DocumentCell *)sender;
    NSIndexPath *indexPath = [self.tbDocumentCabinet indexPathForCell:selectedCell];
    
    // Store cell 'selected' state keyed on indexPath
	NSNumber *selectedValue = [NSNumber numberWithBool:NO];
	[self.selectedIndexes setObject:selectedValue forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    [self.selectedCells setObject:selectedCell forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    
	// This is where magic happens...
    [self.tbDocumentCabinet beginUpdates];
	[self.tbDocumentCabinet endUpdates];
}

- (void)documentCell:(DocumentCell *)cell willUpdateDocumentValue:(DocumentObject *)newDoc withProperties:(NSArray *)properties {
    BOOL res = [[DocumentDataManager getInstance] updateDocumentInfo:newDoc];
    if (res) {
        NSIndexPath *indexpath = [self.tbDocumentCabinet indexPathForCell:cell];
        if (indexpath) {
            DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:indexpath.section];
            DocumentObject *updateObj = (DocumentObject*)[CommonFunc findObjectWithValue:newDoc.id bykey:@"id" fromArray:documentCabinet.arrDocuments];
            if (updateObj) {
                [updateObj updateProperties:properties fromObject:newDoc];
                [self.tbDocumentCabinet reloadData];
                Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_EDIT_DOC];
                [event setContent:updateObj];
                [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
            }
        }
    } else {
        [self.tbDocumentCabinet reloadData];
    }
}

- (void)tagViewDidEditTouched:(id)sender forDocument:(DocumentObject *)docObj
{
    DocumentCell *selectedCell = (DocumentCell *)sender;
    NSIndexPath *indexPath = [self.tbDocumentCabinet indexPathForCell:selectedCell];
    
    DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    
    [appDelegate goToDocumentDetail:docObj documents:documentCabinet.arrDocuments actionType:ACTIONTYPE_EDIT_TAGS];
}

- (void)didTouchCell:(id)sender documentObject:(DocumentObject *)docObj {
    DocumentCell *documentCell = sender;
    NSIndexPath *indexPath = [self.tbDocumentCabinet indexPathForCell:documentCell];
    DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
    DocumentObject *document = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
    
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate goToDocumentDetail:document documents:documentCabinet.arrDocuments];
}

#pragma mark - DownloadThumbnailProtocol
- (void)didDownloadImage:(UIImage*)image forDocument:(DocumentObject*)doc {
    //NSArray *rows = self.tbDocumentCabinet.indexPathsForVisibleRows;
    //[self.tbDocumentCabinet reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationNone];
    NSArray *cells = [self.tbDocumentCabinet visibleCells];
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
