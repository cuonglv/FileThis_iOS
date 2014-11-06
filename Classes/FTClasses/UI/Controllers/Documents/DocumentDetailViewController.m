//
//  DocumentDetailViewController.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "DocumentDetailViewController.h"
#import "DocumentDataManager.h"
#import "CacheManager.h"
#import "NSString+Custom.h"
#import "FontCollection.h"
#import "PDFPage.h"
#import "EventManager.h"
#import "Utils.h"
#import "DocumentShareProvider.h"
#import "CommonDataManager.h"
#import "DocumentListViewController.h"
#import "DocumentCabinetObject.h"
#import "FTMobileAppDelegate.h"
#import "DocumentInfoView.h"
#import "CommonFunc.h"
#import "CommonVar.h"
#import "MF_Base64Additions.h"
#import "TagDataManager.h"

#define PADDING 20
#define DEFAULT_KEYWORD @"DJFHDFJGHDFJHSDFKJHSDFHDSFJGDFGDJFHGJDFHDJFHSDJFKHSDKFJHSD"

#define kAlertTag_ConfirmToDeleteDocs           1
#define kAlertTag_UnableToLoadDocumentContent   2

@interface DocumentDetailViewController ()
@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, strong) UIDocumentInteractionController *docInteractionController;
@end

@implementation DocumentDetailViewController

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.actionType == ACTIONTYPE_EDIT_TAGS)
    {
        [self handleTagsButton:nil];
    }
    self.actionType = ACTIONTYPE_UNKNOWN;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if (self.selectedBottomCenterBarButton == self.btnView)
        self.selectedBottomCenterBarButton = nil;
    
    [self.viewOptionPopover dismissPopoverAnimated:YES];
    [self.pageScrollView reloadData];
}

#pragma mark -
- (void)initializeVariables {
    [super initializeVariables];
    
    self.selectedPageNumber = 1;
    self.pageViewLayout = PageViewLayoutSinglePage;
    self.pageScrollView.pageViewLayout = self.pageViewLayout;
    [self.pageScrollView reloadData];
    self.isShowingInfoView = self.isShowingTagsView = self.isShowingSearchView = self.isShowingCabinetView = self.isShowingKeyboard = NO;
}

- (void)initializeScreen {
    [super initializeScreen];

    self.btnNextDoc = [self addTopRightImageBarButton:[UIImage imageNamed:@"next_icon.png"] width:30 target:self selector:@selector(handleNextDoc:)];
    [self.btnNextDoc setContentEdgeInsets:UIEdgeInsetsMake(5, 8, 5, 10)];
    
    self.btnPrevDoc = [self addTopRightImageBarButton:[UIImage imageNamed:@"prev_icon.png"] width:30 target:self selector:@selector(handlePrevDoc:)];
    [self.btnPrevDoc setContentEdgeInsets:UIEdgeInsetsMake(5, 9, 5, 9)];

    [self updateDocumentTitle];
    
    self.documentInfoView = [[[CommonFunc idiomClassWithName:@"DocumentInfoView"] alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height + 20 - [self heightForBottomBar], self.view.bounds.size.width, kDocumentInfoView_Height)];
    [self.documentInfoView setBackgroundColor:kBackgroundLightGrayColor];
    [self.documentInfoView.lblTitle setTextColor:kWhiteColor];
    [self.documentInfoView.lblTitle setBackgroundColor:kCabColorAll];
    [self.documentInfoView.btnClose setTitleColor:kWhiteColor forState:UIControlStateNormal];
    [self.documentInfoView.btnSave setTitleColor:kWhiteColor forState:UIControlStateNormal];
    self.documentInfoView.delegate = self;
    self.documentInfoView.tagListView.delegate = self;
    [self.view addSubview:self.documentInfoView];
    
    CGRect rect = CGRectMake(0, self.view.bounds.size.height+20, self.view.bounds.size.width, kDocumentTagsView_Height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        rect = CGRectMake(0, self.view.bounds.size.height+20, self.view.bounds.size.width, self.view.bounds.size.height - [self heightForTopBar] - [self heightForBottomBar]);
    }
    self.documentTagsView = [[[CommonFunc idiomClassWithName:@"DocumentTagsView"] alloc] initWithFrame:rect];
    [self.view addSubview:self.documentTagsView];
    [self.documentTagsView setBackgroundColor:kBackgroundLightGrayColor];
    self.documentTagsView.delegate = self;
    
    self.documentCabinetsView = [[[CommonFunc idiomClassWithName:@"DocumentCabinetsView"] alloc] initWithFrame:rect];
    [self.view addSubview:self.documentCabinetsView];
    [self.documentCabinetsView setBackgroundColor:kBackgroundLightGrayColor];
    self.documentCabinetsView.delegate = self;
    
    self.searchTextView = [[[CommonFunc idiomClassWithName:@"SearchPdfTextView"] alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height, self.view.bounds.size.width, 50)];
    [self.view addSubview:self.searchTextView];
    self.searchTextView.delegate = self;
    
    [self.lblDocumentInfo setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal]];
    [self.lblDocumentInfo setHidden:NO];
    
    [self.lblSearchResult setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal]];
    [self.lblSearchResult setHidden:YES];
    
    self.btnClearSearch = [CommonLayout createTextButton:CGRectMake(0, 0, 120, 30) fontSize:kFontSizeNormal isBold:NO text:@"Clear Search" textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleClearSearch:) superView:self.view];
    [self.view bringSubviewToFront:self.btnClearSearch];
    [self.btnClearSearch setHidden:YES];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardWillShowNotification object:nil];
    
    [self initializeToolbarButtons];
    
    [self.view bringSubviewToFront:self.overlayView];
    [self.view bringSubviewToFront:self.documentTagsView];
    [self.view bringSubviewToFront:self.documentInfoView];
    [self.view bringSubviewToFront:self.documentCabinetsView];
    [self.view bringSubviewToFront:self.searchTextView];
    self.loadingView = [[LoadingView alloc] init];
    self.currentDocumentIndex = [self.arrDocumentsInGroup indexOfObject:self.documentObj];
    
    if (self.currentDocumentIndex == 0) {
        [self.btnPrevDoc setImage:[UIImage imageNamed:@"prev_gray_icon.png"] forState:UIControlStateNormal];
    } else {
        [self.btnPrevDoc setImage:[UIImage imageNamed:@"prev_icon.png"] forState:UIControlStateNormal];
    }
    
    if (self.currentDocumentIndex == [self.arrDocumentsInGroup count] - 1) {
        [self.btnNextDoc setImage:[UIImage imageNamed:@"next_gray_icon.png"] forState:UIControlStateNormal];
    } else {
        [self.btnNextDoc setImage:[UIImage imageNamed:@"next_icon.png"] forState:UIControlStateNormal];
    }
    
    [[EventManager getInstance] addListener:self channel:CHANNEL_DATA];
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(loadDocument:threadObj:) argument:@"NO"];
}

