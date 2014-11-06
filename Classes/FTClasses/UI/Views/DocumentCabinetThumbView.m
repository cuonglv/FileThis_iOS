//
//  DocumentCabinetThumbView.m
//  FileThis
//
//  Created by Manh nguyen on 1/10/14.
//
//

#import "DocumentCabinetThumbView.h"
#import "CommonLayout.h"
#import "MyCollectionFlowLayout.h"
#import "EventManager.h"
#import "CommonDataManager.h"
#import "CabinetDataManager.h"
#import "DocumentDataManager.h"
#import "ThreadManager.h"
#import "DocumentGroupHeaderView.h"
#import "FTMobileAppDelegate.h"
#import "DocumentThumbCell.h"
#import "DocumentGroupCollectionHeaderView.h"
#import "DocumentGroupCollectionEditView.h"
#import "CommonFunc.h"
#import "CacheManager.h"
#import "UIImage+Resize.h"

#define HEIGHT_FOR_HEADER_SECTION  40
#define HEIGHT_FOR_HEADER_EDIT      40
#define HEIGHT_FOR_FOOTER_SECTION  10
#define MAX_ROWS_IN_SECTION             5
#define MAX_ROWS_IN_SECTION_LANDSCAPE   7

#define kDocumentCellIdentifier @"DocumentCell"
#define kDocumentGroupHeaderIdentifier  @"DocumentGroupHeader"
#define kDocumentGroupHeaderEditIdentifier  @"DocumentGroupHeaderEdit"

@implementation DocumentCabinetThumbView

- (id)initWithFrame:(CGRect)frame showSectionHeaders:(BOOL)showed showAllDocs:(BOOL)showAllDocs canReload:(BOOL)canReload {
    self = [super initWithFrame:frame];
    if (self) {
        self.showSectionHeaders = showed;
        self.showAll = showAllDocs;
        self.isEditingMode = NO;
        
        self.collectDocumentCabinet = [CommonLayout createCollectionView:CGRectMake(0,0, self.frame.size.width, self.frame.size.height) backgroundColor:kClearColor layout:[[MyCollectionFlowLayout alloc] init] cellClass:[DocumentThumbCell class] cellIdentifier:kDocumentCellIdentifier superView:self delegateDataSource:self];
        self.collectDocumentCabinet.allowsSelection = YES;
        self.collectDocumentCabinet.scrollEnabled = YES;
        self.collectDocumentCabinet.alwaysBounceVertical = YES;
        [self.collectDocumentCabinet setBackgroundColor:kWhiteColor];
        
        if (self.showSectionHeaders) {
            [self.collectDocumentCabinet registerClass:[DocumentGroupCollectionHeaderView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDocumentGroupHeaderIdentifier];
        } else {
            [self.collectDocumentCabinet registerClass:[DocumentGroupCollectionEditView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDocumentGroupHeaderEditIdentifier];
        }
        
        self.selectedDocuments = [[NSMutableArray alloc] init];
        self.selectedSections = [[NSMutableArray alloc] init];
        self.documentCabinetHeaders = [[NSMutableDictionary alloc] init];
        self.arrDocumentCabinets  = [[NSMutableArray alloc] init];
        
        // Initial select first section
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSArray *arr = [userDefault objectForKey:kSelectedSectionCabinetThumb];
        if (!arr)
        {
            [self.selectedSections addObject:@"0"];
        }
        else
        {
            self.selectedSections = [[NSMutableArray alloc] initWithArray:arr];
        }
        
        //Observe for thumb download event
        [[NSNotificationCenter defaultCenter] removeObserver:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDownloadThumb:) name:NotificationDownloadThumb object:nil];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}

- (void)addHeaderPullToRefresh {
    //Add header (pull to refresh) to tableview
    self.headerViewRefresh = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.collectDocumentCabinet.bounds.size.height, self.collectDocumentCabinet.bounds.size.width, self.collectDocumentCabinet.bounds.size.height)];
    [self.collectDocumentCabinet addSubview:self.headerViewRefresh];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    if ([DocumentDataManager getInstance].delegateDownloadImage == self)
        [DocumentDataManager getInstance].delegateDownloadImage = nil;
}

- (void)layoutSubviews {
    [self.collectDocumentCabinet setFrame:CGRectMake(0,0, self.frame.size.width, self.frame.size.height)];
    [self.loadingView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
}

- (void)loadData {
    if (![[CommonDataManager getInstance] isCommonDataAvailableWithKey:DATA_COMMON_KEY]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView startLoadingInView:self];
        });
        self.loadingView.threadObj = [[CommonDataManager getInstance] reloadCommonDataWithKey:DATA_COMMON_KEY];
    } else {
        [self loadDocumentsInCab];
    }
}

