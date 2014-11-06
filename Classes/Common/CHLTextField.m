//
//  CHLTextField.m
//  FileThis
//
//  Created by Cao Huu Loc on 3/8/14.
//
//

#import "CHLTextField.h"

@implementation CHLTextField

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.lineBreakMode = NSLineBreakByTruncatingTail;
    }
    return self;
}


// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    /*if (!self.isEditing) {
        [self.text drawInRect:rect withFont:self.font lineBreakMode:NSLineBreakByTruncatingMiddle];
    }*/
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)drawTextInRect:(CGRect)rect {
    if (self.lineBreakMode != NSLineBreakByTruncatingTail) {
        CGSize size = [self.text sizeWithFont:self.font forWidth:rect.size.width lineBreakMode:NSLineBreakByTruncatingTail];
        float top = (rect.size.height - size.height) / 2.0;
        CGRect newRect = CGRectMake(0, top, rect.size.width, size.height);
        
        [self.textColor set];
        [self.text drawInRect:newRect withFont:self.font lineBreakMode:self.lineBreakMode];
    } else {
        [super drawTextInRect:rect];
    }
}
#pragma GCC diagnostic pop

@end
