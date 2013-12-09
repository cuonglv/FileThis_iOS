//
//  UIView+Layout.h
//  OnMat
//
//  Created by decuoi on 11/10/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (Ext)

#pragma mark get left,right,top,bottom
- (float)left;
- (float)right;
- (float)top;
- (float)bottom;

#pragma mark set left,right,top,bottom
- (void)setLeft:(float)left;
- (void)setLeft:(float)left top:(float)top;
- (void)setLeft:(float)left right:(float)right;
- (void)setRight:(float)right;
- (void)setRight:(float)right top:(float)top;
- (void)setRight:(float)right bottom:(float)bottom;
- (void)setTop:(float)top;
- (void)setTop:(float)top height:(float)h;
- (void)setTop:(float)top bottom:(float)bottom;
- (void)setBottom:(float)bottom;
- (void)setOrigin:(CGPoint)origin;

#pragma mark move left,right,top,bottom
- (void)moveToLeftOfView:(UIView*)vw offset:(float)offset;
- (void)moveToRightOfView:(UIView*)vw offset:(float)offset;
- (void)moveToTopOfView:(UIView*)vw offset:(float)offset;
- (void)moveToBottomOfView:(UIView*)vw offset:(float)offset;
- (void)moveToHorizontalCenterOfSuperView;

#pragma mark get rect at left,right,top,bottom
- (CGRect)rectAtLeft:(float)offset width:(float)width;
- (CGRect)rectAtLeft:(float)offset width:(float)width height:(float)height;
- (CGRect)rectAtRightOfLeftSide:(float)offsetLeftTopBottom width:(float)width;

- (CGRect)rectAtRight:(float)offset width:(float)width;
- (CGRect)rectAtRight:(float)offset width:(float)width height:(float)height;
- (CGRect)rectAtLeftOfRightSide:(float)offset width:(float)width height:(float)height;

- (CGRect)innerRectAtRight:(float)offset width:(float)width;
- (CGRect)innerRectAtRight:(float)offset width:(float)width height:(float)height;

- (CGRect)rectAtTop:(float)offset height:(float)height;
- (CGRect)rectAtBottom:(float)offset height:(float)height;
- (CGRect)rectAtBottom:(float)offset width:(float)width height:(float)height;

- (CGRect)rectAtMiddleOffsetLeft:(float)offsetLeft offsetRight:(float)offsetRight offsetTop:(float)offsetTop offsetBottom:(float)offsetBottom;

- (CGRect)innerRectOffsetLeft:(float)offsetLeft offsetRight:(float)offsetRight offsetTop:(float)offsetTop offsetBottom:(float)offsetBottom;
- (CGRect)innerRectOffsetLeft:(float)offsetLeft offsetTop:(float)offsetTop offsetBottom:(float)offsetBottom width:(float)width;
- (CGRect)innerRectOffsetRight:(float)offsetRight offsetTop:(float)offsetTop offsetBottom:(float)offsetBottom width:(float)width;

- (CGPoint)bottomRightPoint;

#pragma mark resize
- (void)setWidth:(float)newWidth;
- (void)setHeight:(float)newHeight;
- (void)setWidth:(float)newWidth height:(float)newHeight;
- (void)setLeft:(float)left width:(float)newWidth;
- (void)setLeft:(float)left width:(float)newWidth height:(float)newHeight;
- (float)autoWidth;
- (float)autoWidthAlignAtRight;
- (void)autoHeight;
- (BOOL)fitWidth:(float)maxWidth;
- (BOOL)fitWidthWithMaxRight:(float)maxRight;
- (void)changeWidthForRight:(float)right;

#pragma mark SubViews
- (void)removeAllSubViews;
- (void)relayout;
@end
