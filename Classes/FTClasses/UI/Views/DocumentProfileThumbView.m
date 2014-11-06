//
//  DocumentProfileThumbView.m
//  FileThis
//
//  Created by Manh nguyen on 1/10/14.
//
//

#import "DocumentProfileThumbView.h"
#import "CommonLayout.h"
#import "MyCollectionFlowLayout.h"
#import "DocumentThumbCell.h"
#import "DocumentGroupCollectionHeaderView.h"
#import "DocumentProfileObject.h"
#import "DocumentGroupHeaderView.h"
#import "CommonDataManager.h"
#import "ProfileDataManager.h"
#import "DocumentDataManager.h"
#import "FTMobileAppDelegate.h"
#import "EventManager.h"
#import "LoadingView.h"
#import "CommonFunc.h"
#import "CacheManager.h"
#import "UIImage+Resize.h"

#define HEIGHT_FOR_HEADER_SECTION  40
#define MAX_ROWS_IN_SECTION 5
#define MAX_ROWS_IN_SECTION_LANDSCAPE 7

#define kDocumentCellIdentifier @"DocumentCell"
#define kDocumentGroupHeaderIdentifier  @"DocumentGroupHeader"

@implementation DocumentProfileThumbView

- (id)initWithFrame:(CGRect)frame showSectionHeaders:(BOOL)showed showAllDocs:(BOOL)showAllDocs {
    self = [super initWithFrame:frame];
    if (self) {
        self.showSectionHeaders = showed;
        self.showAll = showAllDocs;
        
        self.collectDocumentProfile = [CommonLayout createCollectionView:CGRectMake(0,0, self.frame.size.width, self.frame.size.height) backgroundColor:kClearColor layout:[[MyCollectionFlowLayout alloc] init] cellClass:[DocumentThumbCell class] cellIdentifier:kDocumentCellIdentifier superView:self delegateDataSource:self];
        self.collectDocumentProfile.allowsSelection = YES;
        self.collectDocumentProfile.scrollEnabled = YES;
        self.collectDocumentProfile.alwaysBounceVertical = YES;
        [self.collectDocumentProfile setBackgroundColor:kWhiteColor];
        [self.collectDocumentProfile registerClass:[DocumentGroupCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDocumentGroupHeaderIdentifier];
        
        self.selectedSections = [[NSMutableArray alloc] init];
        self.documentProfileHeaders = [[NSMutableDictionary alloc] init];
        self.arrDocumentProfiles  = [[NSMutableArray alloc] init];
        
        // Initial select first section
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSArray *arr = [userDefault objectForKey:kSelectedSectionProfileThumb];
        if (!arr)
        {
            [self.selectedSections addObject:@"0"];
        }
        else
        {
            self.selectedSections = [[NSMutableArray alloc] initWithArray:arr];
        }
        
        //Add header (pull to refresh) to tableview
        self.headerViewRefresh = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.collectDocumentProfile.bounds.size.height, self.collectDocumentProfile.bounds.size.width, self.collectDocumentProfile.bounds.size.height)];
        [self.collectDocumentProfile addSubview:self.headerViewRefresh];
        
        //Observe for thumb download event
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDownloadThumb:) name:NotificationDownloadThumb object:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
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
        [[CommonDataManager getInstance] reloadCommonDataWithKey:DATA_COMMON_KEY];
    } else {
        [self loadDocumentsInProfile];
    }
}

- (void)loadDocumentsInProfile {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self];
    });
    
    // Load all documents
    [self.arrDocumentProfiles removeAllObjects];
    NSArray *allDocumentProfiles = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentProfiles]];
    for (DocumentProfileObject *documentProfileObj in allDocumentProfiles) {
        if ([documentProfileObj.arrDocuments count] > 0) {
            [self.arrDocumentProfiles addObject:documentProfileObj];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
        [self.collectDocumentProfile reloadData];
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_FINISHED_DISPLAYING_DOCUMENT_LIST];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
    });
}

- (void)clearData {
    [self.arrDocumentProfiles removeAllObjects];
    [self.collectDocumentProfile reloadData];
}

