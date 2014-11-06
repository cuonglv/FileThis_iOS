//
//  MyProgressView.m
//  FileThis
//
//  Created by Cuong Le on 1/16/14.
//
//

#import "MyProgressView.h"
#import "CommonLayout.h"
#import "FTMobileAppDelegate.h"

@interface MyProgressView()

@end

@implementation MyProgressView

- (id)initWithFrame:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor tintColor:(UIColor*)tintColor trackTintColor:(UIColor*)trackTintColor progressBarWidth:(float)progressBarWidth superView:(UIView*)superView {
    self = [self initWithFrame:frame font:font textColor:textColor tintColor:tintColor trackTintColor:trackTintColor progressBarWidth:progressBarWidth addDetailLabel:NO superView:superView];
    return self;
}

- (id)initWithFrame:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor tintColor:(UIColor*)tintColor trackTintColor:(UIColor*)trackTintColor progressBarWidth:(float)progressBarWidth addDetailLabel:(BOOL)addDetailLabel superView:(UIView*)superView {
    if (self = [super initWithFrame:frame]) {
        self.progressLabel = [CommonLayout createLabel:CGRectMake(-10, 0, self.frame.size.width+20, 40) font:font textColor:textColor backgroundColor:nil text:@"" superView:self];
        self.progressLabel.textAlignment = NSTextAlignmentCenter;
        
        self.progressView = [[UIProgressView alloc] initWithFrame:[self.progressLabel rectAtBottom:4 width:progressBarWidth height:6]];
        self.progressView.tintColor = tintColor; //Only iOS 7 device
        self.progressView.trackTintColor = trackTintColor;
        [self addSubview:self.progressView];
        
        CGRect rect;
        if (addDetailLabel) {
            rect = [self.progressLabel rectAtBottom:5 height:40];
            self.detailLabel = [CommonLayout createLabel:rect font:font textColor:textColor backgroundColor:nil text:NSLocalizedString(@"ID_USAGE_DETAIL", @"") superView:self];
            self.detailLabel.textAlignment = NSTextAlignmentCenter;
            [self addSubview:self.detailLabel];
            
            rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
            self.btnGo = [UIButton buttonWithType:UIButtonTypeCustom];
            self.btnGo.frame = rect;
            [self.btnGo addTarget:self action:@selector(clickedDetailButton:) forControlEvents:UIControlEventTouchUpInside];
            self.btnGo.backgroundColor = [UIColor clearColor];
            [self addSubview:self.btnGo];
        }
        
        [superView addSubview:self];
    }
    return self;
}

- (void)setProgressValue:(float)progressvalue text:(NSString*)text {
    self.progressView.progress = progressvalue;
    self.progressLabel.text = text;
}

#pragma mark - Button events
- (void)clickedDetailButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(progressViewClickedDetailButton)]) {
        [self.delegate progressViewClickedDetailButton];
    }
    FTMobileAppDelegate *app = (FTMobileAppDelegate*)[UIApplication sharedApplication].delegate;
    [app goToUssageView];
}

@end
