//
//  Layout.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "Layout.h"
#import "MyControlView.h"

@implementation Layout

#pragma mark CGRect
+ (CGRect)CGRectResize:(CGRect)rect newWidth:(float)newWidth newHeight:(float)newHeight {
    return CGRectMake(rect.origin.x, rect.origin.y, newWidth, newHeight);
}

+ (CGRect)CGRectResize:(CGRect)rect newWidth:(float)newWidth {
    return CGRectMake(rect.origin.x, rect.origin.y, newWidth, rect.size.height);
}

+ (CGRect)CGRectResize:(CGRect)rect newHeight:(float)newHeight {
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, newHeight);
}


+ (CGRect)CGRectIncreaseSize:(CGRect)rect dWidth:(float)dWidth dHeight:(float)dHeight {
    return CGRectMake(rect.origin.x, rect.origin.y, rect.size.width + dWidth, rect.size.height + dHeight);
}

+ (CGRect)CGRectMoveTo:(CGRect)rect newX:(float)x newY:(float)y {
    return CGRectMake(x, y, rect.size.width, rect.size.height);
}

+ (CGRect)CGRectMoveBy:(CGRect)rect dx:(float)dx dy:(float)dy {
    return CGRectMake(rect.origin.x + dx, rect.origin.y + dy, rect.size.width, rect.size.height);
}

+ (CGRect)CGRectMoveToRightSide:(CGRect)rect {
    return CGRectMake(rect.origin.x + rect.size.width, rect.origin.y, rect.size.width, rect.size.height);
}

#pragma mark Set Font & Size
/*
+ (void)setFont:(CGFloat)fontSize forControls:(NSArray *)controls {
    for (NSObject *control in controls) {
        [control performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:fontSize]];
    }
}

+ (void)setFontItalic:(CGFloat)fontSize forControls:(NSArray *)controls {
    for (NSObject *control in controls) {
        [control performSelector:@selector(setFont:) withObject:[UIFont italicSystemFontOfSize:fontSize]];
    }
}

+ (void)setBigBoldFont:(NSArray *)controls {
    for (NSObject *control in controls) {
        [control performSelector:@selector(setFont:) withObject:[UIFont boldSystemFontOfSize:kBigFontSize]];
    }
}

+ (void)setBigFont:(NSArray *)controls {
    for (NSObject *control in controls) {
        [control performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:kBigFontSize]];
    }
}

+ (void)setSmallFont:(NSArray *)controls {
    for (NSObject *control in controls) {
        [control performSelector:@selector(setFont:) withObject:[UIFont systemFontOfSize:kSmallFontSize]];
    }
}

+ (void)setBigFontItalic:(NSArray *)controls {
    for (NSObject *control in controls) {
        [control performSelector:@selector(setFont:) withObject:[UIFont italicSystemFontOfSize:kBigFontSize]];
    }
}

+ (void)setSmallFontItalic:(NSArray *)controls {
    for (NSObject *control in controls) {
        [control performSelector:@selector(setFont:) withObject:[UIFont italicSystemFontOfSize:kSmallFontSize]];
    }
}

+ (void)sizeToFit:(NSArray *)views {
    for (UIView *view in views) {
        [view sizeToFit];
    }
}

+ (void)setColor:(NSArray *)controls textColor:(UIColor *)textColor bgColor:(UIColor *)bgColor {
    for (NSObject *control in controls) {
        [control performSelector:@selector(setTextColor:) withObject:textColor];
        [control performSelector:@selector(setBackgroundColor:) withObject:bgColor];
    }    
}*/

#pragma mark Arrange Control

+ (void)arrangeVerticalControls:(CGFloat)verticalSpacing forControls:(NSArray *)views {
    for (int i = 1, count = [views count]; i < count; i++) {
        UIView *previousControl = views[i-1];
        UIView *control = views[i];
        control.frame = CGRectMake(control.frame.origin.x, previousControl.frame.origin.y + previousControl.frame.size.height + verticalSpacing, control.frame.size.width, control.frame.size.height);
    }
}

+ (void)arrangeVerticalControlsWithScale:(CGFloat)verticalSpacing forControls:(NSArray *)views verticalSpacingScales:(float[])vScales {
    for (int i = 1, count = [views count]; i < count; i++) {
        UIView *previousControl = views[i-1];
        UIView *control = views[i];
        control.frame = CGRectMake(control.frame.origin.x, previousControl.frame.origin.y + previousControl.frame.size.height + verticalSpacing * vScales[i-1], control.frame.size.width, control.frame.size.height);
    }
}