- (void)initializeToolbarButtons {
    self.btnShare = [self addBottomCenterBarButton:NSLocalizedString(@"ID_SEND", @"") image:[UIImage imageNamed:@"send_white_icon.png"] target:self selector:@selector(handleShareButton:) width:70];
    self.btnExport = [self addBottomCenterBarButton:NSLocalizedString(@"ID_SHARE", @"") image:[UIImage imageNamed:@"share_white_icon.png"] target:self selector:@selector(handleExportButton:)];
    
    self.btnCabinet = [self addBottomCenterBarButton:NSLocalizedString(@"ID_CABINET", @"") image:[UIImage imageNamed:@"cab_white_icon.png"] target:self selector:@selector(handleCabinetButton:)];
    self.btnTags = [self addBottomCenterBarButton:NSLocalizedString(@"ID_TAGS_NO_DOT", @"") image:[UIImage imageNamed:@"tags_white_icon.png"] target:self selector:@selector(handleTagsButton:)];
    self.btnInfo = [self addBottomCenterBarButton:NSLocalizedString(@"ID_INFO", @"") image:[UIImage imageNamed:@"info_white_icon.png"] target:self selector:@selector(handleInfoButton:)];
    self.btnSearch = [self addBottomCenterBarButton:NSLocalizedString(@"ID_SEARCH", @"") image:[UIImage imageNamed:@"search_white_icon.png"] target:self selector:@selector(handleSearchButton:)];
    self.btnView = [self addBottomCenterBarButton:NSLocalizedString(@"ID_VIEW_OPTIONS", @"") image:[UIImage imageNamed:@"view_white_icon.png"] target:self selector:@selector(handleViewButton:)];
    self.btnDelete = [self addBottomCenterBarButton:NSLocalizedString(@"ID_DELETE", @"") image:[UIImage imageNamed:@"delete_white_icon.png"] target:self selector:@selector(handleDeleteButton:)];
}

- (void)updateDocumentTitle {
    NSString *docName = self.documentObj.docname?self.documentObj.docname:self.documentObj.filename;
    NSString *ext = [docName pathExtension];
    if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
        docName = [docName stringByDeletingPathExtension];
    }
    [self.titleLabel setText:docName];
}

