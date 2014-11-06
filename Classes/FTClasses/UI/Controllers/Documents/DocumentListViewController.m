//
//  DocumentListViewController.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "DocumentListViewController.h"
#import "DocumentObject.h"
#import "DocumentCell.h"
#import "DocumentDetailViewController.h"
#import "CommonLayout.h"
#import "CacheManager.h"
#import "DocumentDataManager.h"
#import "DocumentService.h"
#import "EventManager.h"
#import "Utils.h"
#import "FTMobileAppDelegate.h"
#import "DocumentProfileObject.h"
#import "CommonDataManager.h"
#import "CommonFunc.h"
#import "TagDataManager.h"
#import "DocumentInfoViewController.h"
#import "MF_Base64Additions.h"
#import "MultiDocsShareProvider.h"
#import "UIImage+Resize.h"

#define HEIGHT_FOR_ROW  80
#define HEIGHT_FOR_HEADER  40
#define NUM_TAGS_IN_ROW 8

#define kConfirmToDeleteDocs    1

@interface DocumentListViewController ()

@end

@implementation DocumentListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    //Observe for thumb download event
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDownloadThumb:) name:NotificationDownloadThumb object:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.optionPopover dismissPopoverAnimated:YES];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [[DocumentDataManager getInstance] cancelDownloadingThumbnail];
}

- (void)initializeVariables {
    [super initializeVariables];
    
    self.cellEditingModeIndex = -1;// No cell
    
    self.selectedIndexes = [[NSMutableDictionary alloc] init];
    self.selectedCells = [[NSMutableDictionary alloc] init];
    
    self.currentPopupView = nil;
    self.isShowingKeyboard = NO;
}

- (void)initializeScreen {
    [super initializeScreen];
    
    self.btnOption = [self addTopRightImageBarButton:[UIImage imageNamed:@"gear_icon.png"] width:40 target:self selector:@selector(handleOptionsButton:)];
    
    CGRect rect = CGRectMake(0, self.view.bounds.size.height+20, self.view.bounds.size.width, kDocumentTagsView_Height);
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        rect = CGRectMake(0, self.view.bounds.size.height+20, self.view.bounds.size.width, self.view.bounds.size.height - [self heightForTopBar] - [self heightForBottomBar]);
    }
    self.documentTagsView = [[[CommonFunc idiomClassWithName:@"DocumentTagsView"] alloc] initWithFrame:rect];
    
    [self.view addSubview:self.documentTagsView];
    [self.view bringSubviewToFront:self.documentTagsView];
    self.documentTagsView.delegate = self;
    [self.documentTagsView setBackgroundColor:kBackgroundLightGrayColor];
    
    self.documentCabinetView = [[[CommonFunc idiomClassWithName:@"DocumentCabinetsView"] alloc] initWithFrame:rect];
    self.tbDocumentList.frame = self.contentView.frame;
    self.tbDocumentList.allowsSelection = NO;
    
    self.documentCabinetView.delegate = self;
    [self.view addSubview:self.documentCabinetView];
    [self.view bringSubviewToFront:self.documentCabinetView];
    [self.documentCabinetView setBackgroundColor:kBackgroundLightGrayColor];
    
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(keyboardDidHide) name:UIKeyboardWillHideNotification object:nil];
    [center addObserver:self selector:@selector(keyboardDidShow) name:UIKeyboardWillShowNotification object:nil];
    
    self.btnBottomCabinets = [self addBottomCenterBarButton:NSLocalizedString(@"ID_CABINET", @"") image:[UIImage imageNamed:@"cab_white_icon.png"] target:self selector:@selector(handleCabinetButton:)];
    self.btnBottomTags = [self addBottomCenterBarButton:NSLocalizedString(@"ID_TAGS_NO_DOT", @"") image:[UIImage imageNamed:@"tags_white_icon.png"] target:self selector:@selector(handleAddTagsToDocuments:)];
    [self.btnBottomTags setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    self.btnBottomShare = [self addBottomCenterBarButton:NSLocalizedString(@"ID_SEND", @"") image:[UIImage imageNamed:@"send_white_icon.png"] target:self selector:@selector(handleShareButton:) width:70];
    self.btnBottomDelete = [self addBottomCenterBarButton:NSLocalizedString(@"ID_DELETE", @"") image:[UIImage imageNamed:@"delete_white_icon.png"] target:self selector:@selector(handleDeleteDocuments:)];
    
    self.selectedDocuments = [[NSMutableArray alloc] init];
    
    self.documentsCabThumbView = [[DocumentCabinetThumbView alloc] initWithFrame:self.contentView.frame showSectionHeaders:NO showAllDocs:YES canReload:NO];
    [self.view addSubview:self.documentsCabThumbView];
    [self.documentsCabThumbView setDelegate:self];
    
    self.loadingView = [[LoadingView alloc] init];
    self.showType = [CommonVar getDocumentOptionView];
    [self updateUIBaseOnTypes];
    
    [[EventManager getInstance] addListener:self channel:CHANNEL_DATA];
}

