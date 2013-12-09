//
//  ConnectionSettingsViewController.h
//  FileThis
//
//  Created by Drew Wilson on 1/22/13.
//
//

#import <UIKit/UIKit.h>
@class FTConnection;

@interface ConnectionSettingsViewController : UITableViewController

@property FTConnection *connection;

- (void)save;

@end
