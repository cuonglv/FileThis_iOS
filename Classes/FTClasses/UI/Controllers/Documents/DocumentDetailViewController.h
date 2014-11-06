//
//  DocumentDetailViewController.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "MyDetailViewController.h"
#import "DocumentObject.h"
#import "DocumentInfoView.h"
#import "DocumentTagsView.h"
#import "SearchPdfTextView_iphone.h"
#import "PageView.h"
#import "DocumentCabinetsView.h"
#import "DocumentPreviewLayoutViewOption.h"
#import "LoadingView.h"
#import "EventProtocol.h"
#import "MyPopoverWrapper.h"
#import "DocumentSearchCriteria.h"

@interface DocumentDetailViewController : MyDetailViewController<DocumentInfoViewDelegate, DocumentTagsViewDelegate, SearchPdfTextViewDelegate, PageViewDelegate, UIPopoverControllerDelegate, UIAlertViewDelegate, DocumentCabinetsViewDelegate, DocumentPreviewLayoutViewOptionDelegate, PageDelegate, EventProtocol, TagListViewDelegate> {
    CGPDFDocumentRef document;
}

@property (nonatomic, strong) UIButton *reloadButton;
@property (nonatomic, strong) DocumentObject *documentObj;
@property (nonatomic, strong) NSURL *docUrl;
@property (nonatomic, strong) DocumentInfoView *documentInfoView;
@property (nonatomic, strong) BaseView *currentPopupView;
@property (nonatomic, strong) DocumentTagsView *documentTagsView;
@property (nonatomic, assign) BOOL isShowingInfoView, isShowingTagsView, isShowingSearchView, isShowingCabinetView, isShowingKeyboard;
@property (nonatomic, strong) UIButton *btnShare, *btnExport, *btnCabinet, *btnTags, *btnInfo, *btnSearch, *btnView, *btnDelete;
@property (nonatomic, strong) SearchPdfTextView *searchTextView;
@property (nonatomic, strong) MyPopoverWrapper *viewOptionPopover;
@property (nonatomic, strong) DocumentPreviewLayoutViewOption *layoutOptionsView;
@property (nonatomic, strong) IBOutlet PageView *pageScrollView;
@property (nonatomic, copy) NSString *searchKeyword;
@property (nonatomic, strong) IBOutlet UIView *overlayView;
@property (nonatomic, strong) IBOutlet UILabel *lblDocumentInfo, *lblSearchResult;
@property (nonatomic, strong) UIButton *btnClearSearch;
@property (nonatomic, strong) DocumentCabinetsView *documentCabinetsView;
@property (nonatomic, assign) PageViewLayout pageViewLayout;
@property (nonatomic, assign) int selectedPageNumber;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) UIButton *btnNextDoc, *btnPrevDoc;
@property (nonatomic, strong) NSMutableArray *arrDocumentsInGroup;
@property (nonatomic, assign) int currentDocumentIndex;

//Search criteria passed from global search
@property (nonatomic, strong) DocumentSearchCriteria *documentSearchCriteria;

- (void)updateDocumentTitle;
- (void)loadPageNumber:(int)pageNumber pageView:(PageView *)pageView;
- (void)initializeToolbarButtons;
- (void)moveViewToAboveKeyboard:(BaseView *)view isAbove:(BOOL)isAbove;
- (void)enableToolbarButtons:(BOOL)enabled;
- (void)handleSearchButton:(id)sender;

@end
