//
//  MyAnimatedView.m
//  GreatestRoad
//
//  Created by decuoi on 11/16/10.
//  Copyright 2010 Greatest Road Software. All rights reserved.
//

#import "MyAnimatedView.h"
#import "Constants.h"

@implementation MyAnimatedView

@synthesize animation, blnIsAnimating;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        blnIsAnimating = NO;
    }
    return self;
}

+ (id)newWithSuperview:(UIView *)view image:(UIImage*)myImage {
    MyAnimatedView *ret = [[MyAnimatedView alloc] initWithImage:myImage];
    ret.frame = CGRectMake((view.frame.size.width - myImage.size.width)/2, (view.frame.size.height - myImage.size.height)/2, myImage.size.width, myImage.size.height);

    CATransform3D transform = CATransform3DMakeRotation(1.0, 0.0, 0.0, 1.0);
	
	// Create a basic animation to animate the layer's transform
	CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
	animation.toValue = [NSValue valueWithCATransform3D:transform];
	animation.duration = 0.2;
	animation.cumulative = YES;
	animation.repeatCount = MAXFLOAT;  // this is infinity in IEEE 754 floating point format
    
    ret.animation = animation;
    ret.hidden = YES;
    [view addSubview:ret];
    return ret;
}

- (void)dealloc {
    //[self stopAnimating];
    if (blnIsAnimating) {
        [self stopAnimating];
    }
}

#pragma mark Spinner Animtation
- (void)startMyAnimation {
    if (!blnIsAnimating) {
        blnIsAnimating = YES;
        self.hidden = NO;
        [NSThread detachNewThreadSelector:@selector(doStartMyAnimation) toTarget:self withObject:nil];
    }
}

- (void)doStartMyAnimation {
    @autoreleasepool {
        if (blnIsAnimating) {  //must use this code to ensure that stopMyAnimation was not invoked
            [self.layer addAnimation:animation forKey:@"RotateAnimation"];
            if (!blnIsAnimating) {  //must use this code to ensure that stopMyAnimation was not invoked
                [self stopMyAnimation];
            }
        }
	}
}

- (void)stopMyAnimation {
    @autoreleasepool {
        blnIsAnimating = NO;
        self.hidden = YES;
        [self.layer removeAllAnimations];
	}
}

@end
