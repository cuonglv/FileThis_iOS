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
#import "LeftAlignedCollectionViewFlowLayout.h"
#import "UIColor+Ext.h"

#define EPSILON_COMPARE_FLOATING    0.000001

#define KB_TO_MB_UNIT               1000
#define KB_TO_GB_UNIT               1000000

#define kFontNameHelveticaNeue              @"HelveticaNeue"
#define kFontNameAppleGothic                @"Verdana"
#define kPI 3.1416

//#define kGrayColor          [UIColor colorWithRed:59.0/255 green:59.0/255 blue:59.0/255 alpha:1.0]
#define kSeparateLineColor  [UIColor colorWithRed:68.0/255 green:68.0/255 blue:68.0/255 alpha:1.0]
#define kDarkRedColor       [UIColor colorWithRed:0.5 green:0 blue:0 alpha:1]
#define kBlueColor          [UIColor colorWithRed:0.12 green:0.32 blue:0.51 alpha:1.0]
#define kBlackColor         [UIColor blackColor]
#define kClearColor         [UIColor clearColor]

#define kLightYellowColor   [UIColor colorWithRed:1.0 green:1.0 blue:0.3 alpha:1]
#define kMyOrangeColor      [UIColor colorWithRed:0.9 green:0.5 blue:0.4 alpha:1.0]
#define kMyRedColor         [UIColor colorWithRed:0.7 green:0 blue:0 alpha:1]
#define kWhiteSmokeColor    [UIColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1]

#define kAlertMessage_CannotSaveData        NSLocalizedString(@"ID_WARNING_CANNOT_SAVE_DATA", @"")
#define kAlertMessage_CannotRemoveData      NSLocalizedString(@"ID_WARNING_CANNOT_REMOVE_DATA", @"")
#define kAlertMessage_CannotLoadData        NSLocalizedString(@"ID_WARNING_CANNOT_LOAD_DATA", @"")
#define kAlertMessage_ConfirmRemoveData     NSLocalizedString(@"ID_CONFIRM_REMOVE_DATA", @"")

#define kIcon_CircleCheckedGreen    [UIImage imageNamed:@"circle_green_checked.png"]
#define kIcon_CircleUnchecked       [UIImage imageNamed:@"circle_unchecked.png"]
#define kIcon_EditWhite             [UIImage imageNamed:@"edit_icon_small_white.png"]
#define kIcon_EditBlue              [UIImage imageNamed:@"edit_icon_small_blue.png"]

#define kTextGrayColor              [UIColor colorWithRed:0.4 green:0.4 blue:0.4 alpha:1.0]
#define kTextOrangeColor            [UIColor colorWithRed:0.93 green:0.34 blue:0.15 alpha:1.0]
#define kBackgroundLightGrayColor   [UIColor colorWithRed:0.91 green:0.92 blue:0.94 alpha:1.0]
#define kBackgroundLightGrayColor2  [UIColor colorWithRed:0.976 green:0.976 blue:0.984 alpha:1.0]
#define kBorderLightGrayColor       [UIColor colorWithRed:0.824 green:0.82 blue:0.843 alpha:1.0]
#define kBackgroundOrange           [UIColor colorWithRed:238.0/255.0 green:89.0/255.0 blue:8.0/255.0 alpha:1.0]

