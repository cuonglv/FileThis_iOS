//
//  ChangePasswordPopup.h
//  FileThis
//
//  Created by Cao Huu Loc on 1/20/14.
//
//

#import <UIKit/UIKit.h>

@protocol ChangePasswordPopupDelegate <NSObject>
- (void)didChooseChangePassword:(NSString*)oldPassword withNewPassword:(NSString*)newPassword;
@optional
- (void)didCancelChangePassword;
@end

@interface ChangePasswordPopup : UIViewController <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *btnCancel;
@property (weak, nonatomic) IBOutlet UIButton *btnUpdate;
@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UITextField *txtOldPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtNewPassword;
@property (weak, nonatomic) IBOutlet UITextField *txtConfirmPassword;

@property (nonatomic, assign) id<ChangePasswordPopupDelegate> delegate;
@end