//same as previous, but change frame.origin.x
+ (void)alignLeftControls:(CGFloat)verticalSpacing forControls:(NSArray *)views {
    for (int i = 1, count = [views count]; i < count; i++) {
        UIView *previousControl = views[i-1];
        UIView *control = views[i];
        control.frame = CGRectMake(previousControl.frame.origin.x, previousControl.frame.origin.y + previousControl.frame.size.height + verticalSpacing, control.frame.size.width, control.frame.size.height);
    }
}

//same as previous, but change frame.origin.x
+ (void)arrangeControlsInLine:(CGFloat)horizontalSpacing forControls:(NSArray *)views {
    for (int i = 1, count = [views count]; i < count; i++) {
        UIView *previousControl = views[i-1];
        UIView *control = views[i];
        control.frame = CGRectMake(previousControl.frame.origin.x + previousControl.frame.size.width + horizontalSpacing, previousControl.frame.origin.y, control.frame.size.width, control.frame.size.height);
    }
}

+ (void)setVisibleControls:(BOOL)visible forControls:(NSArray *)views {
    for (UIView *view in views) {
        view.hidden = !visible;
        if ([view isKindOfClass:[MyTextView class]]) {
            MyTextView *myTextView = (MyTextView *)view;
            if (myTextView.backgroundImageView)
                myTextView.backgroundImageView.hidden = !visible;
        }
    }
}

+ (void)moveControl:(UIView *)view toX:(CGFloat)x toY:(CGFloat)y {
    view.frame = CGRectMake(x, y, view.frame.size.width, view.frame.size.height);
    if ([view isKindOfClass:[MyTextView class]]) {
        MyTextView *myTextView = (MyTextView *)view;
        if (myTextView.backgroundImageView)
            myTextView.backgroundImageView.frame = myTextView.frame;
    }
}

+ (void)moveControlGroup:(NSArray *)views toX:(CGFloat)x toY:(CGFloat)y {
    //the first control is moved, other controls moved collerativly
    UIView *firstView = views[0];
    float dx = firstView.frame.origin.x - x;
    float dy = firstView.frame.origin.y - y;
    for (UIView *view in views) {
        [self moveControl:view toX:(view.frame.origin.x - dx) toY:(view.frame.origin.y - dy)];
    }
}

+ (void)saveStableOriginForControls:(NSArray *)views {
    for (NSObject *obj in views) {
        [obj performSelector:@selector(saveStableOrigin)];
    }
}

+ (void)moveControlsToStableOrigin:(NSArray *)views {
    for (NSObject *obj in views) {
        [obj performSelector:@selector(moveToStableOrigin)];
    }
}

+ (BOOL)isPointOutsideControl:(CGPoint)point forControl:(UIView *)view {
    return (point.x > view.frame.origin.x + view.frame.size.width) || (point.x < view.frame.origin.x) || (point.y > view.frame.origin.y + view.frame.size.height) || (point.y < view.frame.origin.y);
}

+ (void)moveControl:(UIView*)view toCenterOfControl:(UIView*)view2 {
    view.frame = CGRectMake(view2.frame.origin.x + (view2.frame.size.width - view.frame.size.width)/2, view2.frame.origin.y + (view2.frame.size.height-view.frame.size.height)/2, view.frame.size.width, view.frame.size.height);
}

#pragma mark Alert
+ (void)alertInfo:(NSString *)content delegate:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Info" message:content delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (void)alertWarning:(NSString *)content delegate:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning" message:content delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

+ (void)alertError:(NSString *)content delegate:(id)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"  message:content delegate:delegate cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

#pragma mark Create Controls
+ (void)addSubViews:(NSArray *)subviews toView:(UIView *)view {
    for (UIView *subview in subviews) {
        [view addSubview:subview];
    }
}

+ (id)labelWithFrame:(CGRect)frame text:(NSString*)text font:(UIFont*)font textColor:(UIColor*)textColor backColor:(UIColor*)backColor {
    UILabel *ret = [[UILabel alloc] initWithFrame:frame];
    ret.text = text;
    ret.font = font;
    ret.textColor = textColor;
    ret.backgroundColor = backColor;
    return ret;
}
@end