- (void)loadDocumentsInCab {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self];
    });
    
    // Load data
    [self.arrDocumentCabinets removeAllObjects];
    NSArray *allDocumentCabinets = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentCabinets]];
    for (DocumentCabinetObject *documentCabObj in allDocumentCabinets) {
        if ([documentCabObj.cabinetObj.docCount intValue] > 0 || [documentCabObj.cabinetObj.id intValue] < 0) {
            if (![self.arrDocumentCabinets containsObject:documentCabObj]) {
                [self.arrDocumentCabinets addObject:documentCabObj];
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
        [self.collectDocumentCabinet reloadData];
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_FINISHED_DISPLAYING_DOCUMENT_LIST];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
    });
}

- (void)clearData {
    [self.arrDocumentCabinets removeAllObjects];
    [self.collectDocumentCabinet reloadData];
}

#pragma mark - Setter
- (void)setLoadingData:(BOOL)loading {
    _loadingData = loading;
    if (!_loadingData)
    {
        [self.headerViewRefresh egoRefreshScrollViewDataSourceDidFinishedLoading:self.collectDocumentCabinet];
    }
}

#pragma mark - documentgroupheaderdelegate
- (void)didViewAllButtonTouched:(id)sender documentGroup:(id)documentGroup {
    DocumentCabinetObject *documentCabinet = (DocumentCabinetObject *)documentGroup;
    
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate goToDocumentGroupViewController:documentCabinet];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    [collectionView.collectionViewLayout invalidateLayout];
    return [self.arrDocumentCabinets count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if ([self.arrDocumentCabinets count] == 0) return 0;
    
    if ([self.selectedSections containsObject:[NSString stringWithFormat:@"%d", section]]) {
        DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:section];
        if (self.showAll) {
            return [documentCabinet.arrDocuments count];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (documentCabinet.arrDocuments.count > MAX_ROWS_IN_SECTION_PHONE)
                return MAX_ROWS_IN_SECTION_PHONE;
            return documentCabinet.arrDocuments.count;
        }
        else if (self.bounds.size.width > self.bounds.size.height) {
            if ([documentCabinet.arrDocuments count] > MAX_ROWS_IN_SECTION_LANDSCAPE) return MAX_ROWS_IN_SECTION_LANDSCAPE;
            return [documentCabinet.arrDocuments count];
        } else {
            if ([documentCabinet.arrDocuments count] > MAX_ROWS_IN_SECTION) return MAX_ROWS_IN_SECTION;
            return [documentCabinet.arrDocuments count];
        }
    }
    return 0;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    DocumentThumbCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentCellIdentifier forIndexPath:indexPath];
    
    // Get data object from array
    if ([self.arrDocumentCabinets count] == 0) return cell;
    
    DocumentCabinetObject *documentCabinet = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
    if (indexPath.row >= [documentCabinet.arrDocuments count]) return cell;
    
    DocumentObject *documentObj = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
    if ([self.selectedDocuments containsObject:documentObj]) {
        cell.isSelected = YES;
    } else {
        cell.isSelected = NO;
    }
    
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
        if (self.showSectionHeaders) {
            DocumentGroupCollectionHeaderView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDocumentGroupHeaderIdentifier forIndexPath:indexPath];
            
            if ([self.arrDocumentCabinets count] == 0) return headerView;
            id documentGroup = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
            headerView.documentGroupObj = documentGroup;
            [headerView updateData:documentGroup];
            
            BOOL isExpand = [self.selectedSections containsObject:[NSString stringWithFormat:@"%d", indexPath.section]];
            [headerView updateIcon:isExpand];
            headerView.delegate = self;
            [headerView setUserInteractionEnabled:YES];
            
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleThumbSectionTouched:)];
            gesture.accessibilityValue = [NSString stringWithFormat:@"%d", indexPath.section];
            [headerView addGestureRecognizer:gesture];
            
            reusableview = headerView;
        } else {
            DocumentGroupCollectionEditView *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:kDocumentGroupHeaderEditIdentifier forIndexPath:indexPath];
            
            if ([self.arrDocumentCabinets count] == 0) return headerView;
            id documentGroup = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
            
            [headerView setDocumentGroupData:documentGroup];
            if (self.isEditingMode) {
                int numDocs = 0;
                if ([documentGroup isKindOfClass:[DocumentCabinetObject class]]) {
                    numDocs = [((DocumentCabinetObject *)documentGroup).arrDocuments count];
                } else {
                    numDocs = [((DocumentProfileObject *)documentGroup).arrDocuments count];
                }
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                    [headerView.lblHeaderInSection setText:[NSString stringWithFormat:@"%d of %d documents selected", [self.selectedDocuments count], numDocs]];
                } else {
                    [headerView.lblHeaderInSection setText:[NSString stringWithFormat:@"%d Selected", [self.selectedDocuments count]]];
                }
            }
            
            headerView.delegate = self;
            reusableview = headerView;
            self.groupCollectionEditView = headerView;
            
            if (self.isEditingMode) {
                [self.groupCollectionEditView.btnSelect setHidden:YES];
                [self.groupCollectionEditView.btnCancel setHidden:NO];
            } else {
                [self.groupCollectionEditView.btnSelect setHidden:NO];
                [self.groupCollectionEditView.btnCancel setHidden:YES];
            }
        }
    }
    
    return reusableview;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section {
    if (self.showSectionHeaders) {
        return CGSizeMake(collectionView.frame.size.width, HEIGHT_FOR_HEADER_SECTION);
    }
    
    return CGSizeMake(collectionView.frame.size.width, HEIGHT_FOR_HEADER_EDIT);
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (self.bounds.size.width > self.bounds.size.height) {
        return CGSizeMake(135, 200);
    }
    return CGSizeMake(140, 200);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    if (section < [self.arrDocumentCabinets count]) {
        DocumentCabinetObject *documentCab = [self.arrDocumentCabinets objectAtIndex:section];
        if ([documentCab.arrDocuments count] > 0 && [self.selectedSections containsObject:[NSString stringWithFormat:@"%d", section]]) {
            return UIEdgeInsetsMake(0, 0, 10, 0);
        }
    }
    
    return UIEdgeInsetsMake(0, 0, 0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section {
    return 0.0;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DocumentThumbCell *cell = (DocumentThumbCell *)[collectionView cellForItemAtIndexPath:indexPath];
    id docGroup = [self.arrDocumentCabinets objectAtIndex:indexPath.section];
    DocumentObject *docObj = nil;
    NSMutableArray *documents = nil;
    if ([docGroup isKindOfClass:[DocumentCabinetObject class]]) {
        docObj = [((DocumentCabinetObject *)docGroup).arrDocuments objectAtIndex:indexPath.row];
        documents = ((DocumentCabinetObject *)docGroup).arrDocuments;
    } else {
        docObj = [((DocumentProfileObject *)docGroup).arrDocuments objectAtIndex:indexPath.row];
        documents = ((DocumentProfileObject *)docGroup).arrDocuments;
    }
    
    if (self.isEditingMode) {
        cell.isSelected = !cell.isSelected;
        [cell.checkButton setHidden:!cell.isSelected];
        
        if (![self.selectedDocuments containsObject:docObj]) {
            [self.selectedDocuments addObject:docObj];
            if ([self.delegate respondsToSelector:@selector(didSelectDocument:documentId:)]) {
                [self.delegate didSelectDocument:self documentId:docObj.id];
            }
        } else {
            [self.selectedDocuments removeObject:docObj];
            
            if ([self.delegate respondsToSelector:@selector(didDeSelectDocument:documentId:)]) {
                [self.delegate didDeSelectDocument:self documentId:docObj.id];
            }
        }
        
        [self.groupCollectionEditView.lblHeaderInSection setText:[NSString stringWithFormat:@"%d of %d documents selected", [self.selectedDocuments count], [documents count]]];
    } else {
        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate goToDocumentDetail:docObj documents:documents];
    }
}

- (void)handleThumbSectionTouched:(id)sender {
    NSString *section = ((UITapGestureRecognizer *)sender).accessibilityValue;
    if (![self.selectedSections containsObject:section]) {
        [self.selectedSections addObject:section];
    } else {
        [self.selectedSections removeObject:section];
    }
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:self.selectedSections forKey:kSelectedSectionCabinetThumb];
    
    NSMutableIndexSet *mutableIndexSet = [[NSMutableIndexSet alloc] initWithIndexesInRange:NSMakeRange(0, [self.arrDocumentCabinets count])];
    [self.collectDocumentCabinet reloadSections:mutableIndexSet];
}

