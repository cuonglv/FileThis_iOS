//
//  ForgotPasswordPopupView.h
//  FileThis
//
//  Created by Cuong Le on 3/4/14.
//
//

#import "WhiteRoundRectPopupView.h"

@interface ForgotPasswordPopupView : WhiteRoundRectPopupView <UITextFieldDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) UITextField *emailTextField, *passwordTextField, *retypePasswordTextField;

- (id)initWithEmail:(NSString*)email superView:(UIView*)superView delegate:(id<WhiteRoundRectPopupViewDelegate>)delegate;

@end
