//
//  SignUpView.h
//  FileThis
//
//  Created by Manh nguyen on 1/1/14.
//
//

#import "BaseView.h"
#import "BorderTextField.h"
#import "LoadingView.h"

@protocol SignUpViewDelegate <NSObject>

- (void)didBackButtonTouched:(id)sender;
- (void)didAccountCreated:(NSString *)email password:(NSString *)password;

@end

@interface SignUpView : BaseView<UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UIImageView *imgLogo;
@property (nonatomic, strong) UIView *titleView;
@property (nonatomic, strong) UILabel *lblTitle, *lblForever, *lblVersion;
@property (nonatomic, strong) BorderTextField *txtFirstName, *txtLastName, *txtEmail, *txtPassword, *txtConfirmPassword;
@property (nonatomic, strong) UILabel *lblTerm1, *lblTerm2;
@property (nonatomic, strong) UILabel *lblReadOur;
@property (nonatomic, strong) UIButton *btnBack, *btnBackIcon, *btnTermService, *btnPrivacy, *btnSignUp, *btnLearnMore, *btnLearnMoreIcon;
@property (nonatomic, assign) id<SignUpViewDelegate> delegate;
@property (nonatomic, strong) LoadingView *loadingView;

- (BOOL)isInputingText;
- (void)cancelInputingText;

@end
