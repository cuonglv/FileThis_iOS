//
//  FormLayoutView.m
//  FileThis
//
//  Created by Drew Wilson on 11/21/12.
//
//

#import "FormLayoutView.h"
#import <QuartzCore/QuartzCore.h>


@implementation FormLayoutView

- (void)commonInit {
    self.layer.cornerRadius = 10;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1;
    self.layer.borderColor = [UIColor lightGrayColor].CGColor;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
*/
//
//
static void drawLine(CGContextRef context, CGFloat startX, CGFloat startY, CGFloat endX, CGFloat endY) {

    CGContextMoveToPoint(context, startX, startY); //start at this point
    CGContextAddLineToPoint(context, endX, endY); //draw to this point
    CGContextStrokePath(context);
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGContextRef context    = UIGraphicsGetCurrentContext();
    UIGraphicsPushContext(context);
    CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
    CGContextSetLineWidth(context, 1.0);

    UIView *previousView = nil;
    CGFloat startX = 0;
    CGFloat endX = self.bounds.size.width;
    for (UIView *formView in self.formObjects) {
        if (previousView != nil) {
//            NSLog(@"origin.y %.0f, size.height=%.0f, frame.origin.y=%.0f, frame.origin.y=%.0f",    previousView.frame.origin.y,
//                  previousView.frame.size.height,
//                  formView.frame.origin.y, previousView.frame.origin.y);
            CGFloat bottom = previousView.frame.origin.y + previousView.frame.size.height;

//            CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
//            drawLine(context, self.frame.origin.x, bottom, self.frame.origin.x + self.frame.size.width, bottom);

            CGFloat gap = formView.frame.origin.y - bottom;
            CGFloat y = bottom + gap / 2;
            CGContextSetStrokeColorWithColor(context, [UIColor lightGrayColor].CGColor);
            drawLine(context, startX, y, endX, y);
//            CGContextMoveToPoint(context, self.frame.origin.x, y); //start at this point
//            CGContextAddLineToPoint(context, self.frame.size.width, y); //draw to this point
//            NSLog(@"drawing line from %.0f,%.0f to %.0f,%.0f", self.frame.origin.x, y, self.frame.size.width, y);
            // and now draw the Path!
//            CGContextStrokePath(context);
        }
        previousView = formView;
    }
    UIGraphicsPopContext();
}

@end
