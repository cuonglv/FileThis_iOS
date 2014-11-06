//
//  IconAndTextView.h
//  FileThis
//
//  Created by Cao Huu Loc on 3/11/14.
//
//

#import <UIKit/UIKit.h>

@interface IconAndTextView : UIView
@property (nonatomic, assign) CGSize iconSize;
@property (nonatomic, assign) float leftIconMargin;
@property (nonatomic, assign) float leftTextMargin;
@property (nonatomic, assign) float rightTextMargin;
@property (nonatomic, assign) float topTextMargin;
@property (nonatomic, assign) float bottomTextMargin;
@property (nonatomic, assign) float spaceTextElement;

@property (nonatomic, strong) UIImageView *iconImage;
@property (nonatomic, strong) UILabel *lblText1;
@property (nonatomic, strong) UILabel *lblText2;

- (void)setIcon:(UIImage*)icon text1:(NSString*)text1 text2:(NSString*)text2;
- (void)resizeByWidth:(float)width;

@end
