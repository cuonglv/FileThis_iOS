//
//  NewSettingsViewController.h
//  FileThis
//
//  Created by Cuong Le on 12/13/13.
//
//

#import "MyDetailViewController.h"
#import "ChangePasswordPopup.h"

@interface NewSettingsViewController : MyDetailViewController <ChangePasswordPopupDelegate>
@property (nonatomic, strong) LoadingView *loadingView;

@end