- (void)loadDocument:(id)forceDownload threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    self.loadingView.threadObj = threadObj;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self enableToolbarButtons:NO];
        self.pageScrollView.hidden = self.lblDocumentInfo.hidden = YES;
        [self.loadingView startLoadingInView:self.view frame:self.contentView.frame];
        [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    });
    
    self.filePath = nil;
    if (![forceDownload boolValue]) {
        self.filePath = [[CacheManager getInstance] getDocumentDataCacheFor:self.documentObj];
        NSData *data = [NSData dataWithContentsOfFile:self.filePath];
        if ([data length] <= 1500)
            self.filePath = nil;
    }
    
    NSString *warningTitle = @"Error";
    NSString *warningMessage = @"Unknown Error";
    if (self.filePath == nil) {
        NSError *error;
        NSData *documentData = [[DocumentDataManager getInstance] downloadDocumentFile:self.documentObj error:&error];
        if (![threadObj isCancelled]) {
            warningTitle = NSLocalizedString(@"ID_WARNING",@"");
            if (documentData == nil) {
                warningTitle = NSLocalizedString(@"ID_WARNING_UNABLE_TO_DOWNLOAD_DOCUMENT_CONTENT", @"");
                if ([error localizedDescription].length > 0) {
                    warningMessage = [error localizedDescription];
                } else {
                    warningMessage = NSLocalizedString(@"ID_PLEASE_TRY_AGAIN_LATER",@"");
                }
            } else if ([documentData length] > 1500) {
                self.filePath = [[CacheManager getInstance] setDocumentDataCache:documentData forDoc:self.documentObj];
                if (self.filePath == nil) {
                    warningTitle = NSLocalizedString(@"ID_WARNING",@"");
                    if ([error localizedDescription].length > 0) {
                        warningMessage = [error localizedDescription];
                    } else {
                        warningMessage = NSLocalizedString(@"ID_WARNING_UNABLE_TO_LOAD_DOCUMENT_CONTENT",@"");
                    }
                }
            } else {
                if ([error localizedDescription].length > 0) {
                    warningMessage = [error localizedDescription];
                }
            }
        }
    }
    
    if (self.documentObj.shareContent == nil || [self.documentObj.shareContent length] == 0) {
        NSError *error;
        id response = [[DocumentDataManager getInstance] getDocMailLinks:self.documentObj error:&error];
        if (response != nil) {
            NSString *messageEncoded = [response objectForKey:@"message"];
            NSData *messageData = [NSData dataWithBase64String:messageEncoded];
            NSString *messageDecoded = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
            self.documentObj.shareContent = messageDecoded;
        }
    }
    
    if (![threadObj isCancelled]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.loadingView stopLoading];
            [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
            
            if (self.filePath) {
                self.pageScrollView.hidden = self.lblDocumentInfo.hidden = NO;
                self.documentObj.docURL = [NSURL fileURLWithPath:self.filePath];
                document = CGPDFDocumentCreateWithURL((CFURLRef)self.documentObj.docURL);
                [self.pageScrollView clearData];
                [self.pageScrollView reloadData];
                [self loadPageNumber:0 pageView:self.pageScrollView];
                [self enableToolbarButtons:YES];
                
                //Highlight text which is matched from global search
                if (self.documentSearchCriteria.texts.count > 0) {
                    if (!self.searchKeyword || ([self.searchKeyword isEqualToString:DEFAULT_KEYWORD])) {
                        self.searchKeyword = [self.documentSearchCriteria.texts firstObject];
                        [self.pageScrollView setKeyword:self.searchKeyword];
                    }
                }
                
            } else {
                [CommonLayout showAlertMessageWithTitle:warningTitle content:warningMessage tag:kAlertTag_UnableToLoadDocumentContent delegate:self cancelButtonTitle:NSLocalizedString(@"OK", @"") otherButtonTitle:nil];
            }
        });
    }
    [threadObj releaseOperation];
}

#pragma mark - Layout
- (float)keyboardHeight {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return kKeyboardIPhoneHeight;
    }
    return kKeyboardHeight;
}

- (float)topLabelHeight {
    return 30;
}

- (void)relayout {
    [super relayout];
    
    if (IS_IPHONE)
        [self.titleLabel setLeft:[self.backButton right] + 8 right:[self.btnPrevDoc left]-8];
    
    [self.lblDocumentInfo setFrame:CGRectMake(10, [self heightForTopBar], self.view.bounds.size.width - 20, [self topLabelHeight])];
    [self.lblSearchResult setFrame:self.lblDocumentInfo.frame];
    [self.btnClearSearch setFrame:CGRectMake(0, [self heightForTopBar], 120, [self topLabelHeight])];
    self.pageScrollView.frame = CGRectMake(0, [self.lblDocumentInfo bottom], self.view.bounds.size.width, self.view.bounds.size.height - [self heightForTopBar] - [self heightForBottomBar] - [self topLabelHeight]);
    
    self.overlayView.frame = CGRectMake(0, [self heightForTopBar], self.pageScrollView.frame.size.width, self.pageScrollView.frame.size.height);
    
    [self.documentCabinetsView setWidth:self.view.frame.size.width];
    [self.documentTagsView setWidth:self.view.frame.size.width];
    [self.documentInfoView setWidth:self.view.frame.size.width];
    [self.searchTextView setWidth:self.view.frame.size.width];
    
    float keyboardHeight = [self keyboardHeight];
    if ([self isLandscapeMode]) {
        keyboardHeight = [self keyboardHeight] + 88;
    }
    
    if (self.isShowingCabinetView) {
        [self.documentCabinetsView setBottom:[self.contentView bottom]];
        
        if (self.isShowingKeyboard) {
            [self.documentCabinetsView setTop:[self.documentCabinetsView top] - keyboardHeight];
        }
    } else {
        [self.documentCabinetsView setTop:self.view.bounds.size.height];
    }
    
    if (self.isShowingTagsView) {
        [self.documentTagsView setBottom:[self.contentView bottom]];
        
        if (self.isShowingKeyboard) {
            [self.documentTagsView setTop:[self.documentTagsView top] - keyboardHeight];
        }
    } else {
        [self.documentTagsView setTop:self.view.bounds.size.height];
    }
    
    if (self.isShowingInfoView) {
        [self.documentInfoView setBottom:[self.contentView bottom]];
        
        if (self.isShowingKeyboard) {
            [self.documentInfoView setTop:[self.documentInfoView top] - keyboardHeight];
        }
    } else {
        [self.documentInfoView setTop:self.view.bounds.size.height];
    }
    
    if (self.isShowingSearchView) {
        [self.searchTextView setBottom:[self.contentView bottom]];
        
        if (self.isShowingKeyboard) {
            [self.searchTextView setTop:[self.searchTextView top] - keyboardHeight];
        }
    } else {
        [self.searchTextView setTop:self.view.bounds.size.height];
    }
}

- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    return 40;
}

- (float)rightMarginTopBarButton {
    return 0;
}

#pragma mark - Button events
- (void)handleReloadButton:(id)sender {
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(loadDocument:threadObj:) argument:@"YES"];
}

