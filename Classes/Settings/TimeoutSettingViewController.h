//
//  TimeoutSettingViewController.h
//  FileThis
//
//  Created by Drew Wilson on 1/7/13.
//
//

#import <UIKit/UIKit.h>
#import "FTAccountSettings.h"

@interface TimeoutSettingViewController : UITableViewController

@property FTAccountSettings *settings;

+ (NSString *)titleForTimeout:(NSInteger)timeoutInMinutes;

@end
