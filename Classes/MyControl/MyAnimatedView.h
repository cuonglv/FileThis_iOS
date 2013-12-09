//
//  MyAnimatedView.h
//  GreatestRoad
//
//  Created by decuoi on 11/16/10.
//  Copyright 2010 Greatest Road Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>


@interface MyAnimatedView : UIImageView {
    BOOL blnIsAnimating;
    CABasicAnimation *animation;
}
@property (nonatomic, strong) CABasicAnimation *animation;
@property (readonly) BOOL blnIsAnimating;
+ (id)newWithSuperview:(UIView *)view image:(UIImage*)myImage;
#pragma mark Spinner Animtation
- (void)startMyAnimation;
- (void)doStartMyAnimation;
- (void)stopMyAnimation;
@end
