//
//  DocumentInfoView.h
//  FileThis
//
//  Created by Manh nguyen on 12/24/13.
//
//

#import "BaseView.h"
#import "TagListView.h"
#import "DocumentObject.h"
#import "SelectDateView.h"
#import "MyPopoverWrapper.h"
#import "CHLTextField.h"

#define kDocumentInfoView_Height    350.0

@protocol DocumentInfoViewDelegate <NSObject>
@optional
- (void)didCloseButtonTouched:(id)sender;
- (void)didEditFilenameButtonTouched:(id)sender;
- (void)willUpdateDocumentValue:(DocumentObject*)newDoc withProperties:(NSArray*)properties;

@end

@interface DocumentInfoView : BaseView<UIPopoverControllerDelegate, SelectDateViewDelegate>

@property (nonatomic, strong) UIView *topView, *centerView;
@property (nonatomic, strong) UIButton *btnSave, *btnClose, *btnEditFileName, *btnEditRelevant;
@property (nonatomic, strong) CHLTextField *txtDocumentName, *txtRelevantDate;
@property (nonatomic, strong) TagListView *tagListView;
@property (nonatomic, strong) UILabel *lblTitle, *lblNumberPages, *lblFileSize, *lblAddedDate, *lblCreatedDate;
@property (nonatomic, assign) id<DocumentInfoViewDelegate> delegate;
@property (nonatomic, strong) DocumentObject *documentObj;
@property (nonatomic, strong) MyPopoverWrapper *popoverController;
@property (nonatomic, strong) NSDate *relevantDate;
@property (nonatomic, strong) UIView *line1, *line2, *line3, *line4, *line5, *line6;
@property (nonatomic, assign) BOOL isEditing;

- (BOOL)shouldShowTitleHeader;
- (void)loadViewWithDocument:(DocumentObject *)documentObj;
- (void)setEditStatus:(BOOL)status;
- (void)showPickerView:(UIButton *)buttonTouched;

- (void)handleCloseButton:(id)sender;
- (void)handleSaveButton:(id)sender;

@end
