//
//  Layout.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Layout : NSObject {

}

#pragma mark CGRect
+ (CGRect)CGRectResize:(CGRect)rect newWidth:(float)newWidth;
+ (CGRect)CGRectResize:(CGRect)rect newWidth:(float)newWidth newHeight:(float)newHeight;
+ (CGRect)CGRectResize:(CGRect)rect newHeight:(float)newHeight;
+ (CGRect)CGRectIncreaseSize:(CGRect)rect dWidth:(float)dWidth dHeight:(float)dHeight;
+ (CGRect)CGRectMoveTo:(CGRect)rect newX:(float)x newY:(float)y;
+ (CGRect)CGRectMoveBy:(CGRect)rect dx:(float)dx dy:(float)dy;
+ (CGRect)CGRectMoveToRightSide:(CGRect)rect;

/*
#pragma mark Set Font & Size
+ (void)setBigBoldFont:(NSArray *)controls;
+ (void)setFont:(CGFloat)fontSize forControls:(NSArray *)controls;
+ (void)setFontItalic:(CGFloat)fontSize forControls:(NSArray *)controls;
+ (void)setBigFont:(NSArray *)controls;
+ (void)setSmallFont:(NSArray *)controls;
+ (void)setBigFontItalic:(NSArray *)controls;
+ (void)setSmallFontItalic:(NSArray *)controls;
+ (void)sizeToFit:(NSArray *)views;
+ (void)setColor:(NSArray *)controls textColor:(UIColor *)textColor bgColor:(UIColor *)bgColor;
*/
#pragma mark Arrange Control
+ (void)arrangeVerticalControls:(CGFloat)verticalSpacing forControls:(NSArray *)views;
+ (void)arrangeVerticalControlsWithScale:(CGFloat)verticalSpacing forControls:(NSArray *)views verticalSpacingScales:(float[])vScales;
+ (void)alignLeftControls:(CGFloat)verticalSpacing forControls:(NSArray *)views;
+ (void)arrangeControlsInLine:(CGFloat)horizontalSpacing forControls:(NSArray *)views;

+ (void)setVisibleControls:(BOOL)visible forControls:(NSArray *)views;
+ (void)moveControl:(UIView *)view toX:(CGFloat)x toY:(CGFloat)y;
+ (void)moveControlGroup:(NSArray *)views toX:(CGFloat)x toY:(CGFloat)y;
+ (void)saveStableOriginForControls:(NSArray *)views;
+ (void)moveControlsToStableOrigin:(NSArray *)views;
+ (BOOL)isPointOutsideControl:(CGPoint)point forControl:(UIView *)view;
+ (void)moveControl:(UIView*)view toCenterOfControl:(UIView*)view2;

#pragma mark Alert
+ (void)alertInfo:(NSString *)content delegate:(id)delegate;
+ (void)alertWarning:(NSString *)content delegate:(id)delegate;
+ (void)alertError:(NSString *)content delegate:(id)delegate;

+ (void)addSubViews:(NSArray *)subviews toView:(UIView *)view;

+ (id)labelWithFrame:(CGRect)frame text:(NSString*)text font:(UIFont*)font textColor:(UIColor*)textColor backColor:(UIColor*)backColor;
@end
