//
//  CommonLayout.h
//  TKD
//
//  Created by decuoi on 3/31/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TopAlignedLabel.h"
#import "OffsetLabel.h"
#import "UIView+Ext.h"
#import "UIViewController_Ext.h"

#define kGrayColor          [UIColor colorWithRed:59.0/255 green:59.0/255 blue:59.0/255 alpha:1.0]
#define kSeparateLineColor  [UIColor colorWithRed:68.0/255 green:68.0/255 blue:68.0/255 alpha:1.0]
#define kDarkRedColor       [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1]
#define kBlueColor          [UIColor colorWithRed:0.12 green:0.32 blue:0.51 alpha:1.0]
#define kBlackColor         [UIColor blackColor]

#define kLightYellowColor   [UIColor colorWithRed:1.0 green:1.0 blue:0.3 alpha:1]
#define kMyOrangeColor      [UIColor colorWithRed:0.9 green:0.5 blue:0.4 alpha:1.0]
#define kMyRedColor         [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1]
#define kWhiteSmokeColor    [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]

#define kAlertMessage_CannotSaveData        NSLocalizedString(@"ID_WARNING_CANNOT_SAVE_DATA", @"")
#define kAlertMessage_CannotRemoveData      NSLocalizedString(@"ID_WARNING_CANNOT_REMOVE_DATA", @"")
#define kAlertMessage_CannotLoadData        NSLocalizedString(@"ID_CANNOT_LOAD_DATA", @"")
#define kAlertMessage_ConfirmRemoveData     NSLocalizedString(@"ID_CONFIRM_REMOVE_DATA", @"")

#define kIcon_CircleCheckedGreen    [UIImage imageNamed:@"circle_green_checked.png"]
#define kIcon_CircleUnchecked       [UIImage imageNamed:@"circle_unchecked.png"]
#define kIcon_EditWhite             [UIImage imageNamed:@"edit_icon_small_white.png"]
#define kIcon_EditBlue              [UIImage imageNamed:@"edit_icon_small_blue.png"]

typedef enum FontSize {
    FontSizeXXSmall = 12,
    FontSizeXSmall = 14,
    FontSizeSmall = 16,
    FontSizeMedium = 18,
    FontSizeLarge = 20,
    FontSizexLarge = 22,
    FontSizeXLarge = 24,
    FontSizeXxLarge = 26,
    FontSizeXXLarge = 28,
    FontSizeXXXLarge = 32,
    FontSizeGiant = 38,
    FontSizeXGiant = 46,
    FontSizeXxGiant = 54,
    FontSizeXXGiant = 56,
    FontSizeXXXGiant = 58
} FontSize;

typedef enum FontFamily {
    FontFamilyHelveticaNeue,
    FontFamilyAppleGothic
} FontFamily;

@interface CommonLayout : NSObject {

}

+ (void)firstInit;
+ (UIImage*)whiteButtonImage;
+ (UIImage*)longWhiteButtonImage;
+ (UIImage*)blackButtonImage;
+ (UIImage*)longBlackButtonImage;
+ (UIImage*)redButtonImage;
+ (UIImage*)longRedButtonImage;
+ (UIImage*)blueButtonImage;
+ (UIImage*)longBlueButtonImage;

+ (UIImage*)texturedImage;
+ (UIImage*)circleCheckedImage;
+ (UIImage*)circleUncheckedImage;

+ (BOOL)isPoint:(CGPoint)point inRect:(CGRect)rect;
+ (CGFloat)distanceFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2;

+ (void)moveView:(UIView*)view1 toHorizontalCenterOfView:(UIView*)view2;
+ (void)moveView:(UIView *)view1 toLeftOfView:(UIView*)view2 offset:(int)offset;
+ (void)moveView:(UIView *)view1 toRightOfView:(UIView*)view2 offset:(int)offset;

#pragma mark - Resize Control
+ (void)changeHeight:(UIView*)view newHeight:(float)newHeight;

+ (UIView*)drawLine:(CGRect)rect color:(UIColor*)color superView:(UIView*)superView;

#pragma mark - Create Control
+ (UILabel*)createLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;
+ (UILabel*)createLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;
+ (UILabel*)createLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;

+ (TopAlignedLabel*)createTopAlignedLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView numberOfLines:(int)numberOfLines;

+ (TopAlignedLabel*)createTopAlignedLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView numberOfLines:(int)numberOfLines;