- (void)handleClearSearch:(id)sender {
    self.searchKeyword = DEFAULT_KEYWORD;
    [self.pageScrollView setKeyword:self.searchKeyword];
    [self.btnClearSearch setHidden:YES];
    [self.lblDocumentInfo setHidden:NO];
    [self.lblSearchResult setHidden:YES];
}

- (void)handleNextDoc:(id)sender {
    if (self.currentDocumentIndex < [self.arrDocumentsInGroup count] - 1) {
        [self handleClearSearch:nil];
        
        [self.btnClearSearch setHidden:YES];
        [self.lblDocumentInfo setHidden:NO];
        [self.lblSearchResult setHidden:YES];
        
        self.currentDocumentIndex++;
        
        [self.btnNextDoc setImage:[UIImage imageNamed:@"next_icon.png"] forState:UIControlStateNormal];
        self.documentObj = [self.arrDocumentsInGroup objectAtIndex:self.currentDocumentIndex];
        
        if (![[self.documentObj.kind lowercaseString] isEqualToString:[kPDF lowercaseString]]) {
            [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_PDF_TYPE_WARNING", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        }
        
        NSString *docName = self.documentObj.docname?self.documentObj.docname:self.documentObj.filename;
        NSString *ext = [docName pathExtension];
        if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
            docName = [docName stringByDeletingPathExtension];
        }
        [self.titleLabel setText:docName];
        
        [self.documentTagsView loadViewWithDocumentList:[NSMutableArray arrayWithObject:self.documentObj]];
        [self.documentCabinetsView loadViewWithDocumentList:[NSMutableArray arrayWithObject:self.documentObj]];
        
        [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(loadDocument:threadObj:) argument:@"NO"];
    }
    
    if (self.currentDocumentIndex == [self.arrDocumentsInGroup count] - 1) {
        [self.btnNextDoc setImage:[UIImage imageNamed:@"next_gray_icon.png"] forState:UIControlStateNormal];
    } else {
        [self.btnNextDoc setImage:[UIImage imageNamed:@"next_icon.png"] forState:UIControlStateNormal];
    }
    
    if (self.currentDocumentIndex == 0) {
        [self.btnPrevDoc setImage:[UIImage imageNamed:@"prev_gray_icon.png"] forState:UIControlStateNormal];
    } else {
        [self.btnPrevDoc setImage:[UIImage imageNamed:@"prev_icon.png"] forState:UIControlStateNormal];
    }
}

- (void)handlePrevDoc:(id)sender {
    if (self.currentDocumentIndex > 0) {
        [self handleClearSearch:nil];
        
        [self.btnClearSearch setHidden:YES];
        [self.lblDocumentInfo setHidden:NO];
        [self.lblSearchResult setHidden:YES];
        
        self.currentDocumentIndex--;
        
        self.documentObj = [self.arrDocumentsInGroup objectAtIndex:self.currentDocumentIndex];
        
        if (![[self.documentObj.kind lowercaseString] isEqualToString:[kPDF lowercaseString]]) {
            [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_PDF_TYPE_WARNING", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        }
        
        NSString *docName = self.documentObj.docname?self.documentObj.docname:self.documentObj.filename;
        NSString *ext = [docName pathExtension];
        if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
            docName = [docName stringByDeletingPathExtension];
        }
        [self.titleLabel setText:docName];
        
        [self.documentTagsView loadViewWithDocumentList:[NSMutableArray arrayWithObject:self.documentObj]];
        [self.documentCabinetsView loadViewWithDocumentList:[NSMutableArray arrayWithObject:self.documentObj]];
        
        [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(loadDocument:threadObj:) argument:@"NO"];
    }
    
    if (self.currentDocumentIndex == 0) {
        [self.btnPrevDoc setImage:[UIImage imageNamed:@"prev_gray_icon.png"] forState:UIControlStateNormal];
    } else {
        [self.btnPrevDoc setImage:[UIImage imageNamed:@"prev_icon.png"] forState:UIControlStateNormal];
    }
    
    if (self.currentDocumentIndex == [self.arrDocumentsInGroup count] - 1) {
        [self.btnNextDoc setImage:[UIImage imageNamed:@"next_gray_icon.png"] forState:UIControlStateNormal];
    } else {
        [self.btnNextDoc setImage:[UIImage imageNamed:@"next_icon.png"] forState:UIControlStateNormal];
    }
}

- (void)handleShareButton:(id)sender {
    [self showDocumentCabinetsView:NO];
    [self showDocumentInfoView:NO];
    [self showDocumentTagsView:NO];
    
    //Create new activity provider item to pass to the activity view controller
    DocumentShareProvider *documentShareProvider = [[DocumentShareProvider alloc] init];
    documentShareProvider.documentObj = self.documentObj;
    
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[documentShareProvider] applicationActivities:nil];
    
    NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypeMessage, UIActivityTypePostToWeibo,UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
    activityViewController.excludedActivityTypes = excludedActivities;
    
    [self presentViewController:activityViewController animated:YES completion:nil];
}

- (void)handleExportButton:(id)sender {
    [self showDocumentCabinetsView:NO];
    [self showDocumentInfoView:NO];
    [self showDocumentTagsView:NO];
    
    if (self.filePath.length == 0) {
        return;
    }
    UIButton *btn = sender;
    NSURL *URL = [NSURL fileURLWithPath:self.filePath];
    [self setupDocumentControllerWithURL:URL];
    
    CGRect rect = btn.frame;
    rect.origin.y -= 5;
    [self.docInteractionController presentOptionsMenuFromRect:rect inView:self.bottomBarView animated:YES];
}

- (void)handleCabinetButton:(id)sender {
    self.currentPopupView = self.documentCabinetsView;
    [self.documentCabinetsView loadViewWithDocumentList:[NSMutableArray arrayWithObject:self.documentObj]];
    
    [self showDocumentTagsView:NO];
    [self showDocumentInfoView:NO];
    [self showDocumentCabinetsView:YES];
    self.selectedBottomCenterBarButton = self.btnCabinet;
}

- (void)handleTagsButton:(id)sender {
    self.currentPopupView = self.documentTagsView;
    [self.documentTagsView loadViewWithDocumentList:[NSMutableArray arrayWithObject:self.documentObj]];
    
    [self showDocumentInfoView:NO];
    [self showDocumentCabinetsView:NO];
    [self showDocumentTagsView:YES];
    self.selectedBottomCenterBarButton = self.btnTags;
}

- (void)handleInfoButton:(id)sender {
    self.currentPopupView = self.documentInfoView;
    [self.documentInfoView loadViewWithDocument:self.documentObj];
    
    [self showDocumentTagsView:NO];
    [self showDocumentCabinetsView:NO];
    [self showDocumentInfoView:YES];
    self.selectedBottomCenterBarButton = self.btnInfo;
}

- (void)handleSearchButton:(id)sender {
    self.currentPopupView = self.searchTextView;
    
    if (self.searchKeyword && ![self.searchKeyword isEqualToString:DEFAULT_KEYWORD]) {
        self.searchTextView.txtKeyword.text = self.searchKeyword;
    }
    [self.searchTextView.txtKeyword becomeFirstResponder];
    
    [self.overlayView setHidden:NO];
//    [self.pageScrollView reloadDataWithLayout:1];
    
    [self showDocumentTagsView:NO];
    [self showDocumentInfoView:NO];
    [self showDocumentCabinetsView:NO];
    self.selectedBottomCenterBarButton = self.btnSearch;
}

- (void)handleViewButton:(id)sender {
    self.selectedBottomCenterBarButton = self.btnView;
    
    UIButton *optionButton = sender;
    CGRect selectedButtonFrame = [self.bottomBarView convertRect:optionButton.frame toView:self.view];
    
    if (self.viewOptionPopover == nil) {
        if (self.layoutOptionsView == nil) {
            float height = 150;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
                height = 120;
            self.layoutOptionsView = [[DocumentPreviewLayoutViewOption alloc] initWithFrame:CGRectMake(0, 0, 200, height)];
            self.layoutOptionsView.delegate = self;
        }
        
        UIViewController *optionViewController = [[UIViewController alloc] init];
        optionViewController.view = self.layoutOptionsView;
        
        self.viewOptionPopover = [[MyPopoverWrapper alloc] initWithContentViewController:optionViewController];
        [self.viewOptionPopover setPopoverContentSize:self.layoutOptionsView.frame.size animated:NO];
        self.viewOptionPopover.delegate = self;
    }
    
    NSLog(@"self.pageViewLayout = %d", self.pageViewLayout);
    self.layoutOptionsView.selectedLayout = self.pageViewLayout;
    [self.layoutOptionsView.tbView selectRowAtIndexPath:[NSIndexPath indexPathForRow:self.pageViewLayout inSection:0] animated:NO scrollPosition:UITableViewScrollPositionNone];
    [self.layoutOptionsView.tbView reloadData];
    
    self.viewOptionPopover.layoutTopMargin = 108; //Used for iPhone only
    self.viewOptionPopover.layoutMode = PopoverLayoutModeVerticalTop; //Used for iPhone only
    [self.viewOptionPopover presentPopoverFromRect:selectedButtonFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)handleDeleteButton:(id)sender {
    [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_CONFIRM", @"") tag:kAlertTag_ConfirmToDeleteDocs content:NSLocalizedString(@"ID_DELETE_DOC_CONFIRM", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitles:NSLocalizedString(@"ID_CANCEL", @"")];
}

- (void)handleBackButton {
    DocumentListViewController *documentListVC = nil;
    for (UIViewController *vc in [self.navigationController viewControllers]) {
        if ([vc isKindOfClass:[DocumentListViewController class]]) {
            documentListVC = (DocumentListViewController *)vc;
            break;
        }
    }
    
    NSArray *allDocumentsCabinet = [[NSArray alloc] initWithArray:[[CommonDataManager getInstance] getAllDocumentCabinets]];
    if (documentListVC != nil && [documentListVC.documentGroup isKindOfClass:[DocumentCabinetObject class]] && ![allDocumentsCabinet containsObject:documentListVC.documentGroup]) {
        DocumentCabinetObject *docCabObj = (DocumentCabinetObject *)documentListVC.documentGroup;
        if (docCabObj.cabinetObj != nil && docCabObj.cabinetObj.id != nil) {
            FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate jumpToDocumentGroupListViewController];
            return;
        }
    }
    
    // Delete temp file
    if (self.documentObj != nil) {
        [[CacheManager getInstance] deleteTempFiles];
    }
    
    [super handleBackButton];
}

#pragma mark - Keyboard events
- (void)keyboardDidHide {
    [self moveViewToAboveKeyboard:self.currentPopupView isAbove:NO];
}

- (void)keyboardDidShow {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) return;
    [self moveViewToAboveKeyboard:self.currentPopupView isAbove:YES];
}

- (void)moveViewToAboveKeyboard:(BaseView *)view isAbove:(BOOL)isAbove {
    //CGRect rect = view.frame;
    float keyboardHeight = [self keyboardHeight];

    if ([self isLandscapeMode]) {
        keyboardHeight = [self keyboardHeight] + 88;
    }
    
    [view setBottom:[self.contentView bottom]];
    if (isAbove && !self.isShowingKeyboard) {
        if ([view isKindOfClass:[SearchPdfTextView class]]) {
            self.isShowingSearchView = YES;
            
            [UIView animateWithDuration:0.3 animations:^{
                [view setTop:[view top] - keyboardHeight];
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [view setTop:[view top] - keyboardHeight];
            }];
        }
        
        [self.overlayView setHidden:NO];
    } else if (!isAbove && self.isShowingKeyboard) {
        if ([view isKindOfClass:[SearchPdfTextView class]]) {
            self.isShowingSearchView = NO;
            
            [UIView animateWithDuration:0.3 animations:^{
                [view setBottom:[self.contentView bottom]];
            }];
        } else {
            [UIView animateWithDuration:0.3 animations:^{
                [view setBottom:[self.contentView bottom]];
            }];
        }
        
        if ([view isKindOfClass:[SearchPdfTextView class]]) {
//            [self.pageScrollView reloadDataWithLayout:0];
            [self.overlayView setHidden:YES];
            self.selectedBottomCenterBarButton = nil;
            [view setTop:[self.view bottom]];
        } else {
            if (self.isShowingInfoView || self.isShowingTagsView || self.isShowingCabinetView) {
                [self.overlayView setHidden:NO];
//                [self.pageScrollView reloadDataWithLayout:1];
            } else {
                [self.overlayView setHidden:YES];
//                [self.pageScrollView reloadDataWithLayout:0];
            }
        }
    }
    
    self.isShowingKeyboard = isAbove;
}

#pragma mark - Overidden
- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (BOOL)shouldHideToolBar {
    return NO;
}

- (BOOL)shouldUseBackButton {
    return YES;
}

#pragma mark - Private methods
- (void)setupDocumentControllerWithURL:(NSURL *)url
{
    if (self.docInteractionController == nil)
    {
        self.docInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    }
    else
    {
        self.docInteractionController.URL = url;
    }
}

#pragma mark - DocumentInfoViewDelegate
- (void)didCloseButtonTouched:(id)sender {
    [self showDocumentInfoView:NO];
    [self showDocumentTagsView:NO];
    [self showDocumentCabinetsView:NO];
}

- (void)willUpdateDocumentValue:(DocumentObject *)newDoc withProperties:(NSArray *)properties {
    BOOL res = [[DocumentDataManager getInstance] updateDocumentInfo:newDoc];
    
    // Post event to UI
    if (res) {
        [self.documentObj updateProperties:properties fromObject:newDoc];
        
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_EDIT_DOC];
        [event setContent:self.documentObj];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
        
        [self updateDocumentTitle];
        [self showDocumentInfoView:NO];
        [self showDocumentTagsView:NO];
        [self showDocumentCabinetsView:NO];
    }
}