- (void)dealloc {
    //Observe for thumb download event
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    if ([DocumentDataManager getInstance].delegateDownloadImage == self)
        [DocumentDataManager getInstance].delegateDownloadImage = nil;
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (BOOL)shouldUseBackButton {
    return YES;
}

- (BOOL)shouldHideToolBar {
    return NO;
}

#pragma mark - Layout
- (void)relayout {
    [super relayout];
    
    self.tbDocumentList.frame = self.contentView.frame;
    
    [self.documentsCabThumbView setFrame:self.tbDocumentList.frame];
    [self.documentCabinetView setWidth:self.tbDocumentList.frame.size.width];
    [self.documentTagsView setWidth:self.tbDocumentList.frame.size.width];
    
    float keyboardHeight = kKeyboardHeight;
    UIInterfaceOrientation  orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        keyboardHeight = kKeyboardHeight + 88;
    }
    
    if (self.isShowingCabinetsView) {
        [self.documentCabinetView setBottom:[self.contentView bottom]];
        [self.tbDocumentList setHeight:[self.documentCabinetView top] - 62];
        [self.documentsCabThumbView setHeight:self.tbDocumentList.frame.size.height];
        
        if (self.isShowingKeyboard) {
            [self.documentCabinetView setTop:[self.documentCabinetView top] - keyboardHeight];
            [self.tbDocumentList setHeight:[self.documentCabinetView top] - 62];
        }
    } else {
        [self.documentCabinetView setTop:self.view.bounds.size.height];
        //        [self.tbDocumentList setHeight:[self.documentCabinetView top] - 62];
        //        [self.documentsCabThumbView setHeight:self.tbDocumentList.frame.size.height - 70];
    }
    
    if (self.isShowingTagsView) {
        [self.documentTagsView setBottom:[self.contentView bottom]];
        [self.tbDocumentList setHeight:[self.documentTagsView top] - 62];
        [self.documentsCabThumbView setHeight:self.tbDocumentList.frame.size.height];
        
        if (self.isShowingKeyboard) {
            [self.documentTagsView setTop:[self.documentTagsView top] - keyboardHeight];
            [self.tbDocumentList setHeight:[self.documentTagsView top] - 62];
        }
    } else {
        [self.documentTagsView setTop:self.view.bounds.size.height];
        //        [self.tbDocumentList setHeight:[self.documentTagsView top] - 62];
        //        [self.documentsCabThumbView setHeight:self.tbDocumentList.frame.size.height - 70];
    }
    
    [self.view bringSubviewToFront:self.documentCabinetView];
    [self.view bringSubviewToFront:self.documentTagsView];
    [self.view bringSubviewToFront:self.bottomBarView];
    [self.view bringSubviewToFront:self.topBarView];
}

#pragma mark - My Funcs
- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return 100.0;
    return 40;
}

- (NSString*)getHeaderTitle:(int)count {
    NSString *format;
    if ([self.documentGroup isKindOfClass:[DocumentProfileObject class]]) {
        if (count > 1) {
            format = NSLocalizedString(@"ID_I_DOCUMENTS_IN_ACC", @"");
        } else {
            format = NSLocalizedString(@"ID_I_DOCUMENT_IN_ACC", @"");
        }
    } else {
        if (count > 1) {
            format = NSLocalizedString(@"ID_I_DOCUMENTS_IN_CAB", @"");
        } else {
            format = NSLocalizedString(@"ID_I_DOCUMENT_IN_CAB", @"");
        }
    }
    return [NSString stringWithFormat:format, count];
}

- (void)setHeaderNumOfDocsSelected:(int)count {
    NSString *documentSelected;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        documentSelected = [NSString stringWithFormat:@"%d of %d documents selected", count, [self.documentObjects count]];
    } else {
        documentSelected = [NSString stringWithFormat:@"%d selected", count];
    }
    
    [self.lblHeaderInSection setText:documentSelected];
    [self.documentsCabThumbView.groupCollectionEditView.lblHeaderInSection setText:documentSelected];
}

- (void)updateHeaderAlignment {
    NSTextAlignment alignment;
    if (self.tbDocumentList.isEditing) {
        alignment = NSTextAlignmentCenter;
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            alignment = NSTextAlignmentCenter;
        } else {
            alignment = NSTextAlignmentRight;
        }
    }
    
    self.lblHeaderInSection.textAlignment = alignment;
    self.documentsCabThumbView.groupCollectionEditView.lblHeaderInSection.textAlignment = alignment;
    
    self.btnSelect.hidden = self.isSelectMode;
    self.btnCancel.hidden = !self.isSelectMode;
    self.btnSelectAll.hidden = !self.isSelectMode;
    self.documentsCabThumbView.groupCollectionEditView.btnSelectAll.hidden = !self.isSelectMode;
}

- (void)showDocumentCabinetsView:(BOOL)show {
    [self.documentCabinetView resetView];
    
    if (show && !self.isShowingCabinetsView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentCabinetView setBottom:[self.contentView bottom]];
            [self.tbDocumentList setHeight:[self.documentCabinetView top] - 62];
            [self.documentsCabThumbView setHeight:self.tbDocumentList.frame.size.height];
            [self.documentsCabThumbView relayout];
        }];
    } else if (!show && self.isShowingCabinetsView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentCabinetView setTop:self.view.bounds.size.height];
            [self.tbDocumentList setHeight:[self.documentCabinetView top] - 132];
            [self.documentsCabThumbView setHeight:self.tbDocumentList.frame.size.height];
            [self.documentsCabThumbView relayout];
        }];
    }
    
    self.isShowingCabinetsView = show;
    
    if (!show) {
        self.selectedBottomCenterBarButton = nil;
    }
    [self updateHeaderAlignment];
}

- (void)showDocumentTagsView:(BOOL)show {
    [self.documentTagsView resetView];
    
    if (show && !self.isShowingTagsView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentTagsView setBottom:[self.contentView bottom]];
            [self.tbDocumentList setHeight:[self.documentTagsView top] - 62];
            [self.documentsCabThumbView setHeight:self.tbDocumentList.frame.size.height];
            [self.documentsCabThumbView relayout];
        }];
    } else if(!show && self.isShowingTagsView) {
        [UIView animateWithDuration:0.3 animations:^{
            [self.documentTagsView setTop:self.view.bounds.size.height];
            [self.tbDocumentList setHeight:[self.documentTagsView top] - 132];
            [self.documentsCabThumbView setHeight:self.tbDocumentList.frame.size.height];
            [self.documentsCabThumbView relayout];
        }];
    }
    
    self.isShowingTagsView = show;
    
    if (!show) {
        self.selectedBottomCenterBarButton = nil;
    }
    [self updateHeaderAlignment];
}

