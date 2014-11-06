//
//  DocumentListViewController.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "DocumentGroupListViewController.h"
#import "DocumentGroupCell.h"
#import "DocumentCabinetObject.h"
#import "CabinetObject.h"
#import "DocumentListViewController.h"
#import "CabinetDataManager.h"
#import "DocumentDataManager.h"
#import "DocumentObject.h"
#import "DocumentGroupHeaderView.h"
#import "ThreadManager.h"
#import "DocumentDetailViewController.h"
#import "CommonVar.h"
#import "CacheManager.h"
#import "FTMobileAppDelegate.h"
#import "TagDataManager.h"
#import "DocumentSearchViewController.h"
#import "CommonDataManager.h"
#import "ProfileObject.h"
#import "ProfileDataManager.h"
#import "DocumentProfileObject.h"
#import "DocumentProfileListView.h"
#import "EventManager.h"
#import "CommonFunc.h"
#import "NetworkReachability.h"
#import "Utils.h"
#import "FTSession.h"
#import "DocumentSearchViewController_iPhone.h"

@interface DocumentGroupListViewController ()

@end

@implementation DocumentGroupListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self sort:[CommonVar getSortDocumentBy]];
    if ([CommonVar getDocumentOptionView] != self.showType) {
        self.showType = [CommonVar getDocumentOptionView];
        [self.documentOptionsView.segmentControl setSelectedSegmentIndex:self.showType];
        [self updateUIBaseOnTypes];
    }
}

- (BOOL)shouldRelayoutBeforeViewAppear {
    return NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    if (self.optionPopover.isPopoverVisible) {
        [self.optionPopover dismissPopoverAnimated:NO];
    }
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self reloadUI];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.optionPopover dismissPopoverAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Initialize
- (void)initializeVariables {
    [super initializeVariables];
    
    self.type = TYPE_CABINET;
    self.showType = [CommonVar getDocumentOptionView];
    self.sortBy = [CommonVar getSortDocumentBy];
}

- (void)initializeScreen {
    [super initializeScreen];
    
    self.titleLabel.text = NSLocalizedString(@"ID_CABINETS", @"");
    self.btnSearch = [self addTopRightImageBarButton:[UIImage imageNamed:@"search_white_icon.png"] width:25 target:self selector:@selector(handleSearchButton)];
    self.btnSetting = [self addTopRightImageBarButton:[UIImage imageNamed:@"gear_icon.png"] width:40 target:self selector:@selector(handleOptionsButton:)];
    //self.reloadButton = [self addTopLeftImageBarButton:[UIImage imageNamed:@"reload_icon_white_small.png"] width:35 target:self selector:@selector(handleReloadButton:)];
    
    self.btnCabinets = [self addBottomCenterBarButton:NSLocalizedString(@"ID_CABINETS", @"") image:[UIImage imageNamed:@"cab_white_icon.png"] target:self selector:@selector(handleCabinetsButton:)];
    self.btnAccounts = [self addBottomCenterBarButton:NSLocalizedString(@"ID_ACCOUNTS", @"") image:[UIImage imageNamed:@"account_white_icon.png"] target:self selector:@selector(handleAccountsButton:)];
    self.selectedBottomCenterBarButton = self.btnCabinets;
    
    self.documentCabListView = [[DocumentCabinetListView alloc] initWithFrame:self.contentView.frame];
    [self.view addSubview:self.documentCabListView];
    
    self.documentProfileListView = [[DocumentProfileListView alloc] initWithFrame:self.documentCabListView.frame];
    [self.view addSubview:self.documentProfileListView];
    
    self.documentCabThumbView = [[DocumentCabinetThumbView alloc] initWithFrame:self.documentCabListView.frame showSectionHeaders:YES showAllDocs:NO canReload:YES];
    [self.view addSubview:self.documentCabThumbView];
    
    self.documentProfileThumbView = [[DocumentProfileThumbView alloc] initWithFrame:self.documentCabListView.frame showSectionHeaders:YES showAllDocs:NO];
    [self.view addSubview:self.documentProfileThumbView];
    
    self.loadingView = [[LoadingView alloc] init];
    
    self.btnSearch.userInteractionEnabled = self.btnSetting.userInteractionEnabled = self.bottomBarView.userInteractionEnabled = NO;
    
    [self updateUIBaseOnTypes];
    [[EventManager getInstance] addListener:self channel:CHANNEL_DATA];
    
    if ([CommonVar needToReloadAllDocuments]) {
        [self reloadAllData];
    }
    
    //Add header "pull to refresh"
    [self.documentCabThumbView addHeaderPullToRefresh];
    
    //Pull to refresh delegate
    self.documentCabListView.headerViewRefresh.delegate = self;
    self.documentCabThumbView.headerViewRefresh.delegate = self;
    self.documentProfileListView.headerViewRefresh.delegate = self;
    self.documentProfileThumbView.headerViewRefresh.delegate = self;
}

