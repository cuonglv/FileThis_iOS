//
//  UIView+Layout.m
//  OnMat
//
//  Created by decuoi on 11/10/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import "UIView+Ext.h"


@implementation UIView (Ext)

#pragma mark -
#pragma mark get left,right,top,bottom
- (float)left {
    return self.frame.origin.x;
}

- (float)right {
    return self.frame.origin.x + self.frame.size.width;
}

- (float)top {
    return self.frame.origin.y;
}

- (float)bottom {
    return self.frame.origin.y + self.frame.size.height;
}

#pragma mark -
#pragma mark set left,right,top,bottom
- (void)setLeft:(float)left {
    self.frame = CGRectMake(left, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setLeft:(float)left top:(float)top {
    self.frame = CGRectMake(left, top, self.frame.size.width, self.frame.size.height);
}

- (void)setLeft:(float)left right:(float)right {
    self.frame = CGRectMake(left, self.frame.origin.y, right-left, self.frame.size.height);
}

- (void)setRight:(float)right {
    self.frame = CGRectMake(right - self.frame.size.width, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setRight:(float)right top:(float)top {
    self.frame = CGRectMake(right - self.frame.size.width, top, self.frame.size.width, self.frame.size.height);
}

- (void)setRight:(float)right bottom:(float)bottom {
    self.frame = CGRectMake(right - self.frame.size.width, bottom - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)setRightWithoutChangingLeft:(float)right {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, right - self.frame.origin.x, self.frame.size.height);
}

- (void)setTop:(float)top {
    self.frame = CGRectMake(self.frame.origin.x, top, self.frame.size.width, self.frame.size.height);
}
- (void)setTop:(float)top height:(float)h {
    self.frame = CGRectMake(self.frame.origin.x, top, self.frame.size.width, h);
}

- (void)setTop:(float)top bottom:(float)bottom {
    self.frame = CGRectMake(self.frame.origin.x, top, self.frame.size.width, bottom - top);
}

- (void)setBottom:(float)bottom {
    self.frame = CGRectMake(self.frame.origin.x, bottom - self.frame.size.height, self.frame.size.width, self.frame.size.height);
}

- (void)setBottomWithoutChangingTop:(float)bottom {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, bottom - self.frame.origin.y);
}

- (void)setOrigin:(CGPoint)origin {
    self.frame = CGRectMake(origin.x, origin.y, self.frame.size.width, self.frame.size.height);
}

- (void)setRightWithoutChangingLeft:(float)right bottomWithoutChangingTop:(float)bottom {
    float newWidth = right - self.frame.origin.x;
    if (newWidth < 0)
        newWidth = 0;
    
    float newHeight = bottom - self.frame.origin.y;
    if (newHeight < 0)
        newHeight = 0;
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, newHeight);
}

#pragma mark -
#pragma mark move left,right,top,bottom
- (void)moveToLeftOfView:(UIView*)vw offset:(float)offset {
    self.center = CGPointMake(vw.frame.origin.x - offset - self.frame.size.width/2, vw.center.y);
}

- (void)moveToRightOfView:(UIView*)vw offset:(float)offset {
    self.center = CGPointMake(vw.frame.origin.x + vw.frame.size.width + offset + self.frame.size.width/2, vw.center.y);
}

- (void)moveToTopOfView:(UIView*)vw offset:(float)offset {
    self.center = CGPointMake(vw.center.x, vw.frame.origin.y - offset - self.frame.size.height/2);
}

- (void)moveToBottomOfView:(UIView*)vw offset:(float)offset {
    self.center = CGPointMake(vw.center.x, vw.frame.origin.y + vw.frame.size.height + offset + self.frame.size.height/2);
}

- (void)moveToHorizontalCenterOfSuperView {
    self.center = CGPointMake(self.superview.frame.size.width/2,self.center.y);
}

- (void)moveToCenterOfSuperView {
    self.center = CGPointMake(self.superview.frame.size.width/2,self.superview.frame.size.height/2);
}

#pragma mark -
#pragma mark get rect at left,right,top,bottom
- (CGRect)rectAtLeft:(float)offset width:(float)width {
    return CGRectMake(self.frame.origin.x - offset - width, self.frame.origin.y, width, self.frame.size.height);
}

- (CGRect)rectAtLeft:(float)offset width:(float)width height:(float)height {
    return CGRectMake(self.frame.origin.x - offset - width, self.center.y - height/2, width, height);
}

- (CGRect)rectAtRightOfLeftSide:(float)offsetLeftTopBottom width:(float)width {
    return CGRectMake(self.frame.origin.x + offsetLeftTopBottom, self.frame.origin.y + offsetLeftTopBottom, width, self.frame.size.height - 2 * offsetLeftTopBottom);
}

- (CGRect)rectAtRight:(float)offset width:(float)width {
    return CGRectMake(self.frame.origin.x + self.frame.size.width + offset, self.frame.origin.y, width, self.frame.size.height);
}

- (CGRect)rectAtRight:(float)offset width:(float)width height:(float)height {
    return CGRectMake(self.frame.origin.x + self.frame.size.width + offset, self.center.y - height/2, width, height);
}

- (CGRect)rectAtLeftOfRightSide:(float)offset width:(float)width height:(float)height {
    return CGRectMake(self.frame.origin.x + self.frame.size.width - offset - width, self.center.y - height/2, width, height);
}

- (CGRect)innerRectAtRight:(float)offset width:(float)width {
    return CGRectMake(self.frame.origin.x + self.frame.size.width - offset - width, self.frame.origin.y, width, self.frame.size.height);
}

- (CGRect)innerRectAtRight:(float)offset width:(float)width height:(float)height {
    return CGRectMake(self.frame.origin.x + self.frame.size.width - offset - width, self.center.y - height/2, width, height);
}

- (CGRect)rectAtTop:(float)offset height:(float)height {
    return CGRectMake(self.frame.origin.x, self.frame.origin.y - offset - height, self.frame.size.width, height);
}

- (CGRect)rectAtTop:(float)offset width:(float)width height:(float)height {
    return CGRectMake(self.center.x - width/2, self.frame.origin.y - offset - height, width, height);
}

- (CGRect)rectAtBottom:(float)offset height:(float)height {
    return CGRectMake(self.frame.origin.x, self.frame.origin.y + self.frame.size.height + offset, self.frame.size.width, height);
}

- (CGRect)rectAtBottom:(float)offset width:(float)width height:(float)height {
    return CGRectMake(self.center.x - width/2, self.frame.origin.y + self.frame.size.height + offset, width, height);
}

- (CGRect)rectAtMiddleOffsetLeft:(float)offsetLeft offsetRight:(float)offsetRight offsetTop:(float)offsetTop offsetBottom:(float)offsetBottom {
    return CGRectMake(self.frame.origin.x + offsetLeft, self.frame.origin.y + offsetTop, self.frame.size.width - offsetLeft - offsetRight, self.frame.size.height - offsetTop - offsetBottom);
}

- (CGRect)innerRectOffsetLeft:(float)offsetLeft offsetRight:(float)offsetRight offsetTop:(float)offsetTop offsetBottom:(float)offsetBottom {
    return CGRectMake(offsetLeft, offsetTop, self.frame.size.width - offsetLeft - offsetRight, self.frame.size.height - offsetTop - offsetBottom);
}

- (CGRect)innerRectOffsetLeft:(float)offsetLeft offsetTop:(float)offsetTop offsetBottom:(float)offsetBottom width:(float)width {
    return CGRectMake(offsetLeft, offsetTop, width, self.frame.size.height - offsetTop - offsetBottom);
}

- (CGRect)innerRectOffsetRight:(float)offsetRight offsetTop:(float)offsetTop offsetBottom:(float)offsetBottom width:(float)width {
    return CGRectMake(self.frame.size.width - offsetRight - width, offsetTop, width, self.frame.size.height - offsetTop - offsetBottom);
}

- (CGPoint)bottomRightPoint {
    return CGPointMake([self right],[self bottom]);
}

#pragma mark -
#pragma mark resize
- (void)setWidth:(float)newWidth {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, self.frame.size.height);
}

- (void)setHeight:(float)newHeight {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newHeight);
}

