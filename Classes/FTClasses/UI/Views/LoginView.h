//
//  LoginView.h
//  FileThis
//
//  Created by Manh nguyen on 1/1/14.
//
//

#import "BaseView.h"
#import "BorderTextField.h"
#import "LoadingView.h"
#import "ForgotPasswordPopupView.h"

@protocol  LoginViewDelegate <NSObject>

- (void)didSignUpButtonTouched:(id)sender;

@end

@interface LoginView : BaseView <UITextFieldDelegate, WhiteRoundRectPopupViewDelegate>

@property (nonatomic, strong) UIImageView *imgLogo;
@property (nonatomic, strong) UILabel *lblLogin;
@property (nonatomic, strong) BorderTextField *txtEmail, *txtPassword;
@property (nonatomic, strong) UIButton *btnForgotPassword, *btnLogin, *btnSignUp, *btnLearnMore;
@property (nonatomic, assign) id<LoginViewDelegate> delegate;
@property (nonatomic, strong) LoadingView *loadingView;

@property (nonatomic, strong) UIView *lblLine1;
@property (nonatomic, strong) UIView *lblLine2;
@property (nonatomic, strong) UILabel *lblOr;

- (BOOL)isInputingText;
- (void)cancelInputingText;
- (void)handleLoginButton:(id)sender;

@end
