//
//  LoginCenterView.h
//  FileThis
//
//  Created by Cao Huu Loc on 2/13/14.
//
//

#import <UIKit/UIKit.h>
#import "LoginView.h"
#import "SignUpView.h"
#import "BaseView.h"

@interface LoginCenterView : BaseView <LoginViewDelegate, SignUpViewDelegate>

@property (nonatomic, retain) UIImageView *bgImageView;
@property (nonatomic, retain) LoginView *loginView;
@property (nonatomic, retain) SignUpView *signUpView;
@property (nonatomic, assign) BOOL isShowingLoginView;

- (void)showLoginView;
- (void)showSignUpView;
- (BOOL)isInputingText;
- (void)cancelInputingText;

@end
