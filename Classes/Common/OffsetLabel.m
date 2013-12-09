//
//  OffsetLabel.m
//  TKD
//
//  Created by decuoi on 6/22/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import "OffsetLabel.h"


@implementation OffsetLabel
@synthesize offset;
@synthesize borderWidths, borderColor;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        offset = OffsetZero();
        borderWidths = OffsetZero();
        borderColor = nil;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame offset:(Offset)offsetValue borderColor:(UIColor*)bordercolor borderWidths:(Offset)borderwidths superView:(UIView*)superView {
    self = [super initWithFrame:frame];
    if (self) {
        offset = offsetValue;
        borderWidths = borderwidths;
        borderColor = bordercolor;
        [superView addSubview:self];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame offset:(Offset)offsetValue superView:(UIView*)superView {
    return [self initWithFrame:frame offset:offsetValue borderColor:nil borderWidths:OffsetZero() superView:superView];
}

- (void)drawTextInRect:(CGRect)rect {
    CGRect newRect = CGRectMake(rect.origin.x + offset.left, rect.origin.y + offset.top, rect.size.width - offset.left - offset.right, rect.size.height - offset.top - offset.bottom);
    [super drawTextInRect:newRect];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    if (borderColor == nil)
        return;
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    //CGContextSetFillColorWithColor(context, [borderColor CGColor]);
    
    CGContextSetStrokeColorWithColor(context, [borderColor CGColor]);
    
    if (borderWidths.left > 0) {
        CGContextSetLineWidth(context, borderWidths.left);
        CGContextMoveToPoint(context, borderWidths.left / 2, 0);
        CGContextAddLineToPoint(context, borderWidths.left / 2, self.frame.size.height);
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
    
    if (borderWidths.right > 0) {
        CGContextBeginPath(context);
        CGContextSetLineWidth(context, borderWidths.right);
        CGContextMoveToPoint(context, self.frame.size.width-borderWidths.right/2, 0);
        CGContextAddLineToPoint(context, self.frame.size.width-borderWidths.right/2, self.frame.size.height);
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
    
    if (borderWidths.top > 0) {
        CGContextBeginPath(context);
        CGContextSetLineWidth(context, borderWidths.top);
        CGContextMoveToPoint(context, 0, borderWidths.top/2);
        CGContextAddLineToPoint(context, self.frame.size.width,borderWidths.top/2);
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
    
    if (borderWidths.bottom > 0) {
        CGContextBeginPath(context);
        CGContextSetLineWidth(context, borderWidths.bottom);
        CGContextMoveToPoint(context, 0, self.frame.size.height-borderWidths.bottom/2);
        CGContextAddLineToPoint(context, self.frame.size.width,self.frame.size.height-borderWidths.bottom/2);
        CGContextClosePath(context);
        CGContextStrokePath(context);
    }
}


@end