#pragma mark - Overidden
- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (BOOL)shouldHideToolBar {
    return NO;
}

- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    return 100;
}

#pragma mark - Layout
- (void)relayout {
    [super relayout];
    
    CGRect rect = CGRectMake(0, [self heightForTopBar], self.view.bounds.size.width, self.view.bounds.size.height - [self heightForTopBar] - [self heightForBottomBar]);
    self.documentCabListView.frame = rect;
    self.documentCabListView.tbDocumentCabinet.frame = CGRectMake(0, 0, rect.size.width, rect.size.height);
    self.documentCabThumbView.frame = self.documentCabListView.frame;
    self.documentCabThumbView.collectDocumentCabinet.frame = self.documentCabListView.tbDocumentCabinet.frame;
    
    [self.documentCabListView.tbDocumentCabinet reloadData];
    [self.documentCabThumbView.collectDocumentCabinet reloadData];
    
    self.documentProfileListView.frame = self.documentCabThumbView.frame = self.documentCabListView.frame = self.contentView.frame;
    self.documentProfileListView.tbDocumentProfile.frame = self.documentCabThumbView.collectDocumentCabinet.frame = self.documentCabListView.tbDocumentCabinet.frame = self.documentCabListView.bounds;
    self.documentProfileThumbView.frame = self.documentProfileListView.frame;
    self.documentProfileThumbView.collectDocumentProfile.frame = self.documentProfileListView.tbDocumentProfile.frame;
    
    [self.documentProfileListView.tbDocumentProfile reloadData];
    [self.documentProfileThumbView.collectDocumentProfile reloadData];
}

#pragma mark - Button events
- (void)handleOptionsButton:(id)sender {
    UIButton *optionButton = sender;
    CGRect selectedButtonFrame = [self.topBarView convertRect:optionButton.frame toView:self.view];
    
    if (self.optionPopover == nil) {
        if (self.documentOptionsView == nil) {
            self.documentOptionsView = [[DocumentOptionsView alloc] initWithFrame:CGRectMake(0, 0, 250, 350)];
            self.documentOptionsView.delegate = self;
        }
        
        UIViewController *optionViewController = [[UIViewController alloc] init];
        optionViewController.view = self.documentOptionsView;
        [self.documentOptionsView.segmentControl setSelectedSegmentIndex:self.showType];
        
        self.optionPopover = [[MyPopoverWrapper alloc] initWithContentViewController:optionViewController];
        [self.optionPopover setPopoverContentSize:CGSizeMake(250, 350) animated:NO];
        self.optionPopover.delegate = self;
    }
    
    [self.optionPopover presentPopoverFromRect:selectedButtonFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)handleCabinetsButton:(id)sender {
    self.type = TYPE_CABINET;
    self.titleLabel.text = NSLocalizedString(@"ID_CABINETS", @"");
    self.selectedBottomCenterBarButton = self.btnCabinets;
    [self updateUIBaseOnTypes];
}

- (void)handleAccountsButton:(id)sender {
    self.type = TYPE_PROFILE;
    self.titleLabel.text = NSLocalizedString(@"ID_ACCOUNTS", @"");
    self.selectedBottomCenterBarButton = self.btnAccounts;
    [self updateUIBaseOnTypes];
}

- (void)handleReloadButton:(id)sender {
    if (![[NetworkReachability getInstance] checkInternetActiveManually]) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_NO_INTERNET_CONNECTION2", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    [self reloadAllData];
}


- (void)handleSearchButton {
    /////////////////////////////////
    //Iphone device
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        DocumentSearchViewController_iPhone *target = [[DocumentSearchViewController_iPhone alloc] init];
        [self.navigationController pushViewController:target animated:YES];
        return;
    }
    
    /////////////////////////////////
    //Ipad device
    if ([[CommonDataManager getInstance] isCommonDataAvailableWithKey:DATA_COMMON_KEY] && [[DocumentDataManager getInstance] hasData]) {
        DocumentSearchViewController *target = [[DocumentSearchViewController alloc] init];
        [self.navigationController pushViewController:target animated:YES];
    }
}

