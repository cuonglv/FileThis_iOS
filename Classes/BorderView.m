//
//  BorderView.m
//  TKD
//
//  Created by decuoi on 6/22/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import "BorderView.h"


@implementation BorderView
@synthesize borderWidths, borderColor;

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        borderWidths = OffsetMake(0, 0, 0, 0);
        self.borderColor = [UIColor clearColor];
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame borderColor:(UIColor*)bordercolor borderWidths:(Offset)borderwidths superView:(UIView*)superView {
    if (self = [super initWithFrame:frame]) {
        borderWidths = borderwidths;
        self.borderColor = bordercolor;
        self.backgroundColor = [UIColor clearColor];
        [superView addSubview:self];
    }
    return self;
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
    
    //CGContextDrawPath(context, kCGPathFill);
}


@end