#pragma mark - Methods run in thread
- (void)deleteDocumentsThread:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self.view message:NSLocalizedString(@"ID_DELETING_DOCUMENTS", @"")];
    });
    
    BOOL res = [[DocumentDataManager getInstance] deleteDocuments:self.selectedDocuments];
    if (res) {
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_DELETE_DOCS];
        [event setContent:self.selectedDocuments];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
        
        //Update documents count for each tag relating to this document
        for (DocumentObject *doc in self.selectedDocuments) {
            NSArray *arrTags = [NSArray arrayWithArray:doc.tags];
            for (NSNumber *num in arrTags) {
                TagObject *tagObj = [[TagDataManager getInstance] getObjectByKey:num];
                if ([doc.tags containsObject:num]) {
                    [doc.tags removeObject:num];
                }
                [tagObj updateDocCount];
            }
        }
        
        [self.documentObjects removeObjectsInArray:self.selectedDocuments];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.documentsCabThumbView removeDocument:self.selectedDocuments];
            
            self.tbDocumentList.allowsMultipleSelectionDuringEditing = NO;
            self.tbDocumentList.allowsMultipleSelection = NO;
            [self.tbDocumentList reloadData];
            [self.tbDocumentList setEditing:NO animated:NO];
            
            [self showDocumentCabinetsView:NO];
            [self showDocumentTagsView:NO];
            
            [self.selectedDocuments removeAllObjects];
            
            [self handleCancelButton:nil]; //Cancel selecting mode --> change to normal mode
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
        self.selectedBottomCenterBarButton = nil;
    });
    [threadObj releaseOperation];
}

- (void)shareDocuments:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    self.loadingView.threadObj = threadObj;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self.view];
    });
    
    NSArray *docIds = [self.selectedDocuments valueForKeyPath:@"id"];
    NSError *error;
    NSString *messageDecoded = nil;
    id response = [[DocumentDataManager getInstance] getMultiDocMailLinks:docIds error:&error];
    if (response != nil) {
        NSString *messageEncoded = [response objectForKey:@"message"];
        NSData *messageData = [NSData dataWithBase64String:messageEncoded];
        messageDecoded = [[NSString alloc] initWithData:messageData encoding:NSUTF8StringEncoding];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
    });
    
    if (![threadObj isCancelled]) {
        if (messageDecoded.length > 0) {
            //Create new activity provider item to pass to the activity view controller
            MultiDocsShareProvider *provider = [[MultiDocsShareProvider alloc] init];
            provider.content = messageDecoded;
            
            UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[provider] applicationActivities:nil];
            
            NSArray *excludedActivities = @[UIActivityTypePostToTwitter, UIActivityTypePostToFacebook, UIActivityTypeMessage, UIActivityTypePostToWeibo,UIActivityTypeCopyToPasteboard, UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll];
            activityViewController.excludedActivityTypes = excludedActivities;
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self dismissViewControllerAnimated:NO completion:NULL]; //Dismiss old UIActivityViewController if existed
                [self presentViewController:activityViewController animated:YES completion:nil];
            });
        }
    }

    [threadObj releaseOperation];
}

#pragma mark - SetHighlightBottomCenterBarButton
- (void)setSelectedBottomCenterBarButton:(UIButton*)aButton {
    [super setSelectedBottomCenterBarButton:aButton];
    
    if (aButton) {
        self.btnOption.enabled = NO;
    } else {
        self.btnOption.enabled = YES;
    }
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
        
        [self.documentOptionsView.segmentControl setSelectedSegmentIndex:self.showType];
        UIViewController *optionViewController = [[UIViewController alloc] init];
        optionViewController.view = self.documentOptionsView;
        
        self.optionPopover = [[MyPopoverWrapper alloc] initWithContentViewController:optionViewController];
        [self.optionPopover setPopoverContentSize:CGSizeMake(250, 350) animated:NO];
        self.optionPopover.delegate = self;
    }
    
    [self.optionPopover presentPopoverFromRect:selectedButtonFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)handleAddTagsToDocuments:(id)sender {
    if ([self.selectedDocuments count] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_SELECT_DOCUMENT_FIRST", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    self.currentPopupView = self.documentTagsView;
    [self showDocumentCabinetsView:NO];
    [self showDocumentTagsView:YES];
    
    self.selectedBottomCenterBarButton = self.btnBottomTags;
}

- (void)handleShareButton:(id)sender {
    if ([self.selectedDocuments count] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_SELECT_DOCUMENT_FIRST", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(shareDocuments:threadObj:) argument:@""];
}

- (void)handleDeleteDocuments:(id)sender {
    self.selectedBottomCenterBarButton = self.btnBottomDelete;
    
    if ([self.selectedDocuments count] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_SELECT_DOCUMENT_FIRST", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_CONFIRM", @"") tag:kConfirmToDeleteDocs content:NSLocalizedString(@"ID_DELETE_DOC_CONFIRM", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitles:NSLocalizedString(@"ID_CANCEL", @"")];
}

- (void)handleCabinetButton:(id)sender {
    if ([self.selectedDocuments count] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_SELECT_DOCUMENT_FIRST", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    self.currentPopupView = self.documentCabinetView;
    [self showDocumentTagsView:NO];
    [self showDocumentCabinetsView:YES];
    self.selectedBottomCenterBarButton = self.btnBottomCabinets;
}

- (void)handleSelectButton:(id)sender {
    [self setHeaderNumOfDocsSelected:0];
    self.isSelectMode = YES;
    
    [self.btnSelect setHidden:YES];
    [self.btnCancel setHidden:NO];
    [self.btnSelectAll setHidden:NO];
    [self.documentsCabThumbView.groupCollectionEditView.btnSelect setHidden:YES];
    [self.documentsCabThumbView.groupCollectionEditView.btnCancel setHidden:NO];
    self.documentsCabThumbView.isEditingMode = YES;
    
    [self.selectedIndexes removeAllObjects];
    [self.selectedCells removeAllObjects];
    [self.tbDocumentList beginUpdates];
    [self.tbDocumentList endUpdates];
    
    self.tbDocumentList.allowsSelection = YES;
    self.tbDocumentList.allowsMultipleSelectionDuringEditing = YES;
    self.tbDocumentList.allowsMultipleSelection = YES;
    [self.tbDocumentList setEditing:YES animated:YES];
    
    [self updateHeaderAlignment];
}

- (void)handleSelectAllButton:(id)sender {
    if (![self.tbDocumentList isEditing]) return;
    
    [self.selectedDocuments removeAllObjects];
    [self.selectedDocuments addObjectsFromArray:self.documentObjects];
    
    [NSThread detachNewThreadSelector:@selector(selectAllDocuments) toTarget:self withObject:nil];
    
    self.documentsCabThumbView.selectedDocuments = self.selectedDocuments;
    [self.documentsCabThumbView.collectDocumentCabinet reloadData];
    
    [self.documentTagsView loadViewWithDocumentList:self.selectedDocuments];
    [self.documentCabinetView loadViewWithDocumentList:self.selectedDocuments];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setHeaderNumOfDocsSelected:self.selectedDocuments.count];
    });
}

