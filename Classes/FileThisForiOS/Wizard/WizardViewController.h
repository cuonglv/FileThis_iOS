//
//  WizardViewController.h
//  FileThis
//
//  Created by Cuong Le on 3/8/14.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"

@interface WizardViewController : BaseViewController
@property (nonatomic, assign) int wizardIndex;
@property (nonatomic, strong) UIButton *gotItButton;
@property (nonatomic, assign) UIViewController *initialViewControllerBeforeWizard;
- (id)initWithWizardIndex:(int)wizardIndex initialViewControllerBeforeWizard:(UIViewController*)initialViewControllerBeforeWizard;
@end