- (void)layoutSubviews {
    [self.collectDocumentProfile setFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
    [self.loadingView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

#pragma mark - Setter
- (void)setLoadingData:(BOOL)loading {
    _loadingData = loading;
    if (!_loadingData)
    {
        [self.headerViewRefresh egoRefreshScrollViewDataSourceDidFinishedLoading:self.collectDocumentProfile];
    }
}

#pragma mark - documentgroupheaderdelegate
- (void)didViewAllButtonTouched:(id)sender documentGroup:(id)documentGroup {
    DocumentProfileObject *documentProfile = (DocumentProfileObject *)documentGroup;
    
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate goToDocumentGroupViewController:documentProfile];
}

#pragma mark - uitableviewdelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [collectionView.collectionViewLayout invalidateLayout];
    return [self.arrDocumentProfiles count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.selectedSections containsObject:[NSString stringWithFormat:@"%d", section]]) {
        if ([self.arrDocumentProfiles count] == 0) return 0;
        DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:section];
        
        if (self.showAll) return [documentProfile.arrDocuments count];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (documentProfile.arrDocuments.count > MAX_ROWS_IN_SECTION_PHONE)
                return MAX_ROWS_IN_SECTION_PHONE;
            return documentProfile.arrDocuments.count;
        }
        else if (self.bounds.size.width > self.bounds.size.height) {
            if ([documentProfile.arrDocuments count] > MAX_ROWS_IN_SECTION_LANDSCAPE) return MAX_ROWS_IN_SECTION_LANDSCAPE;
            return [documentProfile.arrDocuments count];
        } else {
            if ([documentProfile.arrDocuments count] > MAX_ROWS_IN_SECTION) return MAX_ROWS_IN_SECTION;
            return [documentProfile.arrDocuments count];
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DocumentThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentCellIdentifier forIndexPath:indexPath];
    
    // Get data object from array
    if ([self.arrDocumentProfiles count] == 0) return cell;
    DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:indexPath.section];
    if (indexPath.row >= [documentProfile.arrDocuments count]) return nil;
    
    DocumentObject *documentObj = [documentProfile.arrDocuments objectAtIndex:indexPath.row];
    
    //[DocumentDataManager getInstance].delegateDownloadImage = self;
    //[[DocumentDataManager getInstance] loadThumbnailForImageView:cell.thumbImage docObj:documentObj];
    if ([[CommonDataManager getInstance] isDocumentThumbDataAvailable:documentObj]) {
        //[documentObj.docThumbImage setToImageView:cell.thumbImage];
    } else {
        [[DocumentDataManager getInstance] downloadThumbnailForDocument:documentObj];
    }
    
    [cell updateCellWithObject:documentObj];
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    UICollectionReusableView *reusableview = nil;
    
    if (kind == UICollectionElementKindSectionHeader) {
        DocumentGroupCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDocumentGroupHeaderIdentifier forIndexPath:indexPath];
        
        if ([self.arrDocumentProfiles count] == 0) return headerView;
        
        id documentGroup = [self.arrDocumentProfiles objectAtIndex:indexPath.section];
        headerView.documentGroupObj = documentGroup;
        [headerView updateData:documentGroup];
        
        BOOL isExpand = [self.selectedSections containsObject:[NSString stringWithFormat:@"%d", indexPath.section]];
        [headerView updateIcon:isExpand];
        headerView.delegate = self;
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSectionTouched:)];
        gesture.accessibilityValue = [NSString stringWithFormat:@"%d", indexPath.section];
        [headerView addGestureRecognizer:gesture];
        
        reusableview = headerView;
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.showSectionHeaders) {
        return CGSizeMake(collectionView.frame.size.width, HEIGHT_FOR_HEADER_SECTION);
    }
    
    return CGSizeMake(0, 0);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.bounds.size.width > self.bounds.size.height) {
        return CGSizeMake(135, 200);
    }
    return CGSizeMake(140, 200);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section < [self.arrDocumentProfiles count] && self.showSectionHeaders) {
        DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:section];
        if ([documentProfile.arrDocuments count] > 0 && [self.selectedSections containsObject:[NSString stringWithFormat:@"%d", section]]) {
            return UIEdgeInsetsMake(0, 0, 20, 0);
        }
    }
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (void)handleSectionTouched:(id)sender {
    if (!self.showSectionHeaders) return;
    
    NSString *section = ((UITapGestureRecognizer *)sender).accessibilityValue;
    if (![self.selectedSections containsObject:section]) {
        [self.selectedSections addObject:section];
    } else {
        [self.selectedSections removeObject:section];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:self.selectedSections forKey:kSelectedSectionProfileThumb];
    
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, [self.arrDocumentProfiles count])];
    [self.collectDocumentProfile reloadSections:mutableIndexSet];
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DocumentProfileObject *documentProfile = [self.arrDocumentProfiles objectAtIndex:indexPath.section];
    DocumentObject *document = [documentProfile.arrDocuments objectAtIndex:indexPath.row];
    
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate goToDocumentDetail:document documents:documentProfile.arrDocuments];
}

#pragma mark - DownloadThumbnailProtocol
- (void)didDownloadImage:(UIImage*)image forDocument:(DocumentObject*)doc {
    //NSArray *items = self.collectDocumentProfile.indexPathsForVisibleItems;
    //[self.collectDocumentProfile reloadItemsAtIndexPaths:items];
    NSArray *cells = [self.collectDocumentProfile visibleCells];
    for (DocumentThumbCell *cell in cells) {
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
