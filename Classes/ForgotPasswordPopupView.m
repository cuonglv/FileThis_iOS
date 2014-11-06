//
//  ForgotPasswordPopupView.m
//  FileThis
//
//  Created by Cuong Le on 3/4/14.
//
//

#import "ForgotPasswordPopupView.h"
#import "CommonLayout.h"
#import "Utils.h"
#import "ThreadManager.h"
#import "LoadingView.h"
#import "FTSession.h"

#define MIN_PASSWORD_LENGTH 6
#define kAlertTag_InvalidEmail      1
#define kAlertTag_InvalidPassword   2
#define kAlertTag_PasswordsNotMatch 3
#define kAlertTag_Finished          4

@implementation ForgotPasswordPopupView

- (id)initWithEmail:(NSString*)email superView:(UIView*)superView delegate:(id<WhiteRoundRectPopupViewDelegate>)delegate {
    if (self = [super initWithSize:CGSizeMake(300, 280) titleOfPopup:NSLocalizedString(@"ID_FORGOT_PASSWORD", @"") titleOfLeftButton:NSLocalizedString(@"ID_CANCEL", @"") titleOfRightButton:NSLocalizedString(@"ID_OK", @"") superView:superView delegate:delegate]) {
        self.emailTextField = [CommonLayout createTextField:[self.titleLabel rectAtBottom:20 width:self.contentView.frame.size.width-40 height:35] fontSize:FontSizeSmall isBold:NO textColor:kTextGrayColor backgroundColor:[UIColor whiteColor] text:email superView:self.contentView];
        self.emailTextField.placeholder = NSLocalizedString(@"ID_EMAIL", @"");
        self.emailTextField.keyboardType = UIKeyboardTypeEmailAddress;
        self.emailTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        self.emailTextField.returnKeyType = UIReturnKeyNext;
        self.emailTextField.delegate = self;
        
        self.passwordTextField = [CommonLayout createTextField:[self.emailTextField rectAtBottom:20 height:35] font:self.emailTextField.font textColor:kTextGrayColor backgroundColor:[UIColor whiteColor] text:@"" superView:self.contentView];
        self.passwordTextField.placeholder = NSLocalizedString(@"ID_NEW_PASSWORD", @"");
        self.passwordTextField.secureTextEntry = YES;
        self.passwordTextField.returnKeyType = UIReturnKeyNext;
        self.passwordTextField.delegate = self;
        
        self.retypePasswordTextField = [CommonLayout createTextField:[self.passwordTextField rectAtBottom:20 height:35] font:self.emailTextField.font textColor:kTextGrayColor backgroundColor:[UIColor whiteColor] text:@"" superView:self.contentView];
        self.retypePasswordTextField.placeholder = NSLocalizedString(@"ID_RETYPE_NEW_PASSWORD", @"");
        self.retypePasswordTextField.secureTextEntry = YES;
        self.retypePasswordTextField.returnKeyType = UIReturnKeyDone;
        self.retypePasswordTextField.delegate = self;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.darkBackView.frame = self.bounds;
    self.darkBackView.center = self.center;
    self.contentView.center = self.center;
}

#pragma mark - Button events
- (void)handleRightButton {
    NSString *email = [self.emailTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (![Utils isValidEmail:email]) {
        [CommonLayout showWarningAlert:NSLocalizedString(@"ID_INVALID_EMAIL", @"") errorMessage:nil tag:kAlertTag_InvalidEmail delegate:self];
        [self.emailTextField becomeFirstResponder];
        return;
    }
    
    if ([self validatePassword]) {
        [self.emailTextField resignFirstResponder];
        [self.passwordTextField resignFirstResponder];
        [self.retypePasswordTextField resignFirstResponder];
        NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [[LoadingView currentLoadingView] startLoadingInView:self.superview.superview message:NSLocalizedString(@"ID_GENERATING_EMAIL", @"")];
        [[FTSession sharedSession] renewPassword:email withPassword:password onSuccess:^(id JSON) {
            //NSLog(@"%@", JSON);
            BOOL success = YES;
            NSString *errorMsg = @"Unknown error";
            if ([JSON isKindOfClass:[NSDictionary class]]) {
                NSDictionary *dic = (NSDictionary*)JSON;
                if ([[dic valueForKey:@"result"] caseInsensitiveCompare:@"ERROR"] == NSOrderedSame) {
                    NSDictionary *error = [dic valueForKey:@"error"];
                    if (error && [error isKindOfClass:[NSDictionary class]]) {
                        success = NO;
                        if ([[error valueForKey:@"text"] description].length > 0)
                            errorMsg = [[error valueForKey:@"text"] description];
                    }
                }
            }
            
            [[LoadingView currentLoadingView] stopLoading];
            if (!success) {
                [CommonLayout showWarningAlert:errorMsg errorMessage:nil delegate:nil];
            } else {
                [CommonLayout showInfoAlert:NSLocalizedString(@"ID_FORGOT_PASSWORD_FINISHED", @"") tag:kAlertTag_Finished delegate:self];
            }
        } onFailure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
            [[LoadingView currentLoadingView] stopLoading];
            NSLog(@"login connection error=%@", error);
            if (error.code == DOMAIN_ERROR_CODE) {
                [[FTSession sharedSession] handleError:error forResponse:response withTitle:@""];
            } else {
                [CommonLayout showWarningAlert:[error localizedDescription] errorMessage:nil delegate:nil];
            }
        }];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertTag_InvalidEmail) {
        [self.emailTextField becomeFirstResponder];
    } else if (alertView.tag == kAlertTag_InvalidPassword) {
        [self.passwordTextField becomeFirstResponder];
    } else if (alertView.tag == kAlertTag_PasswordsNotMatch) {
        [self.retypePasswordTextField becomeFirstResponder];
    } else if (alertView.tag == kAlertTag_Finished) {
        if ([self.delegate respondsToSelector:@selector(whiteRoundRectPopupView_ShouldCloseWithRightButtonTouched:)])
            [self.delegate whiteRoundRectPopupView_ShouldCloseWithRightButtonTouched:self];
        
        [self removeFromSuperview];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.emailTextField) {
        [self.passwordTextField becomeFirstResponder];
    } else if(textField == self.passwordTextField) {
        [self.retypePasswordTextField becomeFirstResponder];
    } else if(textField == self.retypePasswordTextField) {
        [self handleRightButton];
    }
    return YES;
}

#pragma mark - MyFunc
- (BOOL)validatePassword {
    NSString *password = [self.passwordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *passwordAgain = [self.retypePasswordTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([password length] < MIN_PASSWORD_LENGTH) {
        [CommonLayout showWarningAlert:[NSString stringWithFormat:NSLocalizedString(@"ID_PASSWORD_LENGTH", @""), MIN_PASSWORD_LENGTH] errorMessage:nil tag:kAlertTag_InvalidPassword delegate:self];
        return NO;
    } else if (![password isEqualToString:passwordAgain]) {
        [CommonLayout showWarningAlert:NSLocalizedString(@"ID_PASSWORD_NOT_MATCH", @"") errorMessage:nil tag:kAlertTag_PasswordsNotMatch delegate:self];
        return NO;
    } else if ([password rangeOfCharacterFromSet:[NSCharacterSet decimalDigitCharacterSet]].location == NSNotFound) {
        [CommonLayout showWarningAlert:[NSString stringWithFormat:NSLocalizedString(@"ID_PASSWORD_LENGTH", @""), MIN_PASSWORD_LENGTH] errorMessage:nil tag:kAlertTag_InvalidPassword delegate:self];
        return NO;
    } else if ([password rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].location == NSNotFound) {
        [CommonLayout showWarningAlert:[NSString stringWithFormat:NSLocalizedString(@"ID_PASSWORD_LENGTH", @""), MIN_PASSWORD_LENGTH] errorMessage:nil tag:kAlertTag_InvalidPassword delegate:self];
        return NO;
    }
    
    return YES;
}


@end
