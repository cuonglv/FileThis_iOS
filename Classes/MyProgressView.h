//
//  MyProgressView.h
//  FileThis
//
//  Created by Cuong Le on 1/16/14.
//
//

#import <UIKit/UIKit.h>

@protocol MyProgressViewDelegate <NSObject>
@optional
- (void)progressViewClickedDetailButton;
@end

@interface MyProgressView : UIView

@property (nonatomic, strong) UILabel *progressLabel;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) UIButton *btnGo;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, assign) id<MyProgressViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor tintColor:(UIColor*)tintColor trackTintColor:(UIColor*)trackTintColor progressBarWidth:(float)progressBarWidth superView:(UIView*)superView;
- (id)initWithFrame:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor tintColor:(UIColor*)tintColor trackTintColor:(UIColor*)trackTintColor progressBarWidth:(float)progressBarWidth addDetailLabel:(BOOL)addDetailLabel superView:(UIView*)superView;

- (void)setProgressValue:(float)progressvalue text:(NSString*)text;

@end
