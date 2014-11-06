//
//  WhiteRoundRectPopupView.h
//  FileThis
//
//  Created by Cuong Le on 3/4/14.
//
//

#import <UIKit/UIKit.h>

@protocol WhiteRoundRectPopupViewDelegate <NSObject>
@optional
- (void)whiteRoundRectPopupView_ShouldCloseWithLeftButtonTouched:(id)sender;
- (void)whiteRoundRectPopupView_ShouldCloseWithRightButtonTouched:(id)sender;
@end

@interface WhiteRoundRectPopupView : UIView
@property (nonatomic, strong) UIView *darkBackView, *contentView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIButton *leftButton, *rightButton;
@property (nonatomic, assign) id<WhiteRoundRectPopupViewDelegate> delegate;
- (id)initWithSize:(CGSize)size titleOfPopup:(NSString*)titleOfPopup titleOfLeftButton:(NSString*)titleOfLeftButton titleOfRightButton:(NSString*)titleOfRightButton superView:(UIView*)superView delegate:(id<WhiteRoundRectPopupViewDelegate>)delegate;
- (void)handleLeftButton;
- (void)handleRightButton;
@end
