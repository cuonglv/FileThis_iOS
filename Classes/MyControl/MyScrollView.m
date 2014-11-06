//
//  MyScrollView.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/18/14.
//

#import "MyScrollView.h"

@implementation MyScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event
{
    if ([self.touchDelegate respondsToSelector:@selector(touchesEnded:withEvent:sender:)])
    {
        [self.touchDelegate touchesEnded:touches withEvent:event sender:self];
    }
}

@end