- (void)setSelectDocument:(id)documentId {
    if (self.showSectionHeaders) return;
    if ([self.arrDocumentCabinets count] == 0) return;
    
    id docGroup = [self.arrDocumentCabinets objectAtIndex:0];
    DocumentObject *docObj = nil;
    NSMutableArray *docs = nil;
    if ([docGroup isKindOfClass:[DocumentCabinetObject class]]) {
        docs = ((DocumentCabinetObject *)docGroup).arrDocuments;
    } else {
        docs = ((DocumentProfileObject *)docGroup).arrDocuments;
    }
    
    for (DocumentObject *doc in docs) {
        if ([doc.id isEqual:documentId]) {
            docObj = doc;
            break;
        }
    }
    
    if (docObj != nil) {
        if (![self.selectedDocuments containsObject:docObj]) {
            [self.selectedDocuments addObject:docObj];
            [self.collectDocumentCabinet reloadData];
        }
    }
}

- (void)setDeSelectDocument:(id)documentId {
    if (self.showSectionHeaders) return;
    if ([self.arrDocumentCabinets count] == 0) return;
    
    id docGroup = [self.arrDocumentCabinets objectAtIndex:0];
    DocumentObject *docObj = nil;
    NSMutableArray *docs = nil;
    if ([docGroup isKindOfClass:[DocumentCabinetObject class]]) {
        docs = ((DocumentCabinetObject *)docGroup).arrDocuments;
    } else {
        docs = ((DocumentProfileObject *)docGroup).arrDocuments;
    }
    
    for (DocumentObject *doc in docs) {
        if ([doc.id isEqual:documentId]) {
            docObj = doc;
            break;
        }
    }
    
    if (docObj != nil) {
        if ([self.selectedDocuments containsObject:docObj]) {
            [self.selectedDocuments removeObject:docObj];
            [self.collectDocumentCabinet reloadData];
        }
    }
}

