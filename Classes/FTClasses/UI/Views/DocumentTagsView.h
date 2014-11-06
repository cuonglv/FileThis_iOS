//
//  DocumentTagsView.h
//  FileThis
//
//  Created by Manh nguyen on 12/25/13.
//
//

#import "BaseView.h"
#import "SelectTagsView.h"
#import "DocumentObject.h"
#import "BorderTextField.h"

#define kDocumentTagsView_Height 350.0
#define kKeyboardHeight 198
#define kKeyboardIPhoneHeight 150

@protocol DocumentTagsViewDelegate <NSObject>

- (void)didSelectTag:(TagObject *)tagObj;
- (void)didDeselectTag:(TagObject *)tagObj;
- (void)didTagsViewDoneButtonTouched:(id)sender;

@end

@interface DocumentTagsView : BaseView<UITextFieldDelegate, SelectItemsViewDelegate>

@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) BorderTextField *txtSearchTags;
@property (nonatomic, strong) SelectTagsView *selectTagsView;
@property (nonatomic, strong) NSMutableArray *arrDocuments;
@property (nonatomic, strong) UILabel *lblTitle, *lblTemp;
@property (nonatomic, strong) UIButton *btnAddThisTag, *btnDone, *editButton;
@property (nonatomic, assign) id<DocumentTagsViewDelegate> delegate;

- (void)loadViewWithDocumentList:(NSMutableArray *)documents;
- (void)refreshTextStatus;

@end