typedef enum FontSize {
    FontSizeTiny = 10,
    FontSizeXXSmall = 12,
    FontSizexXSmall = 13,
    FontSizeXSmall = 14,
    FontSizexSmall = 15,
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
+ (UIImageView*)createImageView:(CGRect)frame image:(UIImage*)image contentMode:(UIViewContentMode)contentMode superView:(UIView*)superView;
+ (UILabel*)createLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;
+ (UILabel*)createLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;
+ (UILabel*)createLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;

+ (TopAlignedLabel*)createTopAlignedLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView numberOfLines:(int)numberOfLines;

+ (TopAlignedLabel*)createTopAlignedLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView numberOfLines:(int)numberOfLines;

+ (TopAlignedLabel*)createTopAlignedLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView numberOfLines:(int)numberOfLines;

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

+ (UIButton*)createTextButton:(CGRect)frame font:(UIFont*)font text:(NSString*)text textColor:(UIColor*)textColor backColor:(UIColor*)backColor borderColor:(UIColor*)borderColor cornerRadius:(float)cornerRadius touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;
+ (UIButton*)createTextButton:(CGRect)frame font:(UIFont*)font text:(NSString*)text textColor:(UIColor*)textColor touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;
+ (UIButton*)createTextButton:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold text:(NSString*)text textColor:(UIColor*)textColor touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;

+ (UIButton*)createTextImageButton:(CGRect)frame text:(NSString*)text fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor icon:(UIImage*)icon iconSize:(CGSize)iconSize offsetBetweenTextAndIcon:(float)offsetBetweenTextAndIcon iconLeftOffset:(float)iconLeftOffset backgroundImage:(UIImage*)backgroundImage touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;

+ (UIButton*)createTextImageButton:(CGRect)frame text:(NSString*)text font:(UIFont*)font textColor:(UIColor*)textColor icon:(UIImage*)icon iconSize:(CGSize)iconSize offsetBetweenTextAndIcon:(float)offsetBetweenTextAndIcon iconLeftOffset:(float)iconLeftOffset backgroundImage:(UIImage*)backgroundImage touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;

+ (UIButton*)createVerticalTextImageButton:(CGRect)frame text:(NSString*)text font:(UIFont*)font textColor:(UIColor*)textColor icon:(UIImage*)icon iconSize:(CGSize)iconSize offsetBetweenTextAndIcon:(float)offsetBetweenTextAndIcon backgroundImage:(UIImage*)backgroundImage touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;
+ (UIButton*)createVerticalTextImageButton:(CGRect)frame text:(NSString*)text fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor icon:(UIImage*)icon iconSize:(CGSize)iconSize offsetBetweenTextAndIcon:(float)offsetBetweenTextAndIcon backgroundImage:(UIImage*)backgroundImage touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView;

+ (UICollectionView*)createCollectionView:(CGRect)frame backgroundColor:(UIColor*)backgroundColor layout:(UICollectionViewLayout*)layout cellClass:(Class)cellClass cellIdentifier:(NSString*)cellIdentifier superView:(UIView*)superView delegateDataSource:(id<UICollectionViewDataSource,UICollectionViewDelegate>)delegate;
+ (UICollectionView*)createCollectionViewWithFlowLayout:(CGRect)frame backgroundColor:(UIColor*)backgroundColor cellClass:(Class)cellClass cellIdentifier:(NSString*)cellIdentifier superView:(UIView*)superView delegateDataSource:(id<UICollectionViewDataSource,UICollectionViewDelegate>)delegate;

+ (UISegmentedControl*)createSegmentControl:(CGRect)frame texts:(NSArray*)texts font:(UIFont*)font tintColor:(UIColor*)tintColor target:(id)target selector:(SEL)selector superView:(UIView*)superView;

#pragma mark - TextField
+ (UITextField*)createTextField:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;
+ (UITextField*)createTextField:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView;

#pragma mark - TextView
+ (UITextView*)createTextView:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView delegate:(id)delegate;
+ (UITextView*)createTextView:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView delegate:(id)delegate;

#pragma mark - Font
+ (UIFont*)getFont:(FontSize)fontSize isBold:(BOOL)isBold;
+ (UIFont*)getFont:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic;
+ (UIFont*)getFontWithSize:(float)size isBold:(BOOL)isBold;
+ (UIFont*)getFontWithSize:(float)size isBold:(BOOL)isBold isItalic:(BOOL)isItalic;

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

#pragma mark - Subcontrols in view
//Loc Cao
+ (void)setFont:(UIFont*)font forClass:(Class)theClass inView:(UIView*)view;
+ (void)setFont:(UIFont*)font forClassesInList:(NSArray*)listClass inView:(UIView*)view;
+ (void)setTextColor:(UIColor*)color forClass:(Class)theClass inView:(UIView*)view;
+ (void)setTextColor:(UIColor*)color forClassesInList:(NSArray*)listClass inView:(UIView*)view;

+ (void)setAppFontForSubviewsOfView:(UIView*)view; //Cuong

#pragma mark - Unit convertion
+ (BOOL)compareFloatingValue:(float)v1 with:(float)v2;
+ (NSString*)storageTextFromKB:(long long)kb;
+ (NSString*)storageTextFromKB:(long long)kb decimalPlaces:(int)decimalPlaces;

@end