+ (OffsetLabel*)createOffsetLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text offset:(Offset)offset borderColor:(UIColor*)borderColor borderWidths:(Offset)borderWidths superView:(UIView*)superView;
+ (OffsetLabel*)createOffsetLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text offset:(Offset)offset borderColor:(UIColor*)borderColor borderWidths:(Offset)borderWidths superView:(UIView*)superView;
+ (OffsetLabel*)createOffsetLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text offset:(Offset)offset superView:(UIView*)superView;
+ (OffsetLabel*)createOffsetLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text offset:(Offset)offset superView:(UIView*)superView;



+ (UIButton*)createImageButton:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundImage:(UIImage*)backgroundImage text:(NSString*)text touchTarget:(id)target touchSelector:(SEL)selector;
+ (UIButton*)createImageButton:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundImage:(UIImage*)backgroundImage text:(NSString*)text touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;

+ (UIButton*)createImageButton:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundImage:(UIImage*)backgroundImage text:(NSString*)text touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;


+ (UIButton*)createImageButtonWithFrame:(CGRect)frame image:(UIImage*)image touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;
+ (UIButton*)createImageButton:(CGRect)frame image:(UIImage*)image contentMode:(UIViewContentMode)contentMode touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;
+ (UIButton*)createImageButton:(CGRect)frame image:(UIImage*)image contentMode:(UIViewContentMode)contentMode touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView cornerRadius:(float)cornerRadius;
+ (UIButton*)createImageButton:(CGRect)frame backgroundImage:(UIImage*)backgroundImage contentMode:(UIViewContentMode)contentMode touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;
+ (UIButton*)createImageButton:(CGPoint)atPoint image:(UIImage*)image touchTarget:(id)target touchSelector:(SEL)selector;
+ (UIButton*)createImageButtonAtPoint:(CGPoint)atPoint image:(UIImage*)image touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;

+ (UIButton*)createTextButton:(CGRect)frame font:(UIFont*)font text:(NSString*)text textColor:(UIColor*)textColor touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;
+ (UIButton*)createTextButton:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold text:(NSString*)text textColor:(UIColor*)textColor touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;


#pragma mark - TextField
+ (UITextField*)createTextField:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;
+ (UITextField*)createTextField:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;

#pragma mark - Font
+ (UIFont*)getFont:(FontSize)fontSize isBold:(BOOL)isBold;
+ (UIFont*)getFont:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic;

#pragma mark - Alert
+ (void)showAlertMessageWithTitle:(NSString *)title content:(NSString *)content delegate:(id<UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
+ (void)showAlertMessageWithTitle:(NSString *)title content:(NSString *)content tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle;
+ (UIAlertView*)createAlertMessageWithTitle:(NSString *)title content:(NSString *)content delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle;
+ (void)showConfirmAlert:(NSString *)content tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showConfirmAlert:(NSString *)content delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showWarningAlert:(NSString *)content errorMessage:(NSString *)errorMessage delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showWarningAlert:(NSString *)content errorMessage:(NSString *)errorMessage tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showInfoAlert:(NSString *)content delegate:(id<UIAlertViewDelegate>)delegate;
+ (void)showInfoAlert:(NSString *)content tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate;

+ (void)setFont:(FontFamily)fontFamily;

+ (void)autoSizeView:(UIView*)view maxRightX:(float)maxRightX;

+ (void)moveViewsToHorizontalCenterOfSuperView:(NSArray*)views;
+ (void)moveViews:(NSArray*)views toHorizontalCenterOfView:(UIView*)view centerY:(int)y;
+ (void)moveViews:(NSArray*)views toHorizontalCenterOfView:(UIView*)view;
+ (void)moveViews:(NSArray*)views toX:(int)x;

#pragma mark - drawRoundedRectangle
+ (void)drawRoundedRectangle:(CGRect)rect cornerRadius:(float)cornerRadius context:(CGContextRef)context;
+ (void)drawRoundedRectangle:(CGRect)rect cornerRadius:(float)cornerRadius context:(CGContextRef)context arrowDirectionUp:(BOOL)arrowDirectionUp arrowPointX:(float)arrowPointX arrowWidth:(float)arrowWidth arrowHeight:(float)arrowHeight;
+ (void)drawRoundedRectangle:(CGRect)rect cornerRadius:(float)cornerRadius context:(CGContextRef)context arrowDirectionLeft:(BOOL)arrowDirectionLeft arrowPointY:(float)arrowPointY arrowWidth:(float)arrowWidth arrowHeight:(float)arrowHeight;

#pragma mark - scroll view
+ (void)scrollViewToRect:(UIScrollView *)scrollView toRect:(CGRect)toRect;

+ (void)autoImageViewHeight:(UIImageView*)imageView;
@end
