//
//  ConnectionCredentialsViewController.h
//  FileThis
//
//  Created by Drew Wilson on 11/5/12.
//
//

#import <UIKit/UIKit.h>
#import "FTInstitution.h"

@interface ConnectionCredentialsViewController : UIViewController

@property (weak, readonly) NSString *usernameText;
@property (weak, readonly) NSString *passwordText;
@property (strong, nonatomic) FTInstitution *institution;

- (void)setReceiver:(id) receiver withAction:(SEL)action;
- (void)setReceiver:(id) receiver withCancelAction:(SEL)action;

- (IBAction)connect:(id)sender;
- (IBAction)cancel:(id)sender;

@end