- (void)selectAllDocuments {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self.view message:NSLocalizedString(@"ID_SELECTING_DOCUMENTS", @"")];
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        for (int i = 0; i < self.documentObjects.count; i++) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:i inSection:0];
            [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
    });
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
    });
}

- (void)handleCancelButton:(id)sender {
    self.isSelectMode = NO;
    
    self.lblHeaderInSection.text = [self getHeaderTitle:self.documentObjects.count];
    
    self.btnCancel.hidden = YES;
    self.btnSelect.hidden = NO;
    self.btnSelectAll.hidden = YES;
    [self.documentsCabThumbView.groupCollectionEditView.btnSelect setHidden:NO];
    [self.documentsCabThumbView.groupCollectionEditView.btnCancel setHidden:YES];
    self.documentsCabThumbView.isEditingMode = NO;
    [self.documentsCabThumbView.selectedDocuments removeAllObjects];
    [self.documentsCabThumbView.collectDocumentCabinet reloadData];
    [self.documentsCabThumbView.groupCollectionEditView.lblHeaderInSection setText:[self.documentsCabThumbView.groupCollectionEditView getHeaderString]];
    
    self.tbDocumentList.allowsSelection = NO;
    self.tbDocumentList.allowsMultipleSelectionDuringEditing = NO;
    self.tbDocumentList.allowsMultipleSelection = NO;
    [self.tbDocumentList setEditing:NO animated:YES];
    
    [self.selectedDocuments removeAllObjects];
    [self showDocumentTagsView:NO];
    [self showDocumentCabinetsView:NO];
    
    [self updateHeaderAlignment];
}

- (void)handleDoneButton:(id)sender {
    
}

#pragma mark - Keyboard events
- (void)keyboardDidHide {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) return;
    if (self.currentPopupView == nil) return;
    [self moveViewToAboveKeyboard:self.currentPopupView isAbove:NO];
}

- (void)keyboardDidShow {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) return;
    if (self.currentPopupView == nil) return;
    [self moveViewToAboveKeyboard:self.currentPopupView isAbove:YES];
}

#pragma mark - uitableviewdelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.documentObjects count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DocumentObject *document = [self.documentObjects objectAtIndex:indexPath.row];
    if (![tableView isEditing]) {
//        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
//        [appDelegate goToDocumentDetail:document documents:self.documentObjects];
    } else {
        if (![self.selectedDocuments containsObject:document]) {
            [self.selectedDocuments addObject:document];
        }
        
        if (![self.documentsCabThumbView.selectedDocuments containsObject:document]) {
            [self.documentsCabThumbView.selectedDocuments addObject:document];
        }
        [self.documentsCabThumbView.collectDocumentCabinet reloadData];
        [self.documentTagsView loadViewWithDocumentList:self.selectedDocuments];
        [self.documentCabinetView loadViewWithDocumentList:self.selectedDocuments];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setHeaderNumOfDocsSelected:self.selectedDocuments.count];
        });
    }
}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    DocumentObject *document = [self.documentObjects objectAtIndex:indexPath.row];
    if ([self.selectedDocuments containsObject:document]) {
        [self.selectedDocuments removeObject:document];
    }
    
    if ([self.documentsCabThumbView.selectedDocuments containsObject:document]) {
        [self.documentsCabThumbView.selectedDocuments removeObject:document];
    }
    [self.documentsCabThumbView.collectDocumentCabinet reloadData];
    
    [self.documentTagsView loadViewWithDocumentList:self.selectedDocuments];
    [self.documentCabinetView loadViewWithDocumentList:self.selectedDocuments];
    
    if ([self.selectedDocuments count] == 0) {
        [self showDocumentTagsView:NO];
        [self showDocumentCabinetsView:NO];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setHeaderNumOfDocsSelected:self.selectedDocuments.count];
    });
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // If our cell is selected, return double height
	if([self cellIsSelected:indexPath]) {
		return [self calculateHeightForIndexPath:indexPath];
	}
	
	// Cell isn't selected so return single height
    DocumentObject *document = [self.documentObjects objectAtIndex:indexPath.row];
    int heightForTagView = [self getHeightForTagView:document];
    float y = 40;
    return MAX(HEIGHT_FOR_ROW, y + heightForTagView);
    //return HEIGHT_FOR_ROW + heightForTagView;
}

