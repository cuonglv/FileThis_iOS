//
//  MyDetailViewController.h
//  FileThis
//
//  Created by Cuong Le on 12/10/13.
//
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "BorderView.h"
#import "CommonLayout.h"
#import "Constants.h"
#import "MenuDelegate.h"

#define kMyDetailViewController_BarTextColor [UIColor whiteColor]

@interface MyDetailViewController : BaseViewController

@property (assign) float titleLabelMarginLeft, titleLabelMarginRight;
@property (nonatomic, strong) BorderView *topBarView, *bottomBarView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *menuButton, *backButton;
@property (nonatomic, strong) NSMutableArray *leftBarButtons, *rightBarButtons, *bottomLeftBarButtons, *bottomRightBarButtons, *bottomCenterBarButtons;
@property (nonatomic, assign) id<MenuDelegate> myDetailViewControllerDelegate;
@property (assign) BOOL isLocking;
@property (assign) BOOL useBackButton;
@property (nonatomic, strong) UIButton *selectedBottomCenterBarButton;
@property (readonly, getter = selectedBottomCenterBarButtonIndex) int selectedBottomCenterBarButtonIndex;

#pragma mark - Overriden
- (BOOL)shouldUseBackButton;
- (float)heightForTopBar;
- (float)heightForBottomBar;
- (float)horizontalSpacingBetweenBottomCenterBarButtons;
- (float)horizontalSpacingBetweenTopRightBarButtons;
- (float)rightMarginTopBarButton;
- (UIFont*)smallFontForBottomBarButton;
- (UIFont*)fontForBarButton;

#pragma mark - MyFunc
- (UIButton*)addTopLeftTextBarButton:(NSString*)text width:(float)width target:(id)target selector:(SEL)selector;
- (UIButton*)addTopLeftTextBarButton:(NSString*)text target:(id)target selector:(SEL)selector;
- (UIButton*)addTopLeftImageBarButton:(UIImage*)image width:(float)width target:(id)target selector:(SEL)selector;
- (void)addTopLeftBarButton:(UIButton*)button;
- (UIButton*)addTopRightBarButton:(NSString*)text width:(float)width target:(id)target selector:(SEL)selector;
- (UIButton*)addTopRightBarButton:(NSString*)text target:(id)target selector:(SEL)selector;
- (UIButton*)addTopRightImageBarButton:(UIImage*)image width:(float)width target:(id)target selector:(SEL)selector;
- (UIButton*)addBottomLeftBarButton:(NSString*)text width:(float)width target:(id)target selector:(SEL)selector;
- (UIButton*)addBottomRightBarButton:(NSString*)text width:(float)width target:(id)target selector:(SEL)selector;
- (UIButton*)addBottomLeftBarButton:(NSString*)text image:(UIImage *)image target:(id)target selector:(SEL)selector;

- (UIButton*)addBottomCenterBarButton:(NSString*)text image:(UIImage*)image target:(id)target selector:(SEL)selector;
- (UIButton*)addBottomCenterBarButton:(NSString*)text image:(UIImage*)image target:(id)target selector:(SEL)selector width:(float)width;

- (void)setSelectedBottomCenterBarButton:(UIButton*)aButton;
- (void)setSelectedBottomCenterBarButtonIndex:(int)aButtonIndex;
- (void)handleBackButton;
- (void)setTopBarLocked:(BOOL)locked;
@end
