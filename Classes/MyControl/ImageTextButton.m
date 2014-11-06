//
//  ImageTextButton.m
//  FileThis
//
//  Created by Cao Huu Loc on 5/30/14.
//
//

#import "ImageTextButton.h"

@implementation ImageTextButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.imageFrame = CGRectZero;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (!CGRectIsEmpty(self.imageFrame)) {
        self.imageView.frame = self.imageFrame;
        CGRect rect;
        rect.origin.x = self.imageFrame.origin.x + self.imageFrame.size.width;
        rect.origin.y = 0;
        rect.size.width = self.frame.size.width - rect.origin.x;
        rect.size.height = self.frame.size.height;
        self.titleLabel.frame = rect;
    }
}

- (void)setImageFrame:(CGRect)imageFrame {
    _imageFrame = imageFrame;
    [self setNeedsLayout];
}

@end