- (CGFloat)getHeightForTagView:(DocumentObject *)document {
    float widthConstraint = self.tbDocumentList.frame.size.width - 135;
    int row = [TagListView getRowCountForDocument:document byWidth:widthConstraint];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (row > 3)
            row = 3;
    }
    
    return row * TAG_VIEW_HEIGHT;
}

- (BOOL)cellIsSelected:(NSIndexPath *)indexPath {
	NSNumber *selectedIndex = [self.selectedIndexes objectForKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
	return selectedIndex == nil ? FALSE : [selectedIndex boolValue];
}

- (int)calculateHeightForIndexPath:(NSIndexPath *)indexPath
{
    DocumentCell *selectedCell = [self.selectedCells objectForKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    DocumentObject *document = [self.documentObjects objectAtIndex:indexPath.row];
    int heightForTagView = [self getHeightForTagView:document];
    
    int height = HEIGHT_FOR_ROW + selectedCell.documentInfoView.frame.size.height + heightForTagView;
    return height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return HEIGHT_FOR_HEADER;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEIGHT_FOR_HEADER)];
    v.backgroundColor = kDocumentGroupHeaderColor;
    
    self.lblHeaderInSection = [[UILabel alloc] initWithFrame:CGRectMake(kGroupHeaderMargin, 0, self.view.frame.size.width - kGroupHeaderMargin*2, HEIGHT_FOR_HEADER - 2)];
    
    [self.lblHeaderInSection setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal] textColor:kGrayColor backgroundColor:kDocumentGroupHeaderColor text:@"" numberOfLines:0 textAlignment:NSTextAlignmentCenter];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.lblHeaderInSection.textAlignment = NSTextAlignmentRight;
    }
    [self.lblHeaderInSection setUserInteractionEnabled:YES];
    [v addSubview:self.lblHeaderInSection];
    
    self.btnSelect = [CommonLayout createTextButton:CGRectMake(0, 0, 100, 40) fontSize:kFontSizeXLarge isBold:YES text:NSLocalizedString(@"ID_SELECT", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleSelectButton:) superView:v];
    
    self.btnCancel = [CommonLayout createTextButton:self.btnSelect.frame fontSize:kFontSizeXLarge isBold:YES text:NSLocalizedString(@"ID_CANCEL", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleCancelButton:) superView:v];
    
    self.btnSelectAll = [CommonLayout createTextButton:CGRectMake(self.view.frame.size.width - 100, 0, 100, 40) fontSize:kFontSizeXLarge isBold:YES text:NSLocalizedString(@"ID_SELECT_ALL", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleSelectAllButton:) superView:v];
    
    if ([tableView isEditing]) {
        [self.btnCancel setHidden:NO];
        [self.btnSelect setHidden:YES];
        [self.btnSelectAll setHidden:NO];
    } else {
        [self.btnCancel setHidden:YES];
        [self.btnSelect setHidden:NO];
        [self.btnSelectAll setHidden:YES];
    }
    
    if ([tableView isEditing]) {
        [self setHeaderNumOfDocsSelected:self.selectedDocuments.count];
    } else {
        NSString *headerTitle = [self getHeaderTitle:self.documentObjects.count];
        self.lblHeaderInSection.text = headerTitle;
    }
    
    return v;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    DocumentCell *cell = nil;
    static NSString *cellFollowingIdentifier = @"DocumentCell";
	cell = [self.tbDocumentList dequeueReusableCellWithIdentifier:cellFollowingIdentifier];
    
    // Get data object from array
    if (indexPath.row >= [self.documentObjects count]) return cell;
    DocumentObject *documentObj = [self.documentObjects objectAtIndex:indexPath.row];
    
	if (cell == nil) {
		cell = [[DocumentCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellFollowingIdentifier tableView:tableView];
		cell.accessoryType  = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleDefault;
	}
    
    cell.delegate = self;
    
    //[DocumentDataManager getInstance].delegateDownloadImage = self;
    //[[DocumentDataManager getInstance] loadThumbnailForImageView:cell.imvThumb docObj:documentObj];
    if ([[CommonDataManager getInstance] isDocumentThumbDataAvailable:documentObj]) {
        //[documentObj.docThumbImage setToImageView:cell.imvThumb];
    } else {
        [[DocumentDataManager getInstance] downloadThumbnailForDocument:documentObj];
    }
    
    [cell updateCellWithObject:documentObj isSelected:[self cellIsSelected:indexPath]];
    cell.tagListView.delegate = self;
    cell.documentInfoView.tagListView.delegate = self;
    
	return cell;
}

#pragma mark - DocumentCellDelegate
- (void)moveViewToAboveKeyboard:(BaseView *)view isAbove:(BOOL)isAbove {
    CGRect rect = view.frame;
    float keyboardHeight = kKeyboardHeight;
    UIInterfaceOrientation  orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft || orientation == UIDeviceOrientationLandscapeRight) {
        keyboardHeight = kKeyboardHeight + 88;
    }
    
    if (isAbove && !self.isShowingKeyboard) {
        [UIView animateWithDuration:0.3 animations:^{
            [view setTop:rect.origin.y - keyboardHeight];
            [self.tbDocumentList setHeight:[view top] - 62];
        }];
    } else if (!isAbove && self.isShowingKeyboard) {
        if ([view isKindOfClass:[DocumentInfoView class]]) {
            [(DocumentInfoView *)view setEditStatus:NO];
        }
        
        [UIView animateWithDuration:0.3 animations:^{
            [view setTop:rect.origin.y + keyboardHeight];
            [self.tbDocumentList setHeight:[view top] - 62];
        }];
    }
    
    self.isShowingKeyboard = isAbove;
}