#pragma mark - TagListViewDelegate (inside DocumentInfoView)
- (void)tagViewDidEditTouched:(id)sender forDocument:(DocumentObject *)docObj {
    [self handleTagsButton:nil];
}

#pragma mark - DocumentTagsViewDelegate
- (void)didTagsViewDoneButtonTouched:(id)sender {
    [self showDocumentInfoView:NO];
    [self showDocumentTagsView:NO];
    [self showDocumentCabinetsView:NO];
}

- (void)didSelectTag:(TagObject *)tagObj {
    [[CommonDataManager getInstance] addTag:tagObj toDocuments:[NSMutableArray arrayWithObject:self.documentObj]];
}

- (void)didDeselectTag:(TagObject *)tagObj {
    [[CommonDataManager getInstance] removeTag:tagObj fromDocuments:[NSMutableArray arrayWithObject:self.documentObj]];
}

#pragma mark - DocumentCabinetsViewDelegate
- (void)didCabinetsViewDoneButtonTouched:(id)sender {
    [self showDocumentCabinetsView:NO];
}

- (void)didSelectCabinet:(CabinetObject *)cabObj {
    [[CommonDataManager getInstance] addCabinet:cabObj toDocuments:[NSMutableArray arrayWithObject:self.documentObj]];
}

- (void)didDeselectCabinet:(CabinetObject *)cabObj {
    [[CommonDataManager getInstance] removeCabinet:cabObj fromDocuments:[NSMutableArray arrayWithObject:self.documentObj]];
}

