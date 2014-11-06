//
//  LoadingView.m
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

#import "LoadingView.h"
#import <QuartzCore/QuartzCore.h>
#import "UIView+ExtLayout.h"
#import "Constants.h"
#import "CommonLayout.h"
#import "LoadingViewAlertHandler.h"

#define kLoadingViewMessage_LoadingData     NSLocalizedString(@"ID_LOADING_DATA", @"")
#define kLoadingViewMessage_SavingData      NSLocalizedString(@"ID_SAVING_DATA", @"")

#define kLoadingView_AlertTag_ConfirmStopLoadingData    1

@implementation LoadingView

- (id)init {
    if (self = [super init]) {
        self.overlayView = [[UIView alloc] init];
        [self addSubview:self.overlayView];
        [self.overlayView setAlpha:0.9];
        [self.overlayView setBackgroundColor:kBlackColor];
        self.overlayView.layer.cornerRadius = 6;
        
        self.lblMessage = [[UILabel alloc] init];
        [self addSubview:self.lblMessage];
        [self.lblMessage setTextAlignment:NSTextAlignmentCenter];
        [self.lblMessage setTextColor:kWhiteColor];
        [self.lblMessage setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeXNormal]];
        
        self.imgLoading = [[UIImageView alloc] init];
        self.imgLoading.animationImages = [NSArray arrayWithObjects: [UIImage imageNamed:@"blank.png"],
                                             [UIImage imageNamed:@"animate_logo1.png"],
                                             [UIImage imageNamed:@"animate_logo2.png"],
                                             [UIImage imageNamed:@"logo.png"],
                                             nil];
        self.imgLoading.animationDuration = 1.0f;
        self.imgLoading.animationRepeatCount = 0;
        [self.imgLoading startAnimating];
        [self addSubview:self.imgLoading];
        [self.imgLoading setFrame:CGRectMake(0, 0, 72, 95)];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.overlayView setFrame:CGRectInset(self.bounds,4,4)];
    [self.imgLoading setCenter:self.overlayView.center];
    [self.lblMessage setFrame:[self.imgLoading rectAtBottom:10 width:self.frame.size.width height:30]];
}

- (void)startLoadingInView:(UIView *)aSuperview {
    [self startLoadingInView:aSuperview message:NSLocalizedString(@"ID_LOADING_DATA", @"")];
}

- (void)startLoadingInView:(UIView *)aSuperview frame:(CGRect)frame {
    [self startLoadingInView:aSuperview frame:frame message:NSLocalizedString(@"ID_LOADING_DATA", @"")];
}

- (void)startLoadingInView:(UIView *)aSuperview message:(NSString *)message {
    [self startLoadingInView:aSuperview frame:CGRectMake(0, 0, aSuperview.frame.size.width, aSuperview.frame.size.height) message:message];
}

- (void)startLoadingInView:(UIView *)aSuperview frame:(CGRect)frame message:(NSString *)message {
    //if ([aSuperview.subviews containsObject:self]) return; 
    [aSuperview addSubview:self];
	[self setFrame:frame];
    if(message)
        [self.lblMessage setText:message];
    
    [self setAlpha:1.0];
}

- (void)stopLoading {
    self.threadObj = nil;
    [UIView animateWithDuration:0.3 animations:^{
        [self setAlpha:0];
    } completion:^(BOOL finished) {
        [super removeFromSuperview];
    }];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.threadObj) {
        MyAlertView *alert = [[MyAlertView alloc] initWithTitle:NSLocalizedString(@"ID_CONFIRM", @"") message:NSLocalizedString(@"ID_CONFIRM_STOP_LOADING_DATA", @"") delegate:[LoadingViewAlertHandler getInstance] cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitles:NSLocalizedString(@"ID_CANCEL", @""), nil];
        alert.data = self;
        [alert show];
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kLoadingView_AlertTag_ConfirmStopLoadingData) {
        if (buttonIndex == 0) {
            @synchronized (self) {
                if ([self.threadObj conformsToProtocol:@protocol(ThreadProtocol)]) {
                    if ([self.threadObj isExecuting]) {
                        [self.threadObj cancel];
                        [self stopLoading];
                    }
                }
            }
        }
    }
}

#pragma mark - static

static LoadingView *currentLoadingView_ = nil;
static UIView *currentLoadingViewContainer_ = nil;

+ (LoadingView*)currentLoadingView {
    return currentLoadingView_;
}

+ (void)setCurrentLoadingView:(LoadingView*)val {
    currentLoadingView_ = val;
}

+ (UIView*)currentLoadingViewContainer {
    return currentLoadingViewContainer_;
}

+ (void)setCurrentLoadingViewContainer:(UIView*)val {
    currentLoadingViewContainer_ = val;
}

+ (void)startCurrentLoadingView:(NSString*)message {
    if (currentLoadingView_ && currentLoadingViewContainer_) {
        [currentLoadingView_ startLoadingInView:currentLoadingViewContainer_ message:message];
    }
}

+ (void)stopCurrentLoadingView {
    if (currentLoadingView_) {
        [currentLoadingView_ stopLoading];
    }
}

@end
