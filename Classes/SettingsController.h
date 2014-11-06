//
//  SettingsController.h
//  FTMobile
//
//  Created by decuoi on 12/17/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAnimatedView.h"
#import "KeyValueCell.h"

@interface SettingsController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *myTableView;
    NSString *sClientEmail, *sAccountType, *sSpaceUsed, *sUploadEmailAddress;
    MyAnimatedView *vwAnimated;
    BOOL blnIsFirstLoad;
}
- (void)loadData;
@end
