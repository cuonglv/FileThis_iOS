//
//  InviteFriendViewController.h
//  FileThis
//
//  Created by Cao Huu Loc on 6/4/14.
//
//

#import "MyDetailViewController.h"
#import "BorderTextField.h"
#import <MessageUI/MFMailComposeViewController.h>
#import "MyScrollView.h"

@interface InviteFriendViewController : MyDetailViewController <UITextFieldDelegate, UIAlertViewDelegate, MyScrollViewTouchEvent>

@property (weak, nonatomic) IBOutlet UILabel *lblTitle;
@property (weak, nonatomic) IBOutlet UILabel *lblDescription;

@property (weak, nonatomic) IBOutlet UIView *sendView;
@property (weak, nonatomic) IBOutlet UILabel *lblEmailTitle;
@property (weak, nonatomic) IBOutlet BorderTextField *txtEmail;
@property (weak, nonatomic) IBOutlet UIButton *btnSend;
@property (weak, nonatomic) IBOutlet UIView *lineImageView;
@property (weak, nonatomic) IBOutlet UILabel *lblLinkTitle;
@property (weak, nonatomic) IBOutlet UITextView *txtLink;
@property (weak, nonatomic) IBOutlet UIButton *btnCopyLink;

@end
