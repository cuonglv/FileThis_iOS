//
//  LoadingView.h
//  LoadingView
//
//  Created by Matt Gallagher on 12/04/09.
//  Copyright Matt Gallagher 2009. All rights reserved.
// 
//  Permission is given to use this source code file, free of charge, in any
//  project, commercial or otherwise, entirely at your risk, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in compiled projects is
//  appreciated but not required.
//

#import <UIKit/UIKit.h>
#import "ThreadObj.h"

@interface LoadingView : UIView <UIAlertViewDelegate>

@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) UIImageView *imgLoading;
@property (nonatomic, strong) UILabel *lblMessage;
@property (nonatomic, strong) id<ThreadProtocol> threadObj;

- (void)startLoadingInView:(UIView *)aSuperview;
- (void)startLoadingInView:(UIView *)aSuperview frame:(CGRect)frame;
- (void)startLoadingInView:(UIView *)aSuperview message:(NSString*)message;
- (void)startLoadingInView:(UIView *)aSuperview frame:(CGRect)frame message:(NSString *)message;
- (void)stopLoading;

+ (LoadingView*)currentLoadingView;
+ (void)setCurrentLoadingView:(LoadingView*)val;
+ (UIView*)currentLoadingViewContainer;
+ (void)setCurrentLoadingViewContainer:(UIView*)val;
+ (void)startCurrentLoadingView:(NSString*)message;
+ (void)stopCurrentLoadingView;
@end
