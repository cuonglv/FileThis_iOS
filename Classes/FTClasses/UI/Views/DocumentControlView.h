//
//  DocumentControlView.h
//  FileThis
//
//  Created by Manh nguyen on 12/19/13.
//
//

#import "BaseView.h"
#import "DocumentObject.h"

@protocol DocumentControlViewDelegate <NSObject>

- (void)didInfoButtonTouched:(id)sender;
- (void)didTagsButtonTouched:(id)sender;
- (void)didDeleteButtonTouched:(id)sender;

@end

@interface DocumentControlView : BaseView<UIAlertViewDelegate>

@property (nonatomic, strong) UIButton *btnInfo, *btnTags, *btnDelete;
@property (nonatomic, assign) id<DocumentControlViewDelegate> delegate;
@property (nonatomic, strong) DocumentObject *documentObj;

@end