- (void)didButtonInfoTouched:(id)sender for:(DocumentObject *)docObj {
    if ([self.tbDocumentList isEditing]) return;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.documentInfoViewed = docObj; //Store current document being viewed
        
        DocumentInfoViewController *target = [[DocumentInfoViewController alloc] initWithNibName:@"DocumentInfoViewController" bundle:[NSBundle mainBundle]];
        target.arrDocuments = self.documentObjects;
        target.document = docObj;
        [self.navigationController pushViewController:target animated:YES];
        return;
    }

    DocumentCell *selectedCell = (DocumentCell *)sender;
    NSIndexPath *indexPath = [self.tbDocumentList indexPathForCell:selectedCell];
    
    // Toggle 'selected' state
	BOOL isSelected = ![self cellIsSelected:indexPath];
    [selectedCell showDocumentInfo:isSelected];
	
	// Store cell 'selected' state keyed on indexPath
	NSNumber *selectedValue = [NSNumber numberWithBool:isSelected];
    [self.selectedIndexes removeAllObjects];
    [self.selectedCells removeAllObjects];
	[self.selectedIndexes setObject:selectedValue forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    [self.selectedCells setObject:selectedCell forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    
	// This is where magic happens...
    [self.tbDocumentList beginUpdates];
	[self.tbDocumentList endUpdates];
}

- (void)didCloseButtonTouched:(id)sender for:(DocumentObject *)docObj {
//    DocumentCell *selectedCell = (DocumentCell *)sender;
//    NSIndexPath *indexPath = [self.tbDocumentList indexPathForCell:selectedCell];
//    
//    // Store cell 'selected' state keyed on indexPath
//	NSNumber *selectedValue = [NSNumber numberWithBool:NO];
    [self.selectedIndexes removeAllObjects];
    [self.selectedCells removeAllObjects];
//	[self.selectedIndexes setObject:selectedValue forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
//    [self.selectedCells setObject:selectedCell forKey:[NSString stringWithFormat:@"%d_%d", indexPath.section, indexPath.row]];
    
	// This is where magic happens...
    [self.tbDocumentList beginUpdates];
	[self.tbDocumentList endUpdates];
}

- (void)documentCell:(DocumentCell *)cell willUpdateDocumentValue:(DocumentObject *)newDoc withProperties:(NSArray *)properties {
    BOOL res = [[DocumentDataManager getInstance] updateDocumentInfo:newDoc];
    if (res) {
        DocumentObject *updateObj = (DocumentObject*)[CommonFunc findObjectWithValue:newDoc.id bykey:@"id" fromArray:self.documentObjects];
        if (updateObj) {
            [updateObj updateProperties:properties fromObject:newDoc];
            [self.tbDocumentList reloadData];
            Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_EDIT_DOC];
            [event setContent:updateObj];
            [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
        }
    } else {
        [self.tbDocumentList reloadData];
    }
}

- (void)didTouchCell:(id)sender documentObject:(DocumentObject *)docObj {
    if (self.tbDocumentList.isEditing) {
        DocumentCell *documentCell = sender;
        NSIndexPath *indexPath = [self.tbDocumentList indexPathForCell:documentCell];
        if (documentCell.selected) {
            [self.tbDocumentList deselectRowAtIndexPath:indexPath animated:NO];
            [self tableView:self.tbDocumentList didSelectRowAtIndexPath:indexPath];
        } else {
            [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
            [self tableView:self.tbDocumentList didDeselectRowAtIndexPath:indexPath];
        }
    } else {
        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate goToDocumentDetail:docObj documents:self.documentObjects];
    }
}

- (void)tagViewDidEditTouched:(id)sender forDocument:(DocumentObject *)docObj
{   
    if (![self.tbDocumentList isEditing]) {
        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate goToDocumentDetail:docObj documents:self.documentObjects actionType:ACTIONTYPE_EDIT_TAGS];
    }
}

#pragma mark - DocumentCabinetsViewDelegate
- (void)didCabinetsViewDoneButtonTouched:(id)sender {
    [self showDocumentCabinetsView:NO];
}

- (void)didSelectCabinet:(CabinetObject *)cabObj {
    [[CommonDataManager getInstance] addCabinet:cabObj toDocuments:self.selectedDocuments];
}

- (void)didDeselectCabinet:(CabinetObject *)cabObj {
    [[CommonDataManager getInstance] removeCabinet:cabObj fromDocuments:self.selectedDocuments];
}

#pragma mark - DocumentTagsViewDelegate
- (void)didTagsViewDoneButtonTouched:(id)sender {
    [self showDocumentTagsView:NO];
}

- (void)didSelectTag:(TagObject *)tagObj{
    [[CommonDataManager getInstance] addTag:tagObj toDocuments:self.selectedDocuments];
}

- (void)didDeselectTag:(TagObject *)tagObj {
    [[CommonDataManager getInstance] removeTag:tagObj fromDocuments:self.selectedDocuments];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kConfirmToDeleteDocs) {
        if (buttonIndex == 0)
            [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(deleteDocumentsThread:threadObj:) argument:@""];
        else
            self.selectedBottomCenterBarButton = nil;
    }
}