#pragma mark - My Func
- (void)reloadAllData {
    self.btnSearch.userInteractionEnabled = self.btnSetting.userInteractionEnabled = self.bottomBarView.userInteractionEnabled = NO;
    [self.loadingView startLoadingInView:self.view frame:self.contentView.frame];
    self.loadingView.threadObj = [[CommonDataManager getInstance] loadCommonData];
}

- (void)reloadUI {
    [self.documentCabListView.tbDocumentCabinet reloadData];
    [self.documentProfileListView.tbDocumentProfile reloadData];
    
    [self.documentCabThumbView.collectDocumentCabinet reloadData];
    [self.documentProfileThumbView.collectDocumentProfile reloadData];
}

- (void)updateUIBaseOnTypes {
    if (self.type == TYPE_CABINET) {
        if (self.showType == SHOWTYPE_SNIPPET) {
            [self.documentCabListView loadData];
            [self.documentCabListView setHidden:NO];
            [self.documentCabThumbView setHidden:YES];
        } else {
            [self.documentCabThumbView loadData];
            [self.documentCabListView setHidden:YES];
            [self.documentCabThumbView setHidden:NO];
        }
        
        [self.documentProfileListView setHidden:YES];
        [self.documentProfileThumbView setHidden:YES];
    } else {
        if (self.showType == SHOWTYPE_SNIPPET) {
            [self.documentProfileListView loadData];
            [self.documentProfileListView setHidden:NO];
            [self.documentProfileThumbView setHidden:YES];
        } else {
            [self.documentProfileThumbView loadData];
            [self.documentProfileListView setHidden:YES];
            [self.documentProfileThumbView setHidden:NO];
        }
        
        [self.documentCabListView setHidden:YES];
        [self.documentCabThumbView setHidden:YES];
    }
}

