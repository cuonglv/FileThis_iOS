//
//  NewLoginViewController.h
//  FileThis
//
//  Created by Cuong Le on 11/14/13.
//
//

#import <UIKit/UIKit.h>

@class SignupViewController, EnterPasscodeView;

@interface NewLoginViewController : UIViewController {
}

+ (void)setLastSignedUpEmail:(NSString*)val;
+ (void)setLastSignedUpPassword:(NSString*)val;

- (IBAction)signupDismissed:(SignupViewController *)sender;
- (IBAction)accountCreated:(UIStoryboardSegue *)segue;
- (IBAction)cancel:(UIStoryboardSegue *)segue;
- (IBAction)login:(id)sender;

@end