#pragma mark - public methods
- (void)enableToolbarButtons:(BOOL)enabled {
    self.bottomBarView.userInteractionEnabled = enabled;
}

- (void)showDocumentInfoView:(BOOL)show {
    [self.documentInfoView resetView];
    
    if (show && !self.isShowingInfoView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentInfoView setBottom:[self.contentView bottom]];
        }];
    } else if (!show && self.isShowingInfoView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentInfoView setTop:self.view.bounds.size.height];
        }];
    }
    
    self.isShowingInfoView = show;
    
    if (self.isShowingInfoView || self.isShowingTagsView || self.isShowingSearchView || self.isShowingSearchView) {
        [self.overlayView setHidden:NO];
//        [self.pageScrollView reloadDataWithLayout:PageViewlayoutDoublePage];
    } else {
        [self.overlayView setHidden:YES];
//        [self.pageScrollView reloadDataWithLayout:PageViewLayoutSinglePage];
    }
    
    self.pageViewLayout = self.pageScrollView.pageViewLayout;
    if (!show) {
        self.selectedBottomCenterBarButton = nil;
    }
}

- (void)showDocumentTagsView:(BOOL)show {
    [self.documentTagsView resetView];
    
    if (show && !self.isShowingTagsView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentTagsView setBottom:[self.contentView bottom]];
//            [self.pageScrollView reloadDataWithLayout:1];
        }];
    } else if(!show && self.isShowingTagsView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentTagsView setTop:self.view.bounds.size.height];
