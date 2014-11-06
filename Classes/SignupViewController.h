//
//  SignupViewController.h
//  FileThis
//
//  Created by Drew Wilson on 11/13/12.
//
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UITableViewController<UITextFieldDelegate>

@property (weak, readonly) NSString *firstName;
@property (weak, readonly) NSString *lastName;
@property (weak, readonly) NSString *email;
@property (weak, readonly) NSString *password;
@property (weak, readonly) NSString *confirmPassword;

@end
