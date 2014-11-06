//
//  DocumentCabinetsView.h
//  FileThis
//
//  Created by Manh nguyen on 1/4/14.
//
//

#import "BaseView.h"
#import "SelectCabinetsView.h"
#import "DocumentObject.h"

#define kDocumentCabinetsView_Height     350.0

@protocol DocumentCabinetsViewDelegate <NSObject>

- (void)didSelectCabinet:(CabinetObject *)cabObj;
- (void)didDeselectCabinet:(CabinetObject *)cabObj;
- (void)didCabinetsViewDoneButtonTouched:(id)sender;

@end

@interface DocumentCabinetsView : BaseView<UITextFieldDelegate, SelectItemsViewDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UITextField *txtSearchCabinets;
@property (nonatomic, strong) SelectCabinetsView *selectCabinetsView;
@property (nonatomic, strong) NSMutableArray *arrDocuments;
@property (nonatomic, strong) UILabel *lblTitle, *lblTemp;
@property (nonatomic, strong) UIButton *btnAddThisCabinet, *btnDone, *editButton;
@property (nonatomic, assign) id<DocumentCabinetsViewDelegate> delegate;
@property (nonatomic, strong) UIActivityIndicatorView *spinner;
@property (assign) BOOL isEditting;

- (void)loadViewWithDocumentList:(NSMutableArray *)documents;
- (void)refreshTextStatus;

@end
