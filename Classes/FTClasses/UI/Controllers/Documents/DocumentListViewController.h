//
//  DocumentListViewController.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "BaseViewController.h"
#import "DocumentCell.h"
#import "MyDetailViewController.h"
#import "DocumentCabinetsView.h"
#import "DocumentTagsView.h"
#import "EventProtocol.h"
#import "SortCriteriaObject.h"
#import "DocumentCabinetThumbView.h"
#import "DocumentProfileThumbView.h"
#import "DocumentOptionsView.h"
#import "MyPopoverWrapper.h"
#import "DocumentDataManager.h"

#define SHOWTYPE_THUMB      0
#define SHOWTYPE_SNIPPET    1

@interface DocumentListViewController : MyDetailViewController <UITableViewDataSource, UITableViewDelegate, DocumentCabinetsViewDelegate, DocumentCellDelegate, TagListViewDelegate, DocumentTagsViewDelegate, UIAlertViewDelegate, EventProtocol, UIPopoverControllerDelegate, DocumentOptionsViewDelegate, DocumentCabinetThumbViewDelegate, DownloadThumbnailProtocol>

@property (nonatomic, strong) NSMutableArray *documentObjects;
@property (nonatomic, strong) IBOutlet UITableView *tbDocumentList;
@property (nonatomic, assign) int cellEditingModeIndex;
@property (nonatomic, strong) DocumentCabinetsView *documentCabinetView;
@property (nonatomic, strong) BaseView *currentPopupView;
@property (nonatomic, strong) DocumentTagsView *documentTagsView;
@property (nonatomic, strong) UIButton *btnOption, *btnBottomShare, *btnBottomTags, *btnBottomDelete, *btnBottomCabinets, *btnSelect, *btnCancel, *btnSelectAll;
@property (nonatomic, strong) UILabel *lblHeaderInSection;
@property (nonatomic, assign) BOOL isShowingCabinetsView, isShowingTagsView, isShowingKeyboard;
@property (nonatomic, strong) NSMutableArray *selectedDocuments;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexes;
@property (nonatomic, strong) NSMutableDictionary *selectedCells;
@property (nonatomic, strong) id documentGroup;
@property (nonatomic, strong) DocumentCabinetThumbView *documentsCabThumbView;
@property (nonatomic, assign) int showType;
@property (nonatomic, strong) MyPopoverWrapper *optionPopover;
@property (nonatomic, strong) DocumentOptionsView *documentOptionsView;
@property (nonatomic, strong) LoadingView *loadingView;

@property (nonatomic, strong) DocumentObject *documentInfoViewed;

@property (nonatomic, assign) BOOL isSelectMode;

- (void)showDocumentCabinetsView:(BOOL)show;
- (void)showDocumentTagsView:(BOOL)show;
- (void)moveViewToAboveKeyboard:(BaseView *)view isAbove:(BOOL)isAbove;
- (void)updateUIBaseOnTypes;

- (void)didSelectSortBy:(SORTBY)sortBy;

@end
