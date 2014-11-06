//
//  HScalableThreePartBackgroundView.h
//  FileThis
//
//  Created by Cuong Le on 12/19/13.
//
//

#import <UIKit/UIKit.h>

@interface HScalableThreePartBackgroundView : UIView
@property (nonatomic, strong) UIImageView *leftBackgroundView, *centerBackgroundView, *rightBackgroundView;
@property (nonatomic, strong) UIView *contentView;

- (id)initWithFrame:(CGRect)frame leftImage:(UIImage*)leftImage centerImage:(UIImage*)centerImage rightImage:(UIImage*)rightImage superView:(UIView*)superView;
- (void)setLeftImage:(UIImage*)leftImage centerImage:(UIImage*)centerImage rightImage:(UIImage*)rightImage;
@end
