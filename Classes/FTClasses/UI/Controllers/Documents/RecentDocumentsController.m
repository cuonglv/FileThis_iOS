//
//  RecentDocumentsController.m
//  FileThis
//
//  Created by Cao Huu Loc on 1/21/14.
//
//

#import "RecentDocumentsController.h"
#import "CommonDataManager.h"
#import "EventManager.h"
#import "FTMobileAppDelegate.h"
#import "DocumentDataManager.h"
#import "NetworkReachability.h"
#import "Utils.h"

@interface RecentDocumentsController ()

@end

@implementation RecentDocumentsController

- (BOOL)shouldUseBackButton {
    return NO;
}

- (void)initializeScreen {
    [super initializeScreen];
    
    self.titleLabel.text = NSLocalizedString(@"ID_RECENTLY_ADDED", @"");
    //self.reloadButton = [self addTopLeftImageBarButton:[UIImage imageNamed:@"reload_icon_white_small.png"] width:35 target:self selector:@selector(handleReloadButton:)];
    self.loadingView = [[LoadingView alloc] init];
    
    // [manhnn] We dont need to reload all documents on all cabinets. We just need to reload all document on Recently Added Cabinet only.
    if (![[CommonDataManager getInstance] isCommonDataAvailableWithKey:DATA_COMMON_KEY]) {
        [self.loadingView startLoadingInView:self.view frame:self.contentView.frame];
        self.loadingView.threadObj = [[CommonDataManager getInstance] loadCommonData];
    } else {
        [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeReloadRecentSearch:threadObj:) argument:@""];
    }
    
    //Add header "pull to refresh"
    [self.documentsCabThumbView addHeaderPullToRefresh]; //Thumb view
    
    //List view
    self.headerViewRefresh = [[EGORefreshTableHeaderView alloc] initWithFrame:CGRectMake(0, 0 - self.tbDocumentList.bounds.size.height, self.tbDocumentList.bounds.size.width, self.tbDocumentList.bounds.size.height)];
    [self.tbDocumentList addSubview:self.headerViewRefresh];
    
    //Pull to refresh delegate
    self.headerViewRefresh.delegate = self;
    self.documentsCabThumbView.headerViewRefresh.delegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tbDocumentList reloadData];
}

- (void)loadRecentDocuments {
    // Get recently added cabinet
    DocumentCabinetObject *recentlyAddedCabinet = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetRecentlyAddedType];
    if (recentlyAddedCabinet != nil) {
        self.documentGroup = recentlyAddedCabinet;
        self.documentObjects = recentlyAddedCabinet.arrDocuments;
        [self.documentsCabThumbView.arrDocumentCabinets removeAllObjects];
        [self.documentsCabThumbView.arrDocumentCabinets addObject:self.documentGroup];
    }
    
    [self.documentsCabThumbView.selectedSections addObject:@"0"];
    [self.documentsCabThumbView.collectDocumentCabinet reloadData];
    [self.tbDocumentList reloadData];
}

#pragma mark - Setter
- (void)setLoadingData:(BOOL)loading {
    _loadingData = loading;
    if (!_loadingData)
    {
        [self.headerViewRefresh egoRefreshScrollViewDataSourceDidFinishedLoading:self.tbDocumentList];
    }
}

#pragma mark - Layout
- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    if (IS_IPHONE)
        return 30;
    return [super horizontalSpacingBetweenBottomCenterBarButtons];
}

#pragma mark - Button
- (void)handleReloadButton:(id)sender {
    if (![[NetworkReachability getInstance] checkInternetActiveManually]) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_NO_INTERNET_CONNECTION2", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeReloadRecentSearch:threadObj:) argument:@""];
}

- (void)executeReloadRecentSearch:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self.view frame:self.contentView.frame];
    });
    
    // Reload recent documents
    DocumentCabinetObject *recentlyAddedCabinet = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetRecentlyAddedType];
    
    // Get Cabinet ALL to put new document to.
    DocumentCabinetObject *allCabinet = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetAllType];
    
    if (recentlyAddedCabinet && allCabinet) {
        NSArray *recentDocuments = [[DocumentDataManager getInstance] getDocumentsInCabinate:recentlyAddedCabinet.cabinetObj.id];
        
        [recentlyAddedCabinet.arrDocuments removeAllObjects]; //Clear all current items to refresh entire list
        for (DocumentObject *docObj in recentDocuments) {
            //if ([recentlyAddedCabinet getDocumentById:docObj.id] == nil)
            {
                [recentlyAddedCabinet.arrDocuments addObject:docObj];
            }
            
            //if ([allCabinet getDocumentById:docObj.id] == nil)
            int index = [allCabinet getIndexDocumentById:docObj.id];
            if (index == -1)
            {
                [allCabinet.arrDocuments addObject:docObj];
            }
            else
            {
                [allCabinet.arrDocuments replaceObjectAtIndex:index withObject:docObj];
            }
        }
        
        self.documentGroup = recentlyAddedCabinet;
        self.documentObjects = recentlyAddedCabinet.arrDocuments;
        [self.documentsCabThumbView.arrDocumentCabinets removeAllObjects];
        [self.documentsCabThumbView.selectedSections addObject:@"0"];
        [self.documentsCabThumbView.arrDocumentCabinets addObject:self.documentGroup];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //[manhnn - 655] Apply sort after get results, the table will be reloaded data in sort function.
        [self didSelectSortBy:[CommonVar getSortDocumentBy]];
        
        //Update "Last update" title in "Pull to refresh" header view
        [self.headerViewRefresh refreshLastUpdatedDate];
        [self.documentsCabThumbView.headerViewRefresh refreshLastUpdatedDate];
        
        [self.loadingView stopLoading];
    });
}