#pragma mark - EventProtocol methods
- (void)didReceiveEvent:(Event *)event {
    EVENTTYPE eventType = [event getEventType];
    if (eventType == EVENT_TYPE_LOAD_COMMON_DATA) {
        
    } if (eventType == EVENT_TYPE_EDIT_DOC) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
            [self.tbDocumentList reloadData];
        });
    } else if (eventType == EVENT_TYPE_DELETE_DOCS) {
        NSMutableArray *documents = [event getContent];
        for (DocumentObject *docObj in documents) {
            if ([self.documentObjects containsObject:docObj]) {
                [self.documentObjects removeObject:docObj];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
            [self.tbDocumentList reloadData];
        });
    } else if (eventType == EVENT_TYPE_DELETE_DOC) {
        DocumentObject *docObj = [event getContent];
        if ([self.documentObjects containsObject:docObj]) {
            [self.documentObjects removeObject:docObj];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
            [self.tbDocumentList reloadData];
        });
    } else if (eventType == EVENT_TYPE_ADD_TAGS_TO_DOCUMENTS || eventType == EVENT_TYPE_REMOVE_TAGS_FROM_DOCUMENTS) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (self.documentGroup != nil && [self.documentGroup isKindOfClass:[DocumentCabinetObject class]]) {
                DocumentCabinetObject *docCabObj = (DocumentCabinetObject *)self.documentGroup;
                if ([docCabObj.cabinetObj.type isEqualToString:kCabinetUntaggedType]) {
                    [self.selectedDocuments removeAllObjects];
                    self.documentsCabThumbView.selectedDocuments = self.selectedDocuments;
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showDocumentTagsView:NO];
                    });
                }
            }
            
            [self.documentsCabThumbView.collectDocumentCabinet reloadData];
            [self.tbDocumentList reloadData];
            [self.documentTagsView.selectTagsView filterItems];
            
            for (DocumentObject *docObj in self.selectedDocuments) {
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.documentObjects indexOfObject:docObj] inSection:0];
                [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
            }
        });
    } else if (eventType == EVENT_TYPE_ADD_CABS_TO_DOCUMENTS) {
        if ([self.documentGroup isKindOfClass:[DocumentCabinetObject class]]) {
            DocumentCabinetObject *documentCabinetObj = (DocumentCabinetObject *)self.documentGroup;
            NSMutableArray *documents = [event getContent];
            for (DocumentObject *documentObj in documents) {
                if ([documentObj.cabs containsObject:documentCabinetObj.cabinetObj.id] && ![documentCabinetObj.arrDocuments containsObject:documentObj]) {
                    [documentCabinetObj.arrDocuments addObject:documentObj];
                    
                    documentCabinetObj.cabinetObj.docCount = [NSNumber numberWithInt:[documentCabinetObj.arrDocuments count]];
                } else if ([documentCabinetObj.cabinetObj.type isEqualToString:kCabinetUncategorizedType]) {
                    [documentCabinetObj.arrDocuments removeObject:documentObj];
                    documentCabinetObj.cabinetObj.docCount = [NSNumber numberWithInt:[documentCabinetObj.arrDocuments count]];
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.documentsCabThumbView.collectDocumentCabinet reloadData];
                [self.tbDocumentList reloadData];
                [self.documentCabinetView.selectCabinetsView filterItems];
                
                for (DocumentObject *docObj in self.selectedDocuments) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.documentObjects indexOfObject:docObj] inSection:0];
                    [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
                }
            });
        }
    } else if (eventType == EVENT_TYPE_REMOVE_CABS_FROM_DOCUMENTS) {
        if ([self.documentGroup isKindOfClass:[DocumentCabinetObject class]]) {
            DocumentCabinetObject *documentCabinetObj = (DocumentCabinetObject *)self.documentGroup;
            if (!documentCabinetObj.cabinetObj.isAutoCalculateItemsInside) {
                NSMutableArray *documents = [event getContent];
                for (DocumentObject *documentObj in documents) {
                    if ([documentCabinetObj.arrDocuments containsObject:documentObj] && ![documentObj.cabs containsObject:documentCabinetObj.cabinetObj.id]) {
                        [documentCabinetObj.arrDocuments removeObject:documentObj];
                        
                        documentCabinetObj.cabinetObj.docCount = [NSNumber numberWithInt:[documentCabinetObj.arrDocuments count]];
                    }
                }
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.tbDocumentList reloadData];
                [self.documentsCabThumbView.collectDocumentCabinet reloadData];
                [self.documentCabinetView.selectCabinetsView filterItems];
                
                for (DocumentObject *docObj in self.selectedDocuments) {
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.documentObjects indexOfObject:docObj] inSection:0];
                    [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
                }
            });
        }
    } else if (eventType == EVENT_TYPE_ADD_CABINET) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.documentCabinetView.selectCabinetsView filterItems];
        });
    } else if (eventType == EVENT_TYPE_REMOVE_CABINET) {
        CabinetObject *cabObj = [event getContent];
        if ([self.documentGroup isKindOfClass:[DocumentCabinetObject class]]) {
            DocumentCabinetObject *docCabObj = (DocumentCabinetObject *)self.documentGroup;
            if ([docCabObj.cabinetObj isEqual:cabObj]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    if ([[self.navigationController topViewController] isKindOfClass:[DocumentListViewController class]]) {
                        [[EventManager getInstance] removeListener:self channel:CHANNEL_DATA];
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                });
            }
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

- (void)updateUIBaseOnTypes {
    // TODO
    if (self.showType == SHOWTYPE_SNIPPET) {
        [self.documentsCabThumbView setHidden:YES];
        [self.tbDocumentList setHidden:NO];
    } else {
        [self.tbDocumentList setHidden:YES];
        [self.documentsCabThumbView setHidden:NO];
    }
}

#pragma mark - DocumentOptionsViewDelegate
- (void)didSelectSnippetsLayout:(id)sender {
    self.showType = SHOWTYPE_SNIPPET;
    [CommonVar setDocumentOptionView:self.showType];
    [self updateUIBaseOnTypes];
}

- (void)didSelectThumbsLayout:(id)sender {
    self.showType = SHOWTYPE_THUMB;
    [CommonVar setDocumentOptionView:self.showType];
    [self updateUIBaseOnTypes];
    [self.documentsCabThumbView.groupCollectionEditView refreshHeaderButtons:self.isSelectMode];
}

- (void)didSelectSortBy:(SORTBY)sortBy {
    [CommonVar setSortDocumentBy:sortBy];
    
    [CommonFunc sortDocuments:self.documentObjects sortBy:[CommonVar getSortDocumentBy]];
    [self.tbDocumentList reloadData];
    
    NSMutableArray *arrCabinets = self.documentsCabThumbView.arrDocumentCabinets;
    for (DocumentCabinetObject *docCabObj in arrCabinets) {
        [CommonFunc sortDocuments:docCabObj.arrDocuments sortBy:[CommonVar getSortDocumentBy]];
    }
    
    [self.documentsCabThumbView.collectDocumentCabinet reloadData];
}

#pragma mark - DocumentCabinetThumbViewDelegate
- (void)didSelectButton:(id)sender {
    [self setHeaderNumOfDocsSelected:0];
    self.isSelectMode = YES;
    
    [self.btnSelect setHidden:YES];
    [self.btnCancel setHidden:NO];
    [self.btnSelectAll setHidden:NO];
    
    NSArray *indexPaths = [self.selectedIndexes allKeys];
    if ([indexPaths count] > 0) {
        [self.selectedIndexes removeAllObjects];
        [self.selectedCells removeAllObjects];
        [self.tbDocumentList reloadData];
    }
    self.tbDocumentList.allowsSelection = YES;
    self.tbDocumentList.allowsMultipleSelectionDuringEditing = YES;
    self.tbDocumentList.allowsMultipleSelection = YES;
    [self.tbDocumentList setEditing:YES];
    
    [self updateHeaderAlignment];
}

- (void)didSelectAllButton:(id)sender {
    [self handleSelectAllButton:nil];
}

- (void)didCancelButton:(id)sender {
    self.lblHeaderInSection.text = [self getHeaderTitle:self.documentObjects.count];
    
    self.isSelectMode = NO;
    
    [self.btnSelect setHidden:NO];
    [self.btnCancel setHidden:YES];
    
    self.tbDocumentList.allowsSelection = NO;
    self.tbDocumentList.allowsMultipleSelectionDuringEditing = NO;
    self.tbDocumentList.allowsMultipleSelection = NO;
    [self.tbDocumentList setEditing:NO];
    
    [self.selectedDocuments removeAllObjects];
    [self showDocumentTagsView:NO];
    [self showDocumentCabinetsView:NO];
    
    [self updateHeaderAlignment];
}

- (void)didSelectDocument:(id)sender documentId:(id)documentId {
    DocumentObject *selectDocument = nil;
    for (DocumentObject *docObj in self.documentObjects) {
        if ([docObj.id isEqual:documentId]) {
            selectDocument = docObj;
            break;
        }
    }
    
    if (selectDocument != nil) {
        if (![self.selectedDocuments containsObject:selectDocument]) {
            [self.selectedDocuments addObject:selectDocument];
        }
        
        [self.documentTagsView loadViewWithDocumentList:self.selectedDocuments];
        [self.documentCabinetView loadViewWithDocumentList:self.selectedDocuments];
        
        for (DocumentObject *docObj in self.selectedDocuments) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.documentObjects indexOfObject:docObj] inSection:0];
            [self.tbDocumentList selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionBottom];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setHeaderNumOfDocsSelected:self.selectedDocuments.count];
        });
    }
}

