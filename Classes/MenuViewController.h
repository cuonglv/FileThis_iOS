//
//  MenuViewController.h
//  FileThis
//
//  Created by Cuong Le on 12/10/13.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BorderView.h"
#import "MenuItem.h"
#import "MenuCell.h"
#import "MenuDelegate.h"
#import "PremiumBoxView.h"
#import "MyProgressView.h"

@protocol MenuViewControllerDelegate <NSObject>
- (void)menuViewControllerItemSelected:(MenuItem)menuItem animated:(BOOL)animated;
@end

@interface MenuViewController : BaseViewController <UITableViewDelegate, UITableViewDataSource, MyProgressViewDelegate>
@property (assign) id<MenuViewControllerDelegate, MenuDelegate> menuViewControllerDelegate;
@property (nonatomic, strong) NSMutableDictionary *dictMenuItems, *dictMenuIcons;
@property (nonatomic, strong) PremiumBoxView *premiumBoxView;

- (void)selectMenu:(MenuItem)menuItem animated:(BOOL)animated;
- (void)initMenuItems;

@end