#pragma mark - EventProtocol methods
- (void)didReceiveEvent:(Event *)event {
    EVENTTYPE eventType = [event getEventType];
    if (eventType == EVENT_TYPE_LOAD_COMMON_DATA || eventType == EVENT_TYPE_CANCEL_LOADING_DATA) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self loadRecentDocuments];
            [self.loadingView stopLoading];
        });
    } else if (eventType == EVENT_TYPE_ADD_TAGS_TO_DOCUMENTS) {
        NSMutableArray *documents = [event getContent];
        DocumentCabinetObject *untaggedCabinetCab = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetUntaggedType];
        [untaggedCabinetCab.arrDocuments removeObjectsInArray:documents];
        untaggedCabinetCab.cabinetObj.docCount = [NSNumber numberWithInt:[untaggedCabinetCab.arrDocuments count]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbDocumentList reloadData];
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
            [self.documentTagsView.selectTagsView filterItems];
            
            for (DocumentObject *docObj in self.selectedDocuments) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.documentObjects indexOfObject:docObj] inSection:0];
                [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
            }
        });
    } else if (eventType == EVENT_TYPE_REMOVE_TAGS_FROM_DOCUMENTS) {
        NSMutableArray *documents = [event getContent];
        DocumentCabinetObject *untaggedCabinetCab = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetUntaggedType];
        
        for (DocumentObject *docObj in documents) {
            if ([docObj.tags count] == 0) {
                if (![untaggedCabinetCab.arrDocuments containsObject:docObj]) {
                    [untaggedCabinetCab.arrDocuments addObject:docObj];
                }
            }
        }
        untaggedCabinetCab.cabinetObj.docCount = [NSNumber numberWithInt:[untaggedCabinetCab.arrDocuments count]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbDocumentList reloadData];
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
            [self.documentTagsView.selectTagsView filterItems];
            
            for (DocumentObject *docObj in self.selectedDocuments) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.documentObjects indexOfObject:docObj] inSection:0];
                [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
            }
        });
    } else if (eventType == EVENT_TYPE_ADD_CABS_TO_DOCUMENTS) {
        NSMutableArray *documents = [event getContent];
        for (DocumentObject *docObj in documents) {
            for (id cabId in docObj.cabs) {
                DocumentCabinetObject *documentCab = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabId:cabId];
                if (![documentCab.arrDocuments containsObject:docObj]) {
                    [documentCab.arrDocuments addObject:docObj];
                    
                    documentCab.cabinetObj.docCount = [NSNumber numberWithInt:[documentCab.arrDocuments count]];
                }
            }
        }
        
        DocumentCabinetObject *uncategorizedCabinet = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetUncategorizedType];
        [uncategorizedCabinet.arrDocuments removeObjectsInArray:documents];
        uncategorizedCabinet.cabinetObj.docCount = [NSNumber numberWithInt:[uncategorizedCabinet.arrDocuments count]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbDocumentList reloadData];
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
            [self.documentCabinetView.selectCabinetsView filterItems];
            
            for (DocumentObject *docObj in self.selectedDocuments) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.documentObjects indexOfObject:docObj] inSection:0];
                [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
            }
        });
    } else if (eventType == EVENT_TYPE_REMOVE_CABS_FROM_DOCUMENTS) {
        NSArray *documents = [[NSArray alloc] initWithArray:[event getContent]];
        NSArray *allDocumentCabinets = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentCabinets]];
        
        for (DocumentCabinetObject *documentCabObj in allDocumentCabinets) {
            for (DocumentObject *docObj in documents) {
                if ([documentCabObj.arrDocuments containsObject:docObj] && ![docObj.cabs containsObject:documentCabObj.cabinetObj.id]) {
                    if ([documentCabObj.arrDocuments containsObject:docObj]) {
                        [documentCabObj.arrDocuments removeObject:docObj];
                        
                        documentCabObj.cabinetObj.docCount = [NSNumber numberWithInt:[documentCabObj.arrDocuments count]];
                    }
                }
            }
        }
        
        DocumentCabinetObject *uncategorizedCabinet = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetUncategorizedType];
        for (DocumentObject *docObj in documents) {
            if ([docObj.cabs count] == 0) {
                if (![uncategorizedCabinet.arrDocuments containsObject:docObj]) {
                    [uncategorizedCabinet.arrDocuments addObject:docObj];
                }
            }
        }
        uncategorizedCabinet.cabinetObj.docCount = [NSNumber numberWithInt:[uncategorizedCabinet.arrDocuments count]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbDocumentList reloadData];
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
            [self.documentCabinetView.selectCabinetsView filterItems];
            
            for (DocumentObject *docObj in self.selectedDocuments) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.documentObjects indexOfObject:docObj] inSection:0];
                [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
            }
        });
    } else if (eventType == EVENT_TYPE_ADD_CABINET) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbDocumentList reloadData];
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
        });
    } else if (eventType == EVENT_TYPE_DELETE_DOC) {
        DocumentObject *docObj = [event getContent];
        NSArray *allDocumentCabinets = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentCabinets]];
        for (DocumentCabinetObject *documentGroup in allDocumentCabinets) {
            if ([documentGroup.arrDocuments containsObject:docObj]) {
                [documentGroup.arrDocuments removeObject:docObj];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbDocumentList reloadData];
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
        });
    } else if (eventType == EVENT_TYPE_DELETE_DOCS) {
        NSArray *documents = [[NSArray alloc] initWithArray:[event getContent]];
        NSArray *allDocumentCabinets = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentCabinets]];
        
        for (DocumentObject *docObj in documents) {
            for (DocumentCabinetObject *documentGroup in allDocumentCabinets) {
                if ([documentGroup.arrDocuments containsObject:docObj]) {
                    [documentGroup.arrDocuments removeObject:docObj];
                }
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbDocumentList reloadData];
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
        });
    } else if (eventType == EVENT_TYPE_EDIT_DOC) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbDocumentList reloadData];
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
        });
    } else if (eventType == EVENT_TYPE_REMOVE_CABINET) {
        CabinetObject *cabObj = [event getContent];
        DocumentCabinetObject *docCabObj = nil;
        NSArray *arrDocumentCabinets = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentCabinets]];
        for (DocumentCabinetObject *documentGroup in arrDocumentCabinets) {
            if ([documentGroup.cabinetObj isEqual:cabObj]) {
                docCabObj = documentGroup;
                break;
            }
        }
        
        if (docCabObj != nil) {
            DocumentCabinetObject *uncategorizedCabinet = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetUncategorizedType];
            
            for (DocumentObject *docObj in docCabObj.arrDocuments) {
                [docObj.cabs removeObject:cabObj.id];
                
                if ([docObj.cabs count] == 0) {
                    [uncategorizedCabinet.arrDocuments addObject:docObj];
                }
            }
            uncategorizedCabinet.cabinetObj.docCount = [NSNumber numberWithInt:[uncategorizedCabinet.arrDocuments count]];
            
            [[CommonDataManager getInstance] removeDocumentCabinet:docCabObj];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tbDocumentList reloadData];
                [self.documentsCabThumbView.collectDocumentCabinet reloadData];
            });
        }
    } else if (eventType == EVENT_TYPE_REMOVE_TAG) {
        DocumentCabinetObject *untaggedCabinetCab = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetUntaggedType];
        
        TagObject *tagObj = [event getContent];
        NSArray *allDocuments = [[NSArray alloc] initWithArray:[[DocumentDataManager getInstance] getAllDocuments]];
        for (DocumentObject *documentObj in allDocuments) {
            if ([documentObj.tags containsObject:tagObj.id]) {
                [documentObj.tags removeObject:tagObj.id];
                
                if ([documentObj.tags count] == 0) {
                    [untaggedCabinetCab.arrDocuments addObject:documentObj];
                }
            }
        }
        untaggedCabinetCab.cabinetObj.docCount = [NSNumber numberWithInt:[untaggedCabinetCab.arrDocuments count]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tbDocumentList reloadData];
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
        });
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

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(id)view {
    //Do a refresh
    [self handleReloadButton:nil];
    
    //Reset pull-to-refresh state (hide loading header)
    dispatch_async(dispatch_get_main_queue(), ^{
        self.loadingData = NO;
        self.documentsCabThumbView.loadingData = NO;
    });
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(id)view {
    return NO;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

@end
