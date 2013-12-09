//
//  LoginController.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KKPasscodeViewController.h"

@class SignupViewController, EnterPasscodeView;

@interface LoginController : UITableViewController <KKPasscodeViewControllerDelegate> {
}

- (IBAction)signupDismissed:(SignupViewController *)sender;
- (IBAction)accountCreated:(UIStoryboardSegue *)segue;
- (IBAction)cancel:(UIStoryboardSegue *)segue;
- (IBAction)login:(id)sender;
- (IBAction)logout:(UIStoryboardSegue *)segue;

- (void)loadConnections;

@end