//            [self.pageScrollView reloadDataWithLayout:0];
        }];
    }
    
    self.isShowingTagsView = show;
    
    if (self.isShowingInfoView || self.isShowingTagsView || self.isShowingSearchView || self.isShowingSearchView) {
        [self.overlayView setHidden:NO];
//        [self.pageScrollView reloadDataWithLayout:PageViewlayoutDoublePage];
    } else {
        [self.overlayView setHidden:YES];
//        [self.pageScrollView reloadDataWithLayout:PageViewLayoutSinglePage];
    }
    
    self.pageViewLayout = self.pageScrollView.pageViewLayout;
    if (!show) {
        self.selectedBottomCenterBarButton = nil;
    }
}

- (void)showDocumentCabinetsView:(BOOL)show {
    [self.documentCabinetsView resetView];
    
    if (show && !self.isShowingCabinetView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentCabinetsView setBottom:[self.contentView bottom]];
//            [self.pageScrollView reloadDataWithLayout:PageViewlayoutDoublePage];
        }];
    } else if(!show && self.isShowingCabinetView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentCabinetsView setTop:self.view.bounds.size.height];
//            [self.pageScrollView reloadDataWithLayout:PageViewLayoutSinglePage];
        }];
    }
    
    self.isShowingCabinetView = show;
    
    if (self.isShowingInfoView || self.isShowingTagsView || self.isShowingSearchView || self.isShowingCabinetView) {
        [self.overlayView setHidden:NO];
//        [self.pageScrollView reloadDataWithLayout:PageViewlayoutDoublePage];
    } else {
        [self.overlayView setHidden:YES];
//        [self.pageScrollView reloadDataWithLayout:PageViewLayoutSinglePage];
    }
    
    self.pageViewLayout = self.pageScrollView.pageViewLayout;
    if (!show) {
        self.selectedBottomCenterBarButton = nil;
    }
}

#pragma mark - SearchPdfTextViewDelegate
- (void)didDoneButtonTouched:(id)sender {
    [self showDocumentInfoView:NO];
    [self showDocumentTagsView:NO];
    [self showDocumentCabinetsView:NO];
    
    NSString *keyword = [self.searchTextView.txtKeyword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([keyword length] > 0) {
        self.searchKeyword = keyword;
        [self.pageScrollView setKeyword:self.searchKeyword];
        
        [self.btnClearSearch setHidden:NO];
        [self.lblDocumentInfo setHidden:YES];
        [self.lblSearchResult setHidden:NO];
    }
}

#pragma mark - PageViewDelegate
- (NSInteger)numberOfPagesInPageView:(PageView *)pageView
{
	return CGPDFDocumentGetNumberOfPages(document);
}

- (FontCollection *)activeFontCollection
{
	Page *page = [self.pageScrollView pageAtIndex:self.pageScrollView.page];
	PDFContentView *pdfPage = (PDFContentView *) [(PDFPage *) page contentView];
	return [[pdfPage scanner] fontCollection];
}

/* Page view object for the requested page */
- (Page *)pageView:(PageView *)aPageView viewForPage:(NSInteger)pageNumber
{
	PDFPage *page = (PDFPage *) [aPageView pageAtIndex:pageNumber];
    CGRect rect;
	if (!page)
	{
        if (aPageView.pageViewLayout == PageViewLayoutSinglePage) {
            rect = CGRectMake(aPageView.bounds.origin.x, aPageView.bounds.origin.y, aPageView.bounds.size.width, aPageView.bounds.size.height);
        } else if (aPageView.pageViewLayout == PageViewlayoutDoublePage) {
            rect = CGRectMake(aPageView.bounds.origin.x, aPageView.bounds.origin.y, aPageView.bounds.size.width/2, aPageView.bounds.size.height/2);
        } else {
            rect = CGRectMake(aPageView.bounds.origin.x, aPageView.bounds.origin.y, aPageView.bounds.size.width/2, aPageView.bounds.size.height/2);
        }
        
        page = [[PDFPage alloc] initWithFrame:rect];
	} else {
        if (aPageView.pageViewLayout == PageViewLayoutSinglePage) {
            rect = CGRectMake(0, 0, aPageView.bounds.size.width, aPageView.bounds.size.height);
        } else if (aPageView.pageViewLayout == PageViewlayoutDoublePage) {
            rect = CGRectMake(0, 0, aPageView.bounds.size.width/2, aPageView.bounds.size.height/2);
        } else {
            rect = CGRectMake(0, 0, aPageView.bounds.size.width/2, aPageView.bounds.size.height/2);
        }
        [page setFrame:rect];
    }
    
    page.contentSize = CGSizeMake(rect.size.width, rect.size.height);
    page.pageDelegate = self;
	page.pageNumber = pageNumber;
    CGPDFPageRef pdfPage = CGPDFDocumentGetPage(document, pageNumber + 1);
    [page setPage:pdfPage layout:self.pageViewLayout];
	page.keyword = self.searchKeyword;
    
	return page;
}

- (NSString *)keywordForPageView:(PageView *)pageView {
	return self.searchKeyword;
}

- (void)pageView:(PageView *)pageView didScrollToPage:(NSInteger)pageNumber {
    self.selectedPageNumber = pageNumber;
    Page *page = [pageView pageAtIndex:pageNumber];
    [page refactorZoomScale];
    [self loadPageNumber:pageNumber pageView:pageView];
}

- (void)loadPageNumber:(int)pageNumber pageView:(PageView *)pageView {
    NSString *pageLabel = @"";
    int numPages = CGPDFDocumentGetNumberOfPages(document);
    int displayNumPages = 1;
    if (pageView.pageViewLayout == PageViewLayoutSinglePage) {
        displayNumPages = numPages;
        pageLabel = [NSString stringWithFormat:@"Page %d of %d", pageNumber+1, displayNumPages];
    } else if (pageView.pageViewLayout == PageViewlayoutDoublePage) {
        if (numPages > 2) {
            displayNumPages = numPages/2;
            if (numPages % 2 > 0) displayNumPages++;
        }
        pageLabel = [NSString stringWithFormat:@"Page %d of %d", pageNumber+1, displayNumPages];
    } else {
        if (numPages > 4) {
            displayNumPages = numPages/4;
            if (numPages % 4 > 0) displayNumPages++;
        }
        pageLabel = [NSString stringWithFormat:@"Page %d of %d", pageNumber+1, displayNumPages];
    }
    [self.lblDocumentInfo setText:pageLabel];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertTag_ConfirmToDeleteDocs) {
        if (buttonIndex == 0)
            [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(deleteDocumentsThread:threadObj:) argument:@""];
    } else if (alertView.tag == kAlertTag_UnableToLoadDocumentContent) {
        [self enableToolbarButtons:NO];
//        if ([alertView.delegate isKindOfClass:[DocumentDetailViewController class]])
//            [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)deleteDocumentsThread:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self.view message:NSLocalizedString(@"ID_DELETING_DOCUMENTS", @"")];
    });
    
    BOOL res = [[DocumentDataManager getInstance] deleteDocuments:[NSMutableArray arrayWithObject:self.documentObj]];
    if (res) {
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_DELETE_DOC];
        [event setContent:self.documentObj];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
        
        //Update documents count for each tag relating to this document
        NSArray *arrTags = [NSArray arrayWithArray:self.documentObj.tags];
        for (NSNumber *num in arrTags) {
            TagObject *tagObj = [[TagDataManager getInstance] getObjectByKey:num];
            if ([self.documentObj.tags containsObject:num]) {
                [self.documentObj.tags removeObject:num];
            }
            [tagObj updateDocCount];
        }
        
        [self stopAllTaskBeforeQuit];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.navigationController popViewControllerAnimated:YES];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
    });
    [threadObj releaseOperation];
}

