//
//  EnterDocumentNameView.h
//  FileThis
//
//  Created by Cuong Le on 12/26/13.
//
//

#import <UIKit/UIKit.h>

@protocol EnterDocumentNameViewDelegate <NSObject>
- (void)enterDocumentNameView_DidCancel:(id)sender;
- (void)enterDocumentNameView:(id)sender doneWithName:(NSString*)aName;
@end

@interface EnterDocumentNameView : UIView<UITextFieldDelegate>
@property (nonatomic, assign) id<EnterDocumentNameViewDelegate> enterDocumentNameViewDelegate;
@property (nonatomic, strong) UILabel *titleLabel, *descriptionLabel;
@property (nonatomic, strong) UITextField *nameTextField;
@property (nonatomic, strong) UIButton *cancelButton, *uploadButton;
- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<EnterDocumentNameViewDelegate>)delegate;
@end