- (void)removeDocument:(NSMutableArray *)removedocuments {
    NSMutableArray *arrCabinets = self.arrDocumentCabinets;
    id docGroup;
    NSMutableArray *documents = nil;
    if ([arrCabinets count] > 0) {
        docGroup = [arrCabinets objectAtIndex:0];
    }
    
    if ([docGroup isKindOfClass:[DocumentCabinetObject class]]) {
        documents = ((DocumentCabinetObject *)docGroup).arrDocuments;
    } else {
        documents = ((DocumentProfileObject *)docGroup).arrDocuments;
    }
    
    NSArray *docIds = [documents valueForKeyPath:@"id"];
    for (DocumentObject *docObj in removedocuments) {
        if ([docIds containsObject:docObj.id]) {
            [documents removeObjectAtIndex:[docIds indexOfObject:docObj.id]];
        }
    }
    
    [self.collectDocumentCabinet reloadData];
}

#pragma mark - DocumentGroupHeaderEdit
- (void)didShowEditingMode:(id)sender {
    if ([self.arrDocumentCabinets count] == 0) return;
    
    id docGroup = [self.arrDocumentCabinets objectAtIndex:0];
    int numDocs = 0;
    if (docGroup != nil && [docGroup isKindOfClass:[DocumentCabinetObject class]]) {
        numDocs = [((DocumentCabinetObject *)docGroup).arrDocuments count];
    } else {
        numDocs = [((DocumentProfileObject *)docGroup).arrDocuments count];
    }
    
    [self.groupCollectionEditView.lblHeaderInSection setText:[NSString stringWithFormat:@"0 of %d documents selected", numDocs]];
    self.isEditingMode = YES;
    [self.selectedDocuments removeAllObjects];
    
    if ([self.delegate respondsToSelector:@selector(didSelectButton:)]) {
        [self.delegate didSelectButton:self];
    }
}

- (void)didCancelEditingMode:(id)sender {
    [self.groupCollectionEditView.lblHeaderInSection setText:[self.groupCollectionEditView getHeaderString]];
    self.isEditingMode = NO;
    [self.selectedDocuments removeAllObjects];
    [self.collectDocumentCabinet reloadData];
    
    if ([self.delegate respondsToSelector:@selector(didCancelButton:)]) {
        [self.delegate didCancelButton:self];
    }
}

- (void)didSelectAllEditingMode:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectAllButton:)]) {
        [self.delegate didSelectAllButton:self];
    }
}

#pragma mark - DownloadThumbnailProtocol
- (void)didDownloadImage:(UIImage*)image forDocument:(DocumentObject*)doc {
    //NSArray *items = self.collectDocumentCabinet.indexPathsForVisibleItems;
    //[self.collectDocumentCabinet reloadItemsAtIndexPaths:items];
    NSArray *cells = [self.collectDocumentCabinet visibleCells];
    for (DocumentThumbCell *cell in cells) {
        [cell refreshThumbnail];
    }
}

#pragma mark - Download Thumb notification
- (void)didDownloadThumb:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.window) //Is visible on screen
            [self didDownloadImage:nil forDocument:nil];
    });
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

@end
