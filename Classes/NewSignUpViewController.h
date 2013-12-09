//
//  NewSignUpViewController.h
//  FileThis
//
//  Created by Cuong Le on 11/14/13.
//
//

#import <UIKit/UIKit.h>

@interface NewSignUpViewController : UIViewController
@property (weak, readonly) NSString *firstName;
@property (weak, readonly) NSString *lastName;
@property (weak, readonly) NSString *email;
@property (weak, readonly) NSString *password;
@property (weak, readonly) NSString *confirmPassword;
@end