- (void)setWidth:(float)newWidth height:(float)newHeight {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, newWidth, newHeight);
}

- (void)setLeft:(float)left width:(float)newWidth {
    self.frame = CGRectMake(left, self.frame.origin.y, newWidth, self.frame.size.height);
}

- (void)setLeft:(float)left width:(float)newWidth height:(float)newHeight {
    self.frame = CGRectMake(left, self.frame.origin.y, newWidth, newHeight);
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (float)autoWidth {
    float w;
    if ([self isKindOfClass:[UIButton class]]) {
        UIButton *button = (UIButton*)self;
        w = [[button titleForState:UIControlStateNormal] sizeWithFont:button.titleLabel.font].width + 8;
    } else {
        w = [self sizeThatFits:CGSizeZero].width;
    }
    [self setWidth:w];
    return w;
}
#pragma GCC diagnostic pop

- (float)autoWidthAlignAtRight {
    float w = [self sizeThatFits:CGSizeZero].width;
    self.frame = CGRectMake(self.frame.origin.x+self.frame.size.width-w,self.frame.origin.y,w,self.frame.size.height);
    return w;
}

- (void)autoHeight {
    [self setHeight:[self sizeThatFits:CGSizeMake(self.frame.size.width, 2000)].height];
}

- (BOOL)fitWidth:(float)maxWidth {
    float fitWidth = [self sizeThatFits:CGSizeZero].width;
    if (fitWidth < maxWidth) {
        [self setWidth:fitWidth];
        return YES;
    } else {
        [self setWidth:maxWidth];
        return NO;
    }
}

- (BOOL)fitWidthWithMaxRight:(float)maxRight {
    CGSize fitSize = [self sizeThatFits:CGSizeZero];
    if (fitSize.width > maxRight - self.frame.origin.x) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, maxRight - self.frame.origin.x, fitSize.height);
        return NO;
    } else {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, fitSize.width, fitSize.height);
        return YES;
    }
}

- (void)changeWidthForRight:(float)right {
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, right - self.frame.origin.x, self.frame.size.height);
}

#pragma mark -
#pragma mark SubViews
- (void)removeAllSubViews {
    for (int i = [self.subviews count] - 1; i >= 0; i--) {
        UIView *vw = [self.subviews objectAtIndex:i];
        [vw removeFromSuperview];
    }
}

- (void)relayout {
}

- (BOOL)containsTouch:(UITouch*)touch {
    CGPoint p = [touch locationInView:self.superview];
    if (p.x < self.frame.origin.x)
        return NO;
    
    if (p.x > self.frame.origin.x + self.frame.size.width)
        return NO;
    
    if (p.y < self.frame.origin.y)
        return NO;
    
    if (p.y > self.frame.origin.y + self.frame.size.height)
        return NO;
    
    return YES;
}
@end
