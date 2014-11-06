//
//  InviteFriendViewController.m
//  FileThis
//
//  Created by Cao Huu Loc on 6/4/14.
//
//

#import "InviteFriendViewController.h"
#import "FTSession.h"
#import "CommonFunc.h"
#import "UserService.h"
#import "CacheManager.h"
#import <Crashlytics/Crashlytics.h>

#define kAlertTag_InviteSuccess     1
#define kAlertTag_InvalidEmail      2

@interface InviteFriendViewController ()
@property (nonatomic, strong) MyScrollView *scrollView; //iPhone 3.5 inch only
@end

@implementation InviteFriendViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //Loc test
    //[[Crashlytics sharedInstance] crash]; //Loc test
    //[FTSession setTest];
    //[[CacheManager getInstance] setServerUrl:[NSString stringWithFormat:@"https://%@/ftapi/ftapi?", @"astaging.filethis.com"]];
    //---
    
    self.titleLabel.text = @"Invite a Friend";
    self.view.backgroundColor = [UIColor whiteColor];
    self.loadingView = [[LoadingView alloc] init];
    
    //Border
    self.sendView.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1].CGColor;
    self.sendView.layer.borderWidth = 1;
    
    //self.txtEmail.borderColor = [UIColor colorWithRed:183/255.0 green:183/255.0 blue:183/255.0 alpha:1];
    self.txtEmail.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1];
    self.txtEmail.cornerRadius = 0;
    
    self.txtLink.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1].CGColor;
    self.txtLink.layer.borderWidth = 1;
    self.txtLink.editable = NO;
    
    //Font
    FontSize fontsize = IS_IPHONE ? FontSizeSmall : FontSizeXLarge;
    self.lblTitle.font = [CommonLayout getFont:fontsize isBold:YES];
    self.lblTitle.textColor = kTextOrangeColor;
    
    fontsize = IS_IPHONE ? FontSizeXSmall : FontSizeLarge;
    self.lblDescription.font = [CommonLayout getFont:fontsize isBold:NO isItalic:YES];
    self.lblDescription.textColor = kTextGrayColor;
    
    fontsize = IS_IPHONE ? FontSizeXSmall : FontSizeMedium;
    self.lblEmailTitle.font = [CommonLayout getFont:fontsize isBold:NO];
    self.txtEmail.font = [CommonLayout getFont:fontsize isBold:NO];
    
    self.lblLinkTitle.font = [CommonLayout getFont:fontsize isBold:NO];
    self.txtLink.font = [CommonLayout getFont:fontsize isBold:NO];
    
    //Register button events
    [self.btnSend addTarget:self action:@selector(clickedBtnSend:) forControlEvents:UIControlEventTouchUpInside];
    [self.btnCopyLink addTarget:self action:@selector(clickedBtnCopyLink:) forControlEvents:UIControlEventTouchUpInside];
    
    //Show data on GUI
    FTAccountSettings *settings = [FTSession sharedSession].settings;
    if (settings.socialMediaMessage.length > 0) {
        self.txtLink.text = settings.socialMediaMessage;
    } else {
        self.txtEmail.enabled = NO;
        self.btnCopyLink.enabled = NO;
    }
    
    //Add scroll view for iPhone 3.5 inch
    if (IS_IPHONE && ![CommonFunc isTallScreen]) {
        self.scrollView = [[MyScrollView alloc] initWithFrame:self.contentView.bounds];
        self.scrollView.touchDelegate = self;
        [self.contentView addSubview:self.scrollView];
        
        NSArray *subs = [[NSArray alloc] initWithArray:self.view.subviews];
        for (UIView *v in subs) {
            if (![v isEqual:self.topBarView] && ![v isEqual:self.contentView]) {
                CGRect rect = v.frame;
                rect.origin.y -= [self heightForTopBar] + kIOS7CarrierbarHeight;
                v.frame = rect;
                [self.scrollView addSubview:v];
            }
        }
        
        int bottom = [self.sendView bottom];
        self.scrollView.contentSize = CGSizeMake(self.contentView.frame.size.width, bottom);

        //Register keyboard notification
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardDidShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillBeHidden:) name:UIKeyboardWillHideNotification object:nil];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Private methods
- (void)executeSendInviteEmail:(NSString*)email {
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeSendInviteEmail:threadObj:) argument:email];
}