#pragma mark - EventProtocol
- (void)didReceiveEvent:(Event *)event {
    EVENTTYPE eventType = [event getEventType];
    if (eventType == EVENT_TYPE_LOAD_COMMON_DATA) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopLoading];
            self.btnSearch.userInteractionEnabled = self.btnSetting.userInteractionEnabled = self.bottomBarView.userInteractionEnabled = YES;
            
            NSString *dataType = [event getContent];
            if ([dataType isEqualToString:DATA_COMMON_KEY]) {
                if ([CommonVar getDocumentOptionView] == SHOWTYPE_SNIPPET) {
                    if (self.type == TYPE_CABINET) {
                        [self.documentCabListView loadDocumentsInCab];
                    } else {
                        [self.documentProfileListView loadDocumentsInProfile];
                    }
                } else {
                    if (self.type == TYPE_CABINET) {
                        [self.documentCabThumbView loadDocumentsInCab];
                    } else {
                        [self.documentProfileThumbView loadDocumentsInProfile];
                    }
                }
            }
        });
    }  else if (eventType == EVENT_TYPE_FINISHED_DISPLAYING_DOCUMENT_LIST) {
        dispatch_async(dispatch_get_main_queue(), ^{
            self.btnSearch.userInteractionEnabled = self.btnSetting.userInteractionEnabled = self.bottomBarView.userInteractionEnabled = YES;
        });
    }  else if (eventType == EVENT_TYPE_ADD_TAGS_TO_DOCUMENTS) {
        NSMutableArray *documents = [event getContent];
        DocumentCabinetObject *untaggedCabinetCab = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetUntaggedType];
        [untaggedCabinetCab.arrDocuments removeObjectsInArray:documents];
        untaggedCabinetCab.cabinetObj.docCount = [NSNumber numberWithInt:[untaggedCabinetCab.arrDocuments count]];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadUI];
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
            [self reloadUI];
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
                
                if (![self.documentCabListView.arrDocumentCabinets containsObject:documentCab]) {
                    [self.documentCabListView addDocumentCabinetAndSort:documentCab];
                }
                
                if (![self.documentCabThumbView.arrDocumentCabinets containsObject:documentCab]) {
                    [self.documentCabThumbView.arrDocumentCabinets addObject:documentCab];
                }
            }
        }
        
        DocumentCabinetObject *uncategorizedCabinet = [[CommonDataManager getInstance] getDocumentCabinetObjectByCabType:kCabinetUncategorizedType];
        [uncategorizedCabinet.arrDocuments removeObjectsInArray:documents];
        uncategorizedCabinet.cabinetObj.docCount = [NSNumber numberWithInt:[uncategorizedCabinet.arrDocuments count]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.documentCabListView.tbDocumentCabinet reloadData];
            [self.documentCabThumbView.collectDocumentCabinet reloadData];
        });
    } else if (eventType == EVENT_TYPE_REMOVE_CABS_FROM_DOCUMENTS) {
        NSArray *documents = [[NSArray alloc] initWithArray:[event getContent]];
        NSArray *allDocumentCabinets = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentCabinets]];
        
        for (DocumentCabinetObject *documentCabObj in allDocumentCabinets) {
            if (!documentCabObj.cabinetObj.isAutoCalculateItemsInside) {
                for (DocumentObject *docObj in documents) {
                    if ([documentCabObj.arrDocuments containsObject:docObj] && ![docObj.cabs containsObject:documentCabObj.cabinetObj.id]) {
                        if ([documentCabObj.arrDocuments containsObject:docObj]) {
                            [documentCabObj.arrDocuments removeObject:docObj];
                            
                            documentCabObj.cabinetObj.docCount = [NSNumber numberWithInt:[documentCabObj.arrDocuments count]];
                        }
                    }
                }
                
                if ([documentCabObj.arrDocuments count] == 0 && [documentCabObj.cabinetObj.id intValue] > 0) {
                    if ([self.documentCabListView.arrDocumentCabinets containsObject:documentCabObj]) {
                        [self.documentCabListView.arrDocumentCabinets removeObject:documentCabObj];
                    }
                    
                    if ([self.documentCabThumbView.arrDocumentCabinets containsObject:documentCabObj]) {
                        [self.documentCabThumbView.arrDocumentCabinets removeObject:documentCabObj];
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
            [self.documentCabListView.tbDocumentCabinet reloadData];
            [self.documentCabThumbView.collectDocumentCabinet reloadData];
        });
    } else if (eventType == EVENT_TYPE_ADD_CABINET) {
        DocumentCabinetObject *documentCabObj = [event getContent];
        if (documentCabObj != nil && ![self.documentCabListView.arrDocumentCabinets containsObject:documentCabObj] && [documentCabObj.arrDocuments count] > 0) {
            [self.documentCabListView addDocumentCabinetAndSort:documentCabObj];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.documentCabListView.tbDocumentCabinet reloadData];
            [self.documentCabThumbView.collectDocumentCabinet reloadData];
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
            [self reloadUI];
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
            [self reloadUI];
        });
    } else if (eventType == EVENT_TYPE_EDIT_DOC) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadUI];
        });
    } else if (eventType == EVENT_TYPE_LOAD_ALL_DATA) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadAllData];
        });
    } else if (eventType == EVENT_TYPE_REMOVE_CABINET) {
        CabinetObject *cabObj = [event getContent];
        DocumentCabinetObject *docCabObj = nil;
        for (DocumentCabinetObject *documentGroup in self.documentCabListView.arrDocumentCabinets) {
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
            [self.documentCabListView.arrDocumentCabinets removeObject:docCabObj];
            [self.documentCabThumbView.arrDocumentCabinets removeObject:docCabObj];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.documentCabListView.tbDocumentCabinet reloadData];
                [self.documentCabThumbView.collectDocumentCabinet reloadData];
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
                    if (![untaggedCabinetCab.arrDocuments containsObject:documentObj]) {
                        [untaggedCabinetCab.arrDocuments addObject:documentObj];
                    }
                }
            }
        }
        untaggedCabinetCab.cabinetObj.docCount = [NSNumber numberWithInt:[untaggedCabinetCab.arrDocuments count]];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadUI];
        });
    } else if (eventType == EVENT_TYPE_CANCEL_LOADING_DATA) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self reloadUI];
            self.btnSearch.userInteractionEnabled = self.btnSetting.userInteractionEnabled = self.bottomBarView.userInteractionEnabled = YES;
        });
    }
}// 

