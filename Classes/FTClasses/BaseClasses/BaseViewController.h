//
//  BaseViewController.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ThreadManager.h"
#import "LoadingView.h"
#import "Constants.h"

@interface BaseViewController : UIViewController
{
    UIInterfaceOrientationMask currentOrientationMask;
    UIView *m_contentView;
    UIImageView *m_bgView;
}

@property ACTIONTYPE actionType;
@property (nonatomic, strong) UIButton *btnBack;
@property (nonatomic, strong) UIView *m_contentView;
@property (nonatomic, strong) UIImageView *m_bgView;
@property (nonatomic, assign) BOOL shouldRefreshUIOnBack;
@property (nonatomic, strong) LoadingView *loadingView;

- (void)initializeVariables;
- (void)initializeScreen;
- (void)initFooterView;
- (void)relayout;
- (void)stopAllTaskBeforeQuit;
- (void)reloadViewController;

- (BOOL)shouldHideNavigationBar;
- (BOOL)shouldHideToolBar;
- (BOOL)shouldHideFooterView;
- (BOOL)shouldRelayoutBeforeViewAppear;
- (BOOL)isLandscapeMode;
- (BOOL)shouldRelayoutBeforeRotation;

@end