- (void)executeSendInviteEmail:(NSString*)email threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    self.loadingView.threadObj = threadObj;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView startLoadingInView:self.view];
    });
    
    UserService *service = [[UserService alloc] initSendInvitationTo:email];
    NSDictionary *response = [service sendRequestToServer];
    int sendID = 0;
    NSString *errorMessage = @"Send invitation failed";
    if ([response isKindOfClass:[NSDictionary class]]) {
        sendID = [[response objectForKey:@"id"] intValue];
        if ([response objectForKey:@"errorMessage"] != nil)
            errorMessage = [response objectForKey:@"errorMessage"];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingView stopLoading];
        
        if (sendID > 0) {
            [CommonLayout showAlertMessageWithTitle:nil content:@"Your invitation was sent" tag:kAlertTag_InviteSuccess delegate:self cancelButtonTitle:@"OK" otherButtonTitle:nil];
        } else {
            [CommonLayout showAlertMessageWithTitle:@"Error" content:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitle:nil];
        }
    });
    
    [threadObj releaseOperation];
}

#pragma mark - Layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    if (IS_IPHONE)
        return;

    //Top
    int left = 60;
    int width = self.view.frame.size.width - left * 2;
    [self.lblTitle setWidth:width];
    
    width = self.view.frame.size.width - left * 2;
    [self.lblDescription setWidth:width];
    
    //Center (send view)
    left = 40;
    width = self.view.frame.size.width - left * 2;
    [self.sendView setWidth:width];
    
    left = 20;
    width = self.sendView.frame.size.width - left * 2;
    [self.lblEmailTitle setWidth:width];
    [self.lineImageView setWidth:width];
    [self.lblLinkTitle setWidth:width];
    
    int space = 8;
    width = self.sendView.frame.size.width - left * 2 - self.btnSend.frame.size.width - space;
    [self.txtEmail setWidth:width];
    [self.btnSend setLeft:[self.txtEmail right] + space];
    
    [self.txtLink setWidth:width];
    [self.btnCopyLink setLeft:[self.btnSend left]];
}

#pragma mark - Touch events
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.txtEmail resignFirstResponder];
    [self.txtLink resignFirstResponder];
}

#pragma mark - MyScrollViewTouchEvent
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event sender:(id)sender {
    [self touchesEnded:touches withEvent:event];
}

#pragma mark - Button events
- (void)clickedBtnSend:(id)sender {
    //NSArray *arr = [CommonFunc emailsListFromString:self.txtEmail.text];
    //if (arr.count == 0) {
    NSString *trim = [self.txtEmail.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (![CommonFunc validateEmail:trim]) {
        [CommonLayout showWarningAlert:@"Invalid email format" errorMessage:nil tag:kAlertTag_InvalidEmail delegate:self];
        return;
    }
    
    [self executeSendInviteEmail:stringNotNil(self.txtEmail.text)];
}

- (void)clickedBtnCopyLink:(id)sender {
    [UIPasteboard generalPasteboard].string = self.txtLink.text;
}


#pragma mark - UITextField delegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    /*if (textField == self.txtEmail) {
        NSString *newString = [textField.text stringByReplacingCharactersInRange:range withString:string];
        newString = [newString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        BOOL valid = [CommonFunc validateEmail:newString];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.btnSend.enabled = valid;
        });
    }*/
    return YES;
}


#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertTag_InviteSuccess) {
        if (self.useBackButton) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Keyboard events
// Called when the UIKeyboardDidShowNotification is sent.
- (void)keyboardWasShown:(NSNotification*)aNotification
{
    NSDictionary* info = [aNotification userInfo];
    CGSize kbSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    UIEdgeInsets contentInsets = UIEdgeInsetsMake(0.0, 0.0, kbSize.height, 0.0);
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
}

// Called when the UIKeyboardWillHideNotification is sent
- (void)keyboardWillBeHidden:(NSNotification*)aNotification
{
    UIEdgeInsets contentInsets = UIEdgeInsetsZero;
    self.scrollView.contentInset = contentInsets;
    self.scrollView.scrollIndicatorInsets = contentInsets;
    
}
@end