#pragma mark - DocumentOptionsViewDelegate
- (void)didSelectSnippetsLayout:(id)sender {
    if (self.type == TYPE_CABINET) {
        if (self.showType == SHOWTYPE_THUMB) {
            self.showType = SHOWTYPE_SNIPPET;
            
            [self.documentCabListView.selectedSections removeAllObjects];
            for (NSString *section in self.documentCabThumbView.selectedSections) {
                [self.documentCabListView.selectedSections addObject:section];
            }
        }
    } else {
        if (self.showType == SHOWTYPE_THUMB) {
            self.showType = SHOWTYPE_SNIPPET;
            
            [self.documentProfileListView.selectedSections removeAllObjects];
            for (NSString *section in self.documentProfileThumbView.selectedSections) {
                [self.documentProfileListView.selectedSections addObject:section];
            }
        }
    }
    
    [CommonVar setDocumentOptionView:self.showType];
    [self updateUIBaseOnTypes];
}

- (void)didSelectThumbsLayout:(id)sender {
    if (self.type == TYPE_CABINET) {
        if (self.showType == SHOWTYPE_SNIPPET) {
            self.showType = SHOWTYPE_THUMB;
            
            [self.documentCabThumbView.selectedSections removeAllObjects];
            for (NSString *section in self.documentCabListView.selectedSections) {
                [self.documentCabThumbView.selectedSections addObject:section];
            }
        }
    } else {
        if (self.showType == SHOWTYPE_SNIPPET) {
            self.showType = SHOWTYPE_THUMB;
            
            [self.documentProfileThumbView.selectedSections removeAllObjects];
            for (NSString *section in self.documentProfileListView.selectedSections) {
                [self.documentProfileThumbView.selectedSections addObject:section];
            }
        }
    }
    
    [CommonVar setDocumentOptionView:self.showType];
    [self updateUIBaseOnTypes];
}

- (void)didSelectSortBy:(SORTBY)sortBy {
    if (self.sortBy == sortBy) return;
    [self sort:sortBy];
}

- (void)sort:(SORTBY)sortBy {
    self.sortBy = sortBy;
    [CommonVar setSortDocumentBy:sortBy];
    [self.documentOptionsView setSelectedSortBy:sortBy];
    
    for (DocumentCabinetObject *docCabObj in self.documentCabListView.arrDocumentCabinets) {
        [CommonFunc sortDocuments:docCabObj.arrDocuments sortBy:[CommonVar getSortDocumentBy]];
    }
    for (DocumentCabinetObject *docCabObj in self.documentCabThumbView.arrDocumentCabinets) {
        [CommonFunc sortDocuments:docCabObj.arrDocuments sortBy:[CommonVar getSortDocumentBy]];
    }
    
    for (DocumentProfileObject *docProfileObj in self.documentProfileListView.arrDocumentProfiles) {
        [CommonFunc sortDocuments:docProfileObj.arrDocuments sortBy:[CommonVar getSortDocumentBy]];
    }
    for (DocumentProfileObject *docProfileObj in self.documentProfileThumbView.arrDocumentProfiles) {
        [CommonFunc sortDocuments:docProfileObj.arrDocuments sortBy:[CommonVar getSortDocumentBy]];
    }
    
    if (self.type == TYPE_CABINET) {
        if (self.showType == SHOWTYPE_SNIPPET) {
            [self.documentCabListView.tbDocumentCabinet reloadData];
        } else {
            [self.documentCabThumbView.collectDocumentCabinet reloadData];
        }
    } else {
        if (self.showType == SHOWTYPE_SNIPPET) {
            [self.documentProfileListView.tbDocumentProfile reloadData];
        } else {
            [self.documentProfileThumbView.collectDocumentProfile reloadData];
        }
    }
}

#pragma mark - EGORefreshTableHeaderDelegate
- (void)egoRefreshTableHeaderDidTriggerRefresh:(id)view {
    //Do a refresh
    [self handleReloadButton:nil];
    
    //Reset pull-to-refresh state (hide loading header)
    dispatch_async(dispatch_get_main_queue(), ^{
        self.documentCabListView.loadingData = NO;
        self.documentCabThumbView.loadingData = NO;
        self.documentProfileListView.loadingData = NO;
        self.documentProfileThumbView.loadingData = NO;
    });
}

- (BOOL)egoRefreshTableHeaderDataSourceIsLoading:(id)view {
    return NO;
}

- (NSDate*)egoRefreshTableHeaderDataSourceLastUpdated:(EGORefreshTableHeaderView*)view{
	
	return [NSDate date]; // should return date data source was last changed
}

@end
