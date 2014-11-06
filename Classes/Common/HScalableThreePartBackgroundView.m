//
//  HScalableThreePartBackgroundView.m
//  FileThis
//
//  Created by Cuong Le on 12/19/13.
//
//

#import "HScalableThreePartBackgroundView.h"
#import "CommonLayout.h"

@implementation HScalableThreePartBackgroundView

- (id)initWithFrame:(CGRect)frame leftImage:(UIImage*)leftImage centerImage:(UIImage*)centerImage rightImage:(UIImage*)rightImage superView:(UIView*)superView {
    if (self = [super initWithFrame:frame]) {
        self.leftBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.leftBackgroundView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.leftBackgroundView];
        
        self.centerBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.centerBackgroundView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.centerBackgroundView];
        
        self.rightBackgroundView = [[UIImageView alloc] initWithFrame:CGRectZero];
        self.rightBackgroundView.contentMode = UIViewContentModeScaleToFill;
        [self addSubview:self.rightBackgroundView];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectZero];
        [self addSubview:self.contentView];
        
        [self setLeftImage:leftImage centerImage:centerImage rightImage:rightImage];
        [superView addSubview:self];
    }
    return self;
}

- (void)relayout {
    [super relayout];
    float leftBackgroundViewWidth = (self.leftBackgroundView.image ? self.frame.size.height * self.leftBackgroundView.image.size.width / self.leftBackgroundView.image.size.height : 0);
    float rightBackgroundViewWidth = (self.rightBackgroundView.image ? self.frame.size.height * self.rightBackgroundView.image.size.width / self.rightBackgroundView.image.size.height : 0);
    self.leftBackgroundView.frame = CGRectMake(0, 0, leftBackgroundViewWidth, self.frame.size.height);
    self.rightBackgroundView.frame = CGRectMake(self.frame.size.width - rightBackgroundViewWidth, 0, rightBackgroundViewWidth, self.frame.size.height);
    self.contentView.frame = self.centerBackgroundView.frame = CGRectMake(leftBackgroundViewWidth, 0, self.frame.size.width - leftBackgroundViewWidth - rightBackgroundViewWidth, self.frame.size.height);
}

- (void)setLeftImage:(UIImage*)leftImage centerImage:(UIImage*)centerImage rightImage:(UIImage*)rightImage {
    self.leftBackgroundView.image = leftImage;
    self.centerBackgroundView.image = centerImage;
    self.rightBackgroundView.image = rightImage;
    [self relayout];
}

@end
