//
//  ChangePasswordPopup.m
//  FileThis
//
//  Created by Cao Huu Loc on 1/20/14.
//
//

#import "ChangePasswordPopup.h"
#import "CommonLayout.h"
#import <QuartzCore/QuartzCore.h>
#import <Crashlytics/Crashlytics.h>

@interface ChangePasswordPopup ()

@end

@implementation ChangePasswordPopup

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
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
    // Do any additional setup after loading the view from its nib.
    self.navigationController.navigationBarHidden = YES;
    
    //Rounded rect border
    CGPoint center = self.contentView.center;
    center.x = self.view.center.x;
    self.contentView.center =  center;
    self.contentView.layer.borderWidth = 2;
    self.contentView.layer.borderColor = [UIColor grayColor].CGColor;
    self.contentView.layer.cornerRadius = 10;
    
    //Set font to controls
    [CommonLayout setFont:[CommonLayout getFont:14 isBold:NO] forClass:[UITextField class] inView:self.contentView];
    self.lblTitle.font = [CommonLayout getFont:17 isBold:NO];
    self.btnCancel.titleLabel.font = [CommonLayout getFont:15 isBold:NO];
    self.btnUpdate.titleLabel.font = [CommonLayout getFont:15 isBold:YES];
    
    //Set color to controls
    self.btnCancel.titleLabel.textColor = kTextOrangeColor;
    self.btnUpdate.titleLabel.textColor = kTextOrangeColor;
    
    //Set focus on first textfield
    [self.txtOldPassword becomeFirstResponder];
    
    //Textfield delegate
    self.txtOldPassword.delegate = self;
    self.txtNewPassword.delegate = self;
    self.txtConfirmPassword.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.txtOldPassword)
    {
        [self.txtNewPassword becomeFirstResponder];
    }
    else if (textField == self.txtNewPassword)
    {
        [self.txtConfirmPassword becomeFirstResponder];
    }
    else if (textField == self.txtConfirmPassword)
    {
        [self btnClickedUpdate:nil];
    }
    return YES;
}

#pragma mark - Button events
- (IBAction)btnClickedCancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^(){}];
    if ([self.delegate respondsToSelector:@selector(didCancelChangePassword)])
    {
        [self.delegate didCancelChangePassword];
    }
}

- (IBAction)btnClickedUpdate:(id)sender {
    //Check match between Password and Confirm
    NSString *newPass = [self.txtNewPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *confirmPass = [self.txtConfirmPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([newPass compare:confirmPass] != NSOrderedSame)
    {
        [CommonLayout showAlertMessageWithTitle:nil content:NSLocalizedString(@"ID_PASSWORD_NOT_MATCH",@"")  delegate:nil cancelButtonTitle:@"OK" otherButtonTitle:nil];
        return;
    }
    
    //Dismiss GUI, call callback to update password
    [self dismissViewControllerAnimated:YES completion:^(){
        if (self.delegate)
        {
            NSString *oldPass = [self.txtOldPassword.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            [self.delegate didChooseChangePassword:oldPass withNewPassword:newPass];
        }
    }];
}

@end
