//
//  SettingsViewController.h
//  FileThis
//
//  Created by Drew Wilson on 1/7/13.
//

#import <UIKit/UIKit.h>

#import "FTAccountSettings.h"

@interface SettingsViewController : UITableViewController

- (IBAction)destinationConfigured:(UIStoryboardSegue *)segue;

- (void)save;

@end