#pragma mark - DocumentPreviewLayoutViewOption
- (void)didSelectPageLayout:(id)sender pageViewLayout:(PageViewLayout)pageViewLayout {
    if (self.pageViewLayout == pageViewLayout) return;
    
    [self showDocumentTagsView:NO];
    [self showDocumentInfoView:NO];
    [self showDocumentCabinetsView:NO];
    self.pageViewLayout = pageViewLayout;
    
    self.pageScrollView.contentOffset = CGPointMake(0, 0);
    [self.pageScrollView reloadDataWithLayout:pageViewLayout];
    [self loadPageNumber:0 pageView:self.pageScrollView];
    
    [self.viewOptionPopover dismissPopoverAnimated:YES];
    self.selectedBottomCenterBarButton = nil;
}

#pragma mark - PageDelegate
- (void)didPageDoubleTap:(id)sender {
    if (self.pageViewLayout == PageViewLayoutSinglePage) return;
    Page *page = sender;
    
    [self.pageScrollView setContentOffset:CGPointMake(page.pageNumber * self.pageScrollView.bounds.size.width, 0)];
    self.pageViewLayout = PageViewLayoutSinglePage;
    [self.pageScrollView reloadDataWithLayout:self.pageViewLayout];
    [self loadPageNumber:page.pageNumber pageView:self.pageScrollView];
    
    self.layoutOptionsView.selectedLayout = self.pageViewLayout;
    [self.layoutOptionsView.tbView reloadData];
}

#pragma mark - PopoverDelegate
- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.selectedBottomCenterBarButton = nil;
}

#pragma mark - EventProtocol
- (void)didReceiveEvent:(Event *)event {
    EVENTTYPE eventType = [event getEventType];
    if (eventType == EVENT_TYPE_ADD_TAGS_TO_DOCUMENTS || eventType == EVENT_TYPE_REMOVE_TAGS_FROM_DOCUMENTS || eventType == EVENT_TYPE_ADD_TAG || eventType == EVENT_TYPE_REMOVE_TAG) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.documentTagsView.selectTagsView filterItems];
        });
    } else if (eventType == EVENT_TYPE_ADD_CABS_TO_DOCUMENTS || eventType == EVENT_TYPE_REMOVE_CABS_FROM_DOCUMENTS || eventType == EVENT_TYPE_ADD_CABINET || eventType == EVENT_TYPE_REMOVE_CABINET) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.documentCabinetsView.selectCabinetsView filterItems];
        });
    } else if (eventType == EVENT_TYPE_CANCEL_LOADING_DATA) {
    }
}
@end
