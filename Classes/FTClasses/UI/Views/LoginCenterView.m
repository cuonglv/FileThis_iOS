//
//  LoginCenterView.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/13/14.
//
//

#import "LoginCenterView.h"

@implementation LoginCenterView

- (void)initializeView
{
    self.backgroundColor = [UIColor clearColor];
    
    UIImageView *bg = [[UIImageView alloc] initWithFrame:self.bounds];
    bg.image = [UIImage imageNamed:@"bg_white_transparent.png"];
    self.bgImageView = bg;
    [self addSubview:bg];
    
    LoginView *login = [[LoginView alloc] initWithFrame:self.bounds];
    login.delegate = self;
    self.loginView = login;
    
    SignUpView *signup = [[SignUpView alloc] initWithFrame:CGRectMake(self.bounds.size.width, 0, self.bounds.size.width, self.bounds.size.height)];
    signup.delegate = self;
    self.signUpView = signup;
    
    [self addSubview:login];
    [self addSubview:signup];
    
    self.isShowingLoginView = YES;
}

- (void)setupViewForIdiom:(UIUserInterfaceIdiom)aIdiom
{
    UIImage *img;
    if (aIdiom == UIUserInterfaceIdiomPad)
    {
        img = [UIImage imageNamed:@"bg_white_transparent.png"];
    }
    else
    {
        img = [UIImage imageNamed:@"bg_login_center.png"];
    }
    self.bgImageView.image = img;
    
    [self.loginView setupViewForIdiom:aIdiom];
    [self.signUpView setupViewForIdiom:aIdiom];
}

#pragma mark - Layout
- (void)layoutSubviews
{
    CGRect rect = self.bounds;
    self.bgImageView.frame = rect;
    
    if (self.isShowingLoginView)
    {
        rect.origin.x = 0;
    }
    else
    {
        rect.origin.x = -rect.size.width;
    }
    self.loginView.frame = rect;
    
    rect.origin.x += rect.size.width;
    self.signUpView.frame = rect;
}

#pragma mark - Public methods
- (void)showLoginView
{
    CGRect rectLogin = self.loginView.frame;
    CGRect rectSignup = self.signUpView.frame;
    
    self.isShowingLoginView = YES;
    [self cancelInputingText];
    [UIView animateWithDuration:0.2 animations:^{
        [self.loginView setLeft:rectLogin.origin.x + rectLogin.size.width];
        [self.signUpView setLeft:rectSignup.origin.x + rectSignup.size.width];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            self.bgImageView.image = [UIImage imageNamed:@"bg_login_center.png"];
        }
    }];
}

- (void)showSignUpView
{
    CGRect rectLogin = self.loginView.frame;
    CGRect rectSignup = self.signUpView.frame;
    
    self.isShowingLoginView = NO;
    [self cancelInputingText];
    [UIView animateWithDuration:0.2 animations:^{
        [self.loginView setLeft:rectLogin.origin.x - rectLogin.size.width];
        [self.signUpView setLeft:rectSignup.origin.x - rectSignup.size.width];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        {
            self.bgImageView.image = [UIImage imageNamed:@"bg_signup_center.png"];
        }
    }];
}

- (BOOL)isInputingText
{
    BOOL inputing = ([self.loginView isInputingText] || [self.signUpView isInputingText]);
    return inputing;
}

- (void)cancelInputingText
{
    [self.loginView cancelInputingText];
    [self.signUpView cancelInputingText];
}

#pragma mark - LoginViewDelegate
- (void)didSignUpButtonTouched:(id)sender {
    [self showSignUpView];
}

#pragma mark - SignUpViewDelegate
- (void)didBackButtonTouched:(id)sender {
    [self showLoginView];
}

- (void)didAccountCreated:(NSString *)email password:(NSString *)password {
    [self.loginView.txtEmail setText:email];
    [self.loginView.txtPassword setText:password];
    [self showLoginView];
}

@end
