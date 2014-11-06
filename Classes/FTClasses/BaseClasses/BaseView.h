//
//  BaseView.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+Style.h"
#import "Constants.h"
#import "UIView+ExtLayout.h"

@interface BaseView : UIView

- (void)initializeView;
- (void)setupViewForIdiom:(UIUserInterfaceIdiom)aIdiom;
- (void)reloadView;
- (void)relayout;
- (void)closeKeyboard;
- (void)makeEmpty;
- (void)resetView;
- (void)clearData;

@end