- (void)didDeSelectDocument:(id)sender documentId:(id)documentId {
    DocumentObject *selectDocument = nil;
    for (DocumentObject *docObj in self.documentObjects) {
        if ([docObj.id isEqual:documentId]) {
            selectDocument = docObj;
            break;
        }
    }
    
    if (selectDocument != nil) {
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[self.documentObjects indexOfObject:selectDocument] inSection:0];
        [self.tbDocumentList deselectRowAtIndexPath:indexPath animated:NO];
        
        if ([self.selectedDocuments containsObject:selectDocument]) {
            [self.selectedDocuments removeObject:selectDocument];
        }
        
        [self.documentTagsView loadViewWithDocumentList:self.selectedDocuments];
        [self.documentCabinetView loadViewWithDocumentList:self.selectedDocuments];
        if ([self.selectedDocuments count] == 0) {
            [self showDocumentTagsView:NO];
            [self showDocumentCabinetsView:NO];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setHeaderNumOfDocsSelected:self.selectedDocuments.count];
        });
    }
}

#pragma mark - DownloadThumbnailProtocol
- (void)didDownloadImage:(UIImage*)image forDocument:(DocumentObject*)doc {
    /*NSArray *rows = self.tbDocumentList.indexPathsForVisibleRows;
    
    NSMutableArray *selectingRows = [[NSMutableArray alloc] init];
    for (NSIndexPath *index in rows) {
        UITableViewCell *cell = [self.tbDocumentList cellForRowAtIndexPath:index];
        if (cell.selected) {
            [selectingRows addObject:index];
        }
    }
    
    [self.tbDocumentList reloadRowsAtIndexPaths:rows withRowAnimation:UITableViewRowAnimationNone];
    
    for (NSIndexPath *index in selectingRows) {
        [self.tbDocumentList selectRowAtIndexPath:index animated:NO scrollPosition:UITableViewScrollPositionNone];
    }*/
    
    NSArray *cells = [self.tbDocumentList visibleCells];
    for (DocumentCell *cell in cells) {
        [cell refreshThumbnail];
    }
}

#pragma mark - Download Thumb notification
- (void)didDownloadThumb:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.view.window) //Is visible on screen
            [self didDownloadImage:nil forDocument:nil];
    });
}

@end
