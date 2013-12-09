//
//  TopAlignedLabel.m
//  TKD
//
//  Created by decuoi on 4/22/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import "TopAlignedLabel.h"

@implementation TopAlignedLabel

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    textRect.origin.y = bounds.origin.y;
    return textRect;
}

-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

#pragma mark -
#pragma mark Touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (self.topAlignedLabelDelegate != nil && [self.topAlignedLabelDelegate respondsToSelector:@selector(touchTopAlignedLabel:)]) {
        [self.topAlignedLabelDelegate touchTopAlignedLabel:self];
    }
}
@end
