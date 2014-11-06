//
//  DocumentGroupListViewController.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "MyDetailViewController.h"
#import "DocumentCell.h"
#import "DocumentCabinetListView.h"
#import "DocumentProfileListView.h"
#import "DocumentOptionsView.h"
#import "DocumentCabinetThumbView.h"
#import "DocumentProfileThumbView.h"
#import "EventProtocol.h"
#import "MyPopoverWrapper.h"

#define TYPE_CABINET    0
#define TYPE_PROFILE    1

#define SHOWTYPE_THUMB      0
#define SHOWTYPE_SNIPPET    1

@interface DocumentGroupListViewController : MyDetailViewController<UIPopoverControllerDelegate, DocumentOptionsViewDelegate, EventProtocol, EGORefreshTableHeaderDelegate>

@property (nonatomic, strong) DocumentCabinetListView *documentCabListView;
@property (nonatomic, strong) DocumentProfileListView *documentProfileListView;
@property (nonatomic, strong) DocumentCabinetThumbView *documentCabThumbView;
@property (nonatomic, strong) DocumentProfileThumbView *documentProfileThumbView;
@property (nonatomic, strong) UIButton *btnCabinets, *btnAccounts, *btnSetting, *btnSearch, *reloadButton;
@property (nonatomic, assign) int type;//0: Cabinets, 1: Account
@property (nonatomic, assign) int showType;//0: Snippet, 1: Thumb
@property (nonatomic, strong) MyPopoverWrapper *optionPopover;
@property (nonatomic, strong) DocumentOptionsView *documentOptionsView;
@property (nonatomic, assign) SORTBY sortBy;
@property (nonatomic, strong) id<ThreadProtocol> documentThread;

- (void)updateUIBaseOnTypes;
- (void)reloadUI;

@end
