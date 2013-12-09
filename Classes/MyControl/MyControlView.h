//
//  MyControlView.h
//  GreatestRoad
//
//  Created by decuoi on 11/14/10.
//  Copyright 2010 Greatest Road Software. All rights reserved.

//  Author Cuong:
//  Provide each control class new variables and functions to store stable origin (or location)
//  so that, when the control need to move another location, it will be able to come back to stable origin


#import <UIKit/UIKit.h>


typedef enum VerticalAlignment {
    VerticalAlignmentTop,
    VerticalAlignmentMiddle,
    VerticalAlignmentBottom,
} VerticalAlignment;

@interface MyLabel : UILabel {
@public
    CGPoint stableOrigin;
    VerticalAlignment verticalAlignment_;
}
@property (nonatomic, assign) VerticalAlignment verticalAlignment;
+ (id)newWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor backColor:(UIColor *)backColor;
- (void)saveStableOrigin;
- (void)moveToStableOrigin;
@end

#pragma mark -
@interface MyTextField : UITextField {
@public
    CGPoint stableOrigin;
    int maxLength;
    NSString *maxLengthAlertMessage;
    NSString *sExceptionalCharString, *sExceptionalCharsAlertMessage;
}
+ (id)newWithFrame:(CGRect)frame placeHolder:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor;
- (void)saveStableOrigin;
- (void)moveToStableOrigin;
#pragma mark Max Length
- (void)setMaxLength:(int)maxlength alert:(NSString *)message;
- (void)setStandardMaxLength:(int)maxlength alert:(NSString *)localizedMessage;
#pragma mark Exceptional Chars
- (void)setExceptionalChars:(NSString *)stringOfChars alert:(NSString *)message;
- (void)setDefaultExceptionalChars;
#pragma mark Handle Text Event
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
@end


#pragma mark -
@interface MyTextView : UITextView {
    UIImageView *backgroundImageView;
@public
    CGPoint stableOrigin;
    int maxLength;
    NSString *maxLengthAlertMessage;
    NSString *sExceptionalCharString, *sExceptionalCharsAlertMessage;
}
@property (nonatomic, strong) UIImageView *backgroundImageView;
- (void)saveStableOrigin;
- (void)moveToStableOrigin;

#pragma mark Max Length
- (void)setMaxLength:(int)maxlength alert:(NSString *)message;
- (void)setStandardMaxLength:(int)maxlength alert:(NSString *)localizedMessage;
#pragma mark Exceptional Chars
- (void)setExceptionalChars:(NSString *)stringOfChars alert:(NSString *)message;
- (void)setDefaultExceptionalChars;
#pragma mark Handle Text Event
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
#pragma mark BackgroundImage
- (void)setBackgroundImage:(NSString *)imageFile;
@end


@interface MyLinkLabel : MyLabel {
}
- (void)setFont:(UIFont *)font text:(NSString *)text textColor:(UIColor *)textColor;
@end


#pragma mark -
@interface MyLinkButton : UIButton {
@public
    CGPoint stableOrigin;
}
- (void)saveStableOrigin;
- (void)moveToStableOrigin;
- (void)setFont:(UIFont *)font text:(NSString *)text textColor:(UIColor *)textColor;
@end

/*
@interface MyBackBarButton : UIBarButtonItem {
}
+ (id)initWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)target action:(SEL)action;
 
@end*/