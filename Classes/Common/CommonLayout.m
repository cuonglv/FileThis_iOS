//
//  CommonLayout.m
//  TKD
//
//  Created by decuoi on 3/31/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "CommonLayout.h"
#import "CommonVar.h"

#define kFontNameHelveticaNeue              @"HelveticaNeue"
#define kFontNameAppleGothic                @"Verdana"
#define kPI 3.1416

@implementation CommonLayout

static NSString *fontName_ = kFontNameHelveticaNeue;

static BOOL isNewiOS = NO;
static UIColor *defaultTextFieldBackColor = nil;

+ (void)firstInit {
    if ((isNewiOS = ([[UIDevice currentDevice].systemVersion floatValue] >= 5.0))) {
        defaultTextFieldBackColor = [UIColor whiteColor];
    } else {
        defaultTextFieldBackColor = [UIColor clearColor];
    }
}

+ (UIImage*)whiteButtonImage {
    return [UIImage imageNamed:@"white_button.png"];
}

+ (UIImage*)longWhiteButtonImage {
    return [UIImage imageNamed:@"long_white_button.png"];
}

+ (UIImage*)blackButtonImage {
    return [UIImage imageNamed:@"black_button.png"];
}

+ (UIImage*)longBlackButtonImage {
    return [UIImage imageNamed:@"long_black_button.png"];
}

+ (UIImage*)redButtonImage {
    return [UIImage imageNamed:@"red_button.png"];
}

+ (UIImage*)longRedButtonImage {
    return [UIImage imageNamed:@"long_red_button.png"];
}

+ (UIImage*)blueButtonImage {
    return [UIImage imageNamed:@"blue_button.png"];
}

+ (UIImage*)longBlueButtonImage {
    return [UIImage imageNamed:@"long_blue_button.png"];
}

+ (UIImage*)texturedImage {
    return [UIImage imageNamed:@"textured_new.jpg"];
}

+ (UIImage*)circleCheckedImage {
    return [UIImage imageNamed:@"circle_checked.png"];
}

+ (UIImage*)circleUncheckedImage {
    return [UIImage imageNamed:@"circle_unchecked.png"];
}

+ (BOOL)isPoint:(CGPoint)point inRect:(CGRect)rect {
    return ((point.x >= rect.origin.x && point.y >= rect.origin.y) && 
            (point.x >= rect.origin.x && point.y <= rect.origin.y + rect.size.height) &&
            (point.x <= rect.origin.x + rect.size.width && point.y >= rect.origin.y) &&
            (point.x <= rect.origin.x + rect.size.width && point.y <= rect.origin.y + rect.size.height));
}

+ (CGFloat)distanceFromPoint:(CGPoint)point1 toPoint:(CGPoint)point2 {
    float dx = point2.x - point1.x;
    float dy = point2.y - point1.y;
    return sqrt(dx * dx + dy * dy);    
}

+ (void)moveView:(UIView*)view1 toHorizontalCenterOfView:(UIView*)view2 {
    [view1 setCenter:CGPointMake(view2.frame.origin.x + view2.frame.size.width / 2, view1.center.y)];
}

+ (void)moveView:(UIView *)view1 toLeftOfView:(UIView*)view2 offset:(int)offset {
    [view1 setCenter:CGPointMake(view2.frame.origin.x - view1.frame.size.width / 2 - offset, view2.center.y)];
}

+ (void)moveView:(UIView *)view1 toRightOfView:(UIView*)view2 offset:(int)offset {
    [view1 setCenter:CGPointMake(view2.frame.origin.x + view2.frame.size.width + view1.frame.size.width / 2 + offset, view2.center.y)];
}

#pragma mark -
#pragma mark Resize Control
+ (void)changeHeight:(UIView*)view newHeight:(float)newHeight {
    view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, view.frame.size.width, newHeight);
}

#pragma mark - Line
+ (UIView*)drawLine:(CGRect)rect color:(UIColor*)color superView:(UIView*)superView {
    UIView *line = [[UIView alloc] initWithFrame:rect];
    line.backgroundColor = color;
    [superView addSubview:line];
    return line;
}

#pragma mark -
#pragma mark Create Control
+ (UILabel*)createLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView {
    UILabel *label = [[UILabel alloc] initWithFrame:frame];
    [label setFont:font];
    if (textColor)
        [label setTextColor:textColor];
    else
        [label setTextColor:[UIColor blackColor]];
    
    if (backgroundColor)
        [label setBackgroundColor:backgroundColor];
    else
        [label setBackgroundColor:[UIColor clearColor]];
    
    [label setText:text];
    [superView addSubview:label];
    return label;
}


+ (UILabel*)createLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView {
    
    UIFont *font;
    
    if (isBold)
        font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    else
        font = [UIFont fontWithName:fontName_ size:fontSize];

    return [CommonLayout createLabel:frame font:font textColor:textColor backgroundColor:backgroundColor text:text superView:superView];
}

+ (UILabel*)createLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView {
    
    UIFont *font;
    
    if (isBold) {
        if (isItalic)
            font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-BoldItalic", fontName_] size:fontSize];
        else
            font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    } else {
        if (isItalic)
            font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Italic", fontName_] size:fontSize];
        else
            font = [UIFont fontWithName:fontName_ size:fontSize];
    }
    
    return [CommonLayout createLabel:frame font:font textColor:textColor backgroundColor:backgroundColor text:text superView:superView];
}


+ (TopAlignedLabel*)createTopAlignedLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView numberOfLines:(int)numberOfLines {
    TopAlignedLabel *label = [[TopAlignedLabel alloc] initWithFrame:frame];
    [label setFont:font];
    if (textColor)
        [label setTextColor:textColor];
    else
        [label setTextColor:[UIColor blackColor]];
    
    if (backgroundColor)
        [label setBackgroundColor:backgroundColor];
    else
        [label setBackgroundColor:[UIColor clearColor]];
    
    [label setText:text];
    [label setNumberOfLines:numberOfLines];
    [superView addSubview:label];
    return label;
}


+ (TopAlignedLabel*)createTopAlignedLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView numberOfLines:(int)numberOfLines {
    
    UIFont *font;
    
    if (isBold)
        font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    else
        font = [UIFont fontWithName:fontName_ size:fontSize];
    
    return [CommonLayout createTopAlignedLabel:frame font:font textColor:textColor backgroundColor:backgroundColor text:text superView:superView numberOfLines:numberOfLines];
}


+ (OffsetLabel*)createOffsetLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text offset:(Offset)offset borderColor:(UIColor*)borderColor borderWidths:(Offset)borderWidths superView:(UIView*)superView {
    OffsetLabel *label = [[OffsetLabel alloc] initWithFrame:frame offset:offset borderColor:borderColor borderWidths:borderWidths superView:superView];
    [label setFont:font];
    if (textColor)
        [label setTextColor:textColor];
    else
        [label setTextColor:[UIColor blackColor]];
    
    if (backgroundColor)
        [label setBackgroundColor:backgroundColor];
    else
        [label setBackgroundColor:[UIColor clearColor]];
    
    [label setText:text];
    return label;
}


+ (OffsetLabel*)createOffsetLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text offset:(Offset)offset borderColor:(UIColor*)borderColor borderWidths:(Offset)borderWidths superView:(UIView*)superView {
    
    UIFont *font;
    
    if (isBold)
        font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    else
        font = [UIFont fontWithName:fontName_ size:fontSize];
    
    return [CommonLayout createOffsetLabel:frame font:font textColor:textColor backgroundColor:backgroundColor text:text offset:offset borderColor:borderColor borderWidths:borderWidths superView:superView];
}

+ (OffsetLabel*)createOffsetLabel:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text offset:(Offset)offset superView:(UIView*)superView {
    OffsetLabel *label = [[OffsetLabel alloc] initWithFrame:frame offset:offset borderColor:nil borderWidths:OffsetZero() superView:superView];
    [label setFont:font];
    if (textColor)
        [label setTextColor:textColor];
    else
        [label setTextColor:[UIColor blackColor]];
    
    if (backgroundColor)
        [label setBackgroundColor:backgroundColor];
    else
        [label setBackgroundColor:[UIColor clearColor]];
    
    [label setText:text];
    return label;
}

+ (OffsetLabel*)createOffsetLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text offset:(Offset)offset superView:(UIView*)superView {
    
    UIFont *font;
    
    if (isBold)
        font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    else
        font = [UIFont fontWithName:fontName_ size:fontSize];
    
    return [CommonLayout createOffsetLabel:frame font:font textColor:textColor backgroundColor:backgroundColor text:text offset:offset borderColor:nil borderWidths:OffsetZero() superView:superView];
}

#pragma mark -
#pragma mark ImageButton
+ (UIButton*)createImageButton:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundImage:(UIImage*)backgroundImage text:(NSString*)text touchTarget:(id)target touchSelector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button.titleLabel setFont:font];
    
    if (textColor)
        [button setTitleColor:textColor forState:UIControlStateNormal];
    else
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setTitle:text forState:UIControlStateNormal];
    
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    return button;
}

+ (UIButton*)createImageButton:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundImage:(UIImage*)backgroundImage text:(NSString*)text touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    UIFont *font;
    
    if (isBold)
        font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    else
        font = [UIFont fontWithName:fontName_ size:fontSize];
    
    UIButton *button = [CommonLayout createImageButton:frame font:font textColor:textColor backgroundImage:backgroundImage text:text touchTarget:target touchSelector:selector superView:superView];
    return button;
}


+ (UIButton*)createImageButton:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundImage:(UIImage*)backgroundImage text:(NSString*)text touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    UIButton *button = [CommonLayout createImageButton:frame font:font textColor:textColor backgroundImage:backgroundImage text:text touchTarget:target touchSelector:selector];
    [superView addSubview:button];
    return button;
}

+ (UIButton*)createImageButtonWithFrame:(CGRect)frame image:(UIImage*)image touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:button];
    button.clipsToBounds = NO;
    return button;
}

+ (UIButton*)createImageButton:(CGRect)frame image:(UIImage*)image contentMode:(UIViewContentMode)contentMode touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button.imageView setContentMode:contentMode];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:button];
    button.clipsToBounds = NO;
    return button;
}

+ (UIButton*)createImageButton:(CGRect)frame image:(UIImage*)image contentMode:(UIViewContentMode)contentMode touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView cornerRadius:(float)cornerRadius {
    UIButton *button = [CommonLayout createImageButton:frame image:image contentMode:contentMode touchTarget:target touchSelector:selector superView:superView];
    button.imageView.layer.cornerRadius = cornerRadius;
    return button;
}

+ (UIButton*)createImageButton:(CGRect)frame backgroundImage:(UIImage*)backgroundImage contentMode:(UIViewContentMode)contentMode touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button.imageView setContentMode:contentMode];
    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:button];
    return button;
}

+ (UIButton*)createImageButton:(CGPoint)atPoint image:(UIImage*)image touchTarget:(id)target touchSelector:(SEL)selector {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:CGRectMake(atPoint.x, atPoint.y, image.size.width, image.size.height)];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    return button;
}

+ (UIButton*)createImageButtonAtPoint:(CGPoint)atPoint image:(UIImage*)image touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    UIButton *button = [CommonLayout createImageButton:atPoint image:image touchTarget:target touchSelector:selector];
    [superView addSubview:button];
    return button;
}


#pragma mark - Button
+ (UIButton*)createTextButton:(CGRect)frame font:(UIFont*)font text:(NSString*)text textColor:(UIColor*)textColor touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button.titleLabel setFont:font];
    
    if (textColor)
        [button setTitleColor:textColor forState:UIControlStateNormal];
    else
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    [button setTitle:text forState:UIControlStateNormal];
    
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    [superView addSubview:button];
    
    return button;
}

+ (UIButton*)createTextButton:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold text:(NSString*)text textColor:(UIColor*)textColor touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    return [CommonLayout createTextButton:frame font:[CommonLayout getFont:fontSize isBold:isBold] text:text textColor:textColor touchTarget:target touchSelector:selector superView:superView];
}

#pragma mark -
#pragma mark TextField
+ (UITextField*)createTextField:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView {
    UITextField *tf = [[UITextField alloc] initWithFrame:frame];
    [tf setFont:font];
    tf.borderStyle = UITextBorderStyleRoundedRect;
    tf.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    tf.clearButtonMode = UITextFieldViewModeWhileEditing;
    tf.autocorrectionType = UITextAutocorrectionTypeNo;
    if (textColor)
        [tf setTextColor:textColor];
    else
        [tf setTextColor:[UIColor blackColor]];
    
    if (backgroundColor)
        [tf setBackgroundColor:backgroundColor];
    else
        [tf setBackgroundColor:defaultTextFieldBackColor];
    
    [tf setText:text];
    [superView addSubview:tf];
    
    return tf;
}


+ (UITextField*)createTextField:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView {
    
    UIFont *font;
    
    if (isBold)
        font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    else
        font = [UIFont fontWithName:fontName_ size:fontSize];
    
    return [CommonLayout createTextField:frame font:font textColor:textColor backgroundColor:backgroundColor text:text superView:superView];
}

+ (UITextField*)createCheckNoTextField:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView {
    UITextField *tf = [CommonLayout createTextField:frame fontSize:fontSize isBold:isBold textColor:textColor backgroundColor:backgroundColor text:text superView:superView];
    tf.placeholder = NSLocalizedString(@"ID_ENTER_CHECK_NUMBER", @"");
    tf.keyboardType = UIKeyboardTypeNumberPad;
    return tf;
}

#pragma mark - TextView
+ (UITextView*)createTextView:(CGRect)frame font:(UIFont*)font textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView delegate:(id)delegate {
    UITextView *tf = [[UITextView alloc] initWithFrame:frame];
    [tf setFont:font];
    tf.layer.cornerRadius = 8;
    tf.layer.borderWidth = 1;
    tf.layer.borderColor = [[UIColor grayColor] CGColor];
    if (textColor)
        [tf setTextColor:textColor];
    else
        [tf setTextColor:[UIColor blackColor]];
    
    if (backgroundColor)
        [tf setBackgroundColor:backgroundColor];
    else
        [tf setBackgroundColor:defaultTextFieldBackColor];
    
    [tf setText:text];
    [superView addSubview:tf];
    
    tf.delegate = delegate;
    
    return tf;
}

+ (UITextView*)createTextView:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView delegate:(id)delegate {
    UIFont *font;
    
    if (isBold)
        font = [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    else
        font = [UIFont fontWithName:fontName_ size:fontSize];
    
    return [CommonLayout createTextView:frame font:font textColor:textColor backgroundColor:backgroundColor text:text superView:superView delegate:delegate];
}

#pragma mark - Font
+ (UIFont*)getFont:(FontSize)fontSize isBold:(BOOL)isBold {
    if (isBold)
        return [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    else
        return [UIFont fontWithName:fontName_ size:fontSize];
}

+ (UIFont*)getFont:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic {
    if (isBold) {
        if (isItalic)
            return [UIFont fontWithName:[NSString stringWithFormat:@"%@-BoldItalic", fontName_] size:fontSize];
        else
            return [UIFont fontWithName:[NSString stringWithFormat:@"%@-Bold", fontName_] size:fontSize];
    } else {
        if (isItalic)
            return [UIFont fontWithName:[NSString stringWithFormat:@"%@-Italic", fontName_] size:fontSize];
        else
            return [UIFont fontWithName:fontName_ size:fontSize];
    }
}


#pragma mark - Alert
+ (void)showAlertMessageWithTitle:(NSString *)title content:(NSString *)content delegate:(id<UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    [alert show];
}

+ (void)showAlertMessageWithTitle:(NSString *)title content:(NSString *)content tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    alert.tag = tag;
    [alert show];
}

+ (UIAlertView*)createAlertMessageWithTitle:(NSString *)title content:(NSString *)content delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    [alert show];
    return alert;
}

+ (void)showConfirmAlert:(NSString *)content tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ID_CONFIRM", @"") message:content delegate:delegate cancelButtonTitle:NSLocalizedString(@"ID_YES", @"") otherButtonTitles:NSLocalizedString(@"ID_NO", @""), nil];
    alert.tag = tag;
    [alert show];
}

+ (void)showConfirmAlert:(NSString *)content delegate:(id<UIAlertViewDelegate>)delegate {
    [CommonLayout showConfirmAlert:content tag:NSNotFound delegate:delegate];
}

+ (void)showWarningAlert:(NSString *)content errorMessage:(NSString *)errorMessage delegate:(id<UIAlertViewDelegate>)delegate {
    [CommonLayout showWarningAlert:content errorMessage:errorMessage tag:NSNotFound delegate:delegate];
}

+ (void)showWarningAlert:(NSString *)content errorMessage:(NSString *)errorMessage tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate {
    NSString *message;
    if ([errorMessage length] > 0)
        message = [NSString stringWithFormat:@"%@\n%@",content,errorMessage];
    else
        message = content;
        
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ID_WARNING", @"") message:message delegate:delegate cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
}

+ (void)showInfoAlert:(NSString *)content delegate:(id<UIAlertViewDelegate>)delegate {
    [CommonLayout showInfoAlert:content tag:NSNotFound delegate:delegate];
}

+ (void)showInfoAlert:(NSString *)content tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ID_INFO", @"") message:content delegate:delegate cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitles:nil];
    alert.tag = tag;
    [alert show];
}

#pragma mark - Other
+ (void)setFont:(FontFamily)fontFamily {
    switch (fontFamily) {
        case FontFamilyAppleGothic:
            fontName_ = kFontNameAppleGothic; 
            break;
        default:
            fontName_ = kFontNameHelveticaNeue; 
            break;
    }
}

+ (void)autoSizeView:(UIView*)view maxRightX:(float)maxRightX {
    CGSize fitSize = [view sizeThatFits:CGSizeZero];
    if (fitSize.width > maxRightX - view.frame.origin.x)
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, maxRightX - view.frame.origin.x, fitSize.height);
    else
        view.frame = CGRectMake(view.frame.origin.x, view.frame.origin.y, fitSize.width, fitSize.height);
}

+ (void)moveViews:(NSArray*)views toHorizontalCenterOfView:(UIView*)view centerY:(int)y {
    if ([views count] == 0) return;
    
    UIView *v = [views objectAtIndex:0];
    float left = v.frame.origin.x;
    
    v = [views lastObject];
    float right = v.frame.origin.x + v.frame.size.width;
    
    float deltaX = view.frame.size.width/2 - (right + left) / 2;
    
    for (v in views) {
        v.frame = CGRectMake(v.frame.origin.x + deltaX, y - v.frame.size.height/2, v.frame.size.width, v.frame.size.height);
    }
}

+ (void)moveViewsToHorizontalCenterOfSuperView:(NSArray*)views  {
    if ([views count] == 0) return;
    
    UIView *v = [views objectAtIndex:0];
    float left = v.frame.origin.x;
    
    v = [views lastObject];
    float right = v.frame.origin.x + v.frame.size.width;
    
    float deltaX = v.superview.frame.size.width/2 - (right + left) / 2;
    
    for (v in views) {
        [v setLeft:v.frame.origin.x + deltaX];
    }
}

+ (void)moveViews:(NSArray*)views toHorizontalCenterOfView:(UIView*)view {
    if ([views count] == 0) return;
    
    UIView *v = [views objectAtIndex:0];
    float left = v.frame.origin.x;
    
    v = [views lastObject];
    float right = v.frame.origin.x + v.frame.size.width;
    
    float deltaX = view.frame.size.width/2 - (right + left) / 2;
    
    for (v in views) {
        [v setLeft:v.frame.origin.x + deltaX];
    }
}

+ (void)moveViews:(NSArray*)views toX:(int)x {
    if ([views count] == 0) return;
    
    UIView *v = [views objectAtIndex:0];
    float deltaX = x - v.frame.origin.x;
    
    for (v in views) {
        v.frame = CGRectMake(v.frame.origin.x + deltaX, v.frame.origin.y, v.frame.size.width, v.frame.size.height);
    }
}

#pragma mark - drawRoundedRectangle
+ (void)drawRoundedRectangle:(CGRect)rect cornerRadius:(float)cornerRadius context:(CGContextRef)context {
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + cornerRadius);
    CGContextAddArc(context, rect.origin.x + cornerRadius, rect.origin.y + cornerRadius, cornerRadius, kPI, kPI*3/2, 0);
    CGContextAddLineToPoint(context, rect.origin.x+ rect.size.width - cornerRadius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + cornerRadius, cornerRadius, kPI*3/2, kPI*2, 0);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + rect.size.height - cornerRadius, cornerRadius, 0, kPI/2, 0);
    CGContextAddLineToPoint(context, rect.origin.x + cornerRadius, rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + cornerRadius, rect.origin.y + rect.size.height - cornerRadius, cornerRadius, kPI/2, kPI, 0);
}

+ (void)drawRoundedRectangle:(CGRect)rect cornerRadius:(float)cornerRadius context:(CGContextRef)context arrowDirectionUp:(BOOL)arrowDirectionUp arrowPointX:(float)arrowPointX arrowWidth:(float)arrowWidth arrowHeight:(float)arrowHeight {
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + cornerRadius);
    CGContextAddArc(context, rect.origin.x + cornerRadius, rect.origin.y + cornerRadius, cornerRadius, kPI, kPI*3/2, 0);
    if (arrowDirectionUp) {
        CGContextAddLineToPoint(context, rect.origin.x + arrowPointX - arrowWidth/2, rect.origin.y);
        CGContextAddLineToPoint(context, rect.origin.x + arrowPointX, rect.origin.y - arrowHeight);
        CGContextAddLineToPoint(context, rect.origin.x + arrowPointX + arrowWidth/2, rect.origin.y);
    }
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + cornerRadius, cornerRadius, kPI*3/2, kPI*2, 0);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + rect.size.height - cornerRadius, cornerRadius, 0, kPI/2, 0);
    if (!arrowDirectionUp) {
        CGContextAddLineToPoint(context, rect.origin.x + arrowPointX - arrowWidth/2, rect.origin.y + rect.size.height);
        CGContextAddLineToPoint(context, rect.origin.x + arrowPointX, rect.origin.y + rect.size.height + arrowHeight);
        CGContextAddLineToPoint(context, rect.origin.x + arrowPointX + arrowWidth/2, rect.origin.y + rect.size.height);
    }
    CGContextAddLineToPoint(context, rect.origin.x + cornerRadius, rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + cornerRadius, rect.origin.y + rect.size.height - cornerRadius, cornerRadius, kPI/2, kPI, 0);
}

+ (void)drawRoundedRectangle:(CGRect)rect cornerRadius:(float)cornerRadius context:(CGContextRef)context arrowDirectionLeft:(BOOL)arrowDirectionLeft arrowPointY:(float)arrowPointY arrowWidth:(float)arrowWidth arrowHeight:(float)arrowHeight {
    
    CGContextMoveToPoint(context, rect.origin.x, rect.origin.y + cornerRadius);
    CGContextAddArc(context, rect.origin.x + cornerRadius, rect.origin.y + cornerRadius, cornerRadius, kPI, kPI*3/2, 0);
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y);
    CGContextAddArc(context, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + cornerRadius, cornerRadius, kPI*3/2, kPI*2, 0);
    if (!arrowDirectionLeft) {
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + arrowPointY - arrowWidth/2);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width + arrowHeight, rect.origin.y + arrowPointY);
        CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + arrowPointY + arrowWidth/2);
    }
    CGContextAddLineToPoint(context, rect.origin.x + rect.size.width, rect.origin.y + rect.size.height - cornerRadius);
    CGContextAddArc(context, rect.origin.x + rect.size.width - cornerRadius, rect.origin.y + rect.size.height - cornerRadius, cornerRadius, 0, kPI/2, 0);
    CGContextAddLineToPoint(context, rect.origin.x + cornerRadius, rect.origin.y + rect.size.height);
    CGContextAddArc(context, rect.origin.x + cornerRadius, rect.origin.y + rect.size.height - cornerRadius, cornerRadius, kPI/2, kPI, 0);
    if (arrowDirectionLeft) {
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + arrowPointY + arrowWidth/2);
        CGContextAddLineToPoint(context, rect.origin.x - arrowHeight, rect.origin.y + arrowPointY);
        CGContextAddLineToPoint(context, rect.origin.x, rect.origin.y + arrowPointY - arrowWidth/2);
    }
}

#pragma mark - scroll view
+ (void)scrollViewToRect:(UIScrollView *)scrollView toRect:(CGRect)toRect
{
    [scrollView setContentOffset:CGPointMake(toRect.origin.x, toRect.origin.y) animated:YES];  
    [scrollView scrollRectToVisible:CGRectMake(toRect.origin.x, toRect.origin.y, scrollView.frame.size.width, scrollView.frame.size.height) animated:YES];
    scrollView.contentSize = CGSizeMake(toRect.size.width, toRect.size.height);
}

+ (void)autoImageViewHeight:(UIImageView*)imageView {
    [imageView setHeight:imageView.frame.size.width * imageView.image.size.height / imageView.image.size.width];
}

@end
