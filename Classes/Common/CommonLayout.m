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

@implementation CommonLayout

static NSString *fontNameRegular_ = @"Merriweather";
static NSString *fontNameBold_ = @"Merriweather-Bold";
static NSString *fontNameItalic_ = @"Merriweather-Italic";
static NSString *fontNameBoldItalic_ = @"Merriweather-BoldItalic";

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
+ (UIImageView*)createImageView:(CGRect)frame image:(UIImage*)image contentMode:(UIViewContentMode)contentMode superView:(UIView*)superView {
    UIImageView *imv = [[UIImageView alloc] initWithFrame:frame];
    imv.image = image;
    imv.contentMode = contentMode;
    [superView addSubview:imv];
    return imv;
}

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
    return [CommonLayout createLabel:frame font:[CommonLayout getFont:fontSize isBold:isBold] textColor:textColor backgroundColor:backgroundColor text:text superView:superView];
}

+ (UILabel*)createLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView {
    return [CommonLayout createLabel:frame font:[CommonLayout getFont:fontSize isBold:isBold isItalic:isItalic] textColor:textColor backgroundColor:backgroundColor text:text superView:superView];
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
    return [CommonLayout createTopAlignedLabel:frame font:[CommonLayout getFont:fontSize isBold:isBold] textColor:textColor backgroundColor:backgroundColor text:text superView:superView numberOfLines:numberOfLines];
}

+ (TopAlignedLabel*)createTopAlignedLabel:(CGRect)frame fontSize:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic textColor:(UIColor*)textColor backgroundColor:(UIColor*)backgroundColor text:(NSString*)text superView:(UIView*)superView numberOfLines:(int)numberOfLines {
    return [CommonLayout createTopAlignedLabel:frame font:[CommonLayout getFont:fontSize isBold:isBold isItalic:isItalic] textColor:textColor backgroundColor:backgroundColor text:text superView:superView numberOfLines:numberOfLines];
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
    return [CommonLayout createOffsetLabel:frame font:[CommonLayout getFont:fontSize isBold:isBold] textColor:textColor backgroundColor:backgroundColor text:text offset:offset borderColor:borderColor borderWidths:borderWidths superView:superView];
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
    return [CommonLayout createOffsetLabel:frame font:[CommonLayout getFont:fontSize isBold:isBold] textColor:textColor backgroundColor:backgroundColor text:text offset:offset borderColor:nil borderWidths:OffsetZero() superView:superView];
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
    UIButton *button = [CommonLayout createImageButton:frame font:[CommonLayout getFont:fontSize isBold:isBold] textColor:textColor backgroundImage:backgroundImage text:text touchTarget:target touchSelector:selector superView:superView];
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

+ (UIButton*)createTextImageButton:(CGRect)frame text:(NSString*)text fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor icon:(UIImage*)icon iconSize:(CGSize)iconSize offsetBetweenTextAndIcon:(float)offsetBetweenTextAndIcon iconLeftOffset:(float)iconLeftOffset backgroundImage:(UIImage*)backgroundImage touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    return [CommonLayout createTextImageButton:frame text:text font:[CommonLayout getFont:fontSize isBold:isBold] textColor:textColor icon:icon iconSize:iconSize offsetBetweenTextAndIcon:offsetBetweenTextAndIcon iconLeftOffset:iconLeftOffset backgroundImage:backgroundImage touchTarget:target touchSelector:selector superView:superView];
}

+ (UIButton*)createTextImageButton:(CGRect)frame text:(NSString*)text font:(UIFont*)font textColor:(UIColor*)textColor icon:(UIImage*)icon iconSize:(CGSize)iconSize offsetBetweenTextAndIcon:(float)offsetBetweenTextAndIcon iconLeftOffset:(float)iconLeftOffset backgroundImage:(UIImage*)backgroundImage touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button.imageView setContentMode:UIViewContentModeScaleToFill];
    [button setImage:backgroundImage forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:button];
    button.clipsToBounds = YES;
    
    UIImageView *imv = [CommonLayout createImageView:CGRectMake(0, roundf(frame.size.height/2-iconSize.height/2), iconSize.width, iconSize.height) image:icon contentMode:UIViewContentModeScaleAspectFit superView:button];
    UILabel *label = [CommonLayout createLabel:[imv rectAtRight:offsetBetweenTextAndIcon width:70 height:frame.size.height] font:font textColor:textColor backgroundColor:nil text:text superView:button];
    [label autoWidth];
    if (iconLeftOffset != 0) {
        [imv moveLeft:-iconLeftOffset];
        [label moveLeft:-iconLeftOffset];
    }
    [CommonLayout moveViewsToHorizontalCenterOfSuperView:[NSArray arrayWithObjects:imv,label,nil]];
    
    return button;
}

+ (UIButton*)createVerticalTextImageButton:(CGRect)frame text:(NSString*)text font:(UIFont*)font textColor:(UIColor*)textColor icon:(UIImage*)icon iconSize:(CGSize)iconSize offsetBetweenTextAndIcon:(float)offsetBetweenTextAndIcon backgroundImage:(UIImage*)backgroundImage touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button.imageView setContentMode:UIViewContentModeScaleToFill];
    [button setImage:backgroundImage forState:UIControlStateNormal];
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    [superView addSubview:button];
    button.clipsToBounds = YES;
    
    UIImageView *imv = [CommonLayout createImageView:CGRectMake(frame.size.width/2-iconSize.width/2, 8, iconSize.width, iconSize.height) image:icon contentMode:UIViewContentModeScaleAspectFit superView:button];
    UILabel *label = [CommonLayout createLabel:[imv rectAtBottom:offsetBetweenTextAndIcon width:70 height:frame.size.height-iconSize.height-offsetBetweenTextAndIcon-4] font:font textColor:textColor backgroundColor:nil text:text superView:button];
    [label autoWidth];
    [label moveToHorizontalCenterOfSuperView];
    
    return button;
}

+ (UIButton*)createVerticalTextImageButton:(CGRect)frame text:(NSString*)text fontSize:(FontSize)fontSize isBold:(BOOL)isBold textColor:(UIColor*)textColor icon:(UIImage*)icon iconSize:(CGSize)iconSize offsetBetweenTextAndIcon:(float)offsetBetweenTextAndIcon backgroundImage:(UIImage*)backgroundImage touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    return [CommonLayout createVerticalTextImageButton:frame text:text font:[CommonLayout getFont:fontSize isBold:isBold] textColor:textColor icon:icon iconSize:iconSize offsetBetweenTextAndIcon:offsetBetweenTextAndIcon backgroundImage:backgroundImage touchTarget:target touchSelector:selector superView:superView];
}

#pragma mark - Button
+ (UIButton*)createTextButton:(CGRect)frame font:(UIFont*)font text:(NSString*)text textColor:(UIColor*)textColor backColor:(UIColor*)backColor borderColor:(UIColor*)borderColor cornerRadius:(float)cornerRadius touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];
    [button.titleLabel setFont:font];
    
    if (textColor)
        [button setTitleColor:textColor forState:UIControlStateNormal];
    else
        [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    
    if (backColor)
        button.backgroundColor = backColor;
    
    if (borderColor) {
        button.layer.borderWidth = 1.0;
        button.layer.borderColor = borderColor.CGColor;
    }
    
    if (cornerRadius > 0)
        button.layer.cornerRadius = cornerRadius;
    
    [button setTitle:text forState:UIControlStateNormal];
    
    [button addTarget:target action:selector forControlEvents:UIControlEventTouchUpInside];
    
    [superView addSubview:button];
    
    return button;
}

+ (UIButton*)createTextButton:(CGRect)frame font:(UIFont*)font text:(NSString*)text textColor:(UIColor*)textColor touchTarget:(id)target touchSelector:(SEL)selector superView:(UIView*)superView {
    return [self createTextButton:frame font:font text:text textColor:textColor backColor:nil borderColor:nil cornerRadius:0 touchTarget:target touchSelector:selector superView:superView];
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
    return [CommonLayout createTextField:frame font:[CommonLayout getFont:fontSize isBold:isBold] textColor:textColor backgroundColor:backgroundColor text:text superView:superView];
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
    return [CommonLayout createTextView:frame font:[CommonLayout getFont:fontSize isBold:isBold] textColor:textColor backgroundColor:backgroundColor text:text superView:superView delegate:delegate];
}

+ (UICollectionView*)createCollectionView:(CGRect)frame backgroundColor:(UIColor*)backgroundColor layout:(UICollectionViewLayout*)layout cellClass:(Class)cellClass cellIdentifier:(NSString*)cellIdentifier superView:(UIView*)superView delegateDataSource:(id<UICollectionViewDataSource,UICollectionViewDelegate>)delegate {
    UICollectionView *ret;
    ret = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    ret.dataSource = delegate;
    ret.delegate = delegate;
    [ret registerClass:cellClass forCellWithReuseIdentifier:cellIdentifier];
    ret.backgroundColor = backgroundColor;
    [superView addSubview:ret];
    return ret;
}

+ (UICollectionView*)createCollectionViewWithFlowLayout:(CGRect)frame backgroundColor:(UIColor*)backgroundColor cellClass:(Class)cellClass cellIdentifier:(NSString*)cellIdentifier superView:(UIView*)superView delegateDataSource:(id<UICollectionViewDataSource,UICollectionViewDelegate>)delegate {
    UICollectionView *ret;
    UICollectionViewFlowLayout *layout= [[LeftAlignedCollectionViewFlowLayout alloc] init];
    ret = [[UICollectionView alloc] initWithFrame:frame collectionViewLayout:layout];
    ret.dataSource = delegate;
    ret.delegate = delegate;
    [ret registerClass:cellClass forCellWithReuseIdentifier:cellIdentifier];
    ret.backgroundColor = backgroundColor;
    [superView addSubview:ret];
    return ret;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (UISegmentedControl*)createSegmentControl:(CGRect)frame texts:(NSArray*)texts font:(UIFont*)font tintColor:(UIColor*)tintColor target:(id)target selector:(SEL)selector superView:(UIView*)superView {
    UISegmentedControl *segmentControl = [[UISegmentedControl alloc] initWithItems:texts];
    [segmentControl setFrame:frame];
    [segmentControl setTitleTextAttributes:@{UITextAttributeFont : font} forState:UIControlStateNormal];
    [segmentControl setTintColor:tintColor];
    [segmentControl addTarget:target action:selector forControlEvents:UIControlEventValueChanged];
    [superView addSubview:segmentControl];
    return segmentControl;
}
#pragma GCC diagnostic pop

#pragma mark - Font
+ (UIFont*)getFont:(FontSize)fontSize isBold:(BOOL)isBold {
    return [CommonLayout getFont:fontSize isBold:isBold isItalic:NO];
}

+ (UIFont*)getFont:(FontSize)fontSize isBold:(BOOL)isBold isItalic:(BOOL)isItalic {
    return [CommonLayout getFontWithSize:fontSize isBold:isBold isItalic:isItalic];
}

+ (UIFont*)getFontWithSize:(float)size isBold:(BOOL)isBold {
    return [CommonLayout getFontWithSize:size isBold:isBold isItalic:NO];
}

+ (UIFont*)getFontWithSize:(float)size isBold:(BOOL)isBold isItalic:(BOOL)isItalic {
    if (isBold) {
        if (isItalic)
            return [UIFont fontWithName:fontNameBoldItalic_ size:size];
        else
            return [UIFont fontWithName:fontNameBold_ size:size];
    } else {
        if (isItalic)
            return [UIFont fontWithName:fontNameItalic_ size:size];
        else
            return [UIFont fontWithName:fontNameRegular_ size:size];
    }
}

#pragma mark - Alert
+ (void)showAlertMessageWithTitle:(NSString *)title content:(NSString *)content delegate:(id<UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    if ([NSThread isMainThread]) {
        [alert show];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
}

+ (void)showAlertMessageWithTitle:(NSString *)title content:(NSString *)content tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitle:(NSString *)otherButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    alert.tag = tag;
    if ([NSThread isMainThread]) {
        [alert show];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
}

+ (UIAlertView*)createAlertMessageWithTitle:(NSString *)title content:(NSString *)content delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitle {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:content delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:otherButtonTitle, nil];
    if ([NSThread isMainThread]) {
        [alert show];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
    return alert;
}

+ (void)showConfirmAlert:(NSString *)content tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ID_CONFIRM", @"") message:content delegate:delegate cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitles:NSLocalizedString(@"ID_CANCEL", @""), nil];
    alert.tag = tag;
    if ([NSThread isMainThread]) {
        [alert show];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
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
    if ([NSThread isMainThread]) {
        [alert show];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
}

+ (void)showInfoAlert:(NSString *)content delegate:(id<UIAlertViewDelegate>)delegate {
    [CommonLayout showInfoAlert:content tag:NSNotFound delegate:delegate];
}

+ (void)showInfoAlert:(NSString *)content tag:(int)tag delegate:(id<UIAlertViewDelegate>)delegate {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"ID_INFO", @"") message:content delegate:delegate cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitles:nil];
    alert.tag = tag;
    if ([NSThread isMainThread]) {
        [alert show];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [alert show];
        });
    }
}

#pragma mark - Other
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

#pragma mark - Subcontrols in view
//Loc Cao
+ (void)setFont:(UIFont*)font forClass:(Class)theClass inView:(UIView*)view
{
    for (UIView *sub in view.subviews)
    {
        if ([sub isKindOfClass:theClass])
        {
            if ([sub respondsToSelector:@selector(setFont:)])
            {
                [sub performSelector:@selector(setFont:) withObject:font];
            }
        }
        else
        {
            [self setFont:font forClass:theClass inView:sub];
        }
    }
}

+ (void)setFont:(UIFont*)font forClassesInList:(NSArray*)listClass inView:(UIView*)view
{
    for (Class theClass in listClass)
    {
        [self setFont:font forClass:theClass inView:view];
    }
}

+ (void)setTextColor:(UIColor*)color forClass:(Class)theClass inView:(UIView*)view
{
    for (UIView *sub in view.subviews)
    {
        if ([sub isKindOfClass:theClass])
        {
            if ([sub respondsToSelector:@selector(setTextColor:)])
            {
                [sub performSelector:@selector(setTextColor:) withObject:color];
            }
        }
        else
        {
            [self setTextColor:color forClass:theClass inView:sub];
        }
    }
}

+ (void)setTextColor:(UIColor*)color forClassesInList:(NSArray*)listClass inView:(UIView*)view
{
    for (Class theClass in listClass)
    {
        [self setTextColor:color forClass:theClass inView:view];
    }
}

+ (void)setAppFontForSubviewsOfView:(UIView*)view { //Cuong
    for (UIView *sub in view.subviews) {
        if ([sub respondsToSelector:@selector(setFont:)]) {
            UIFont *font = [sub performSelector:@selector(font) withObject:nil];
            NSString *fontName = font.fontName;
            BOOL isBold = ([fontName rangeOfString:@"bold" options:NSCaseInsensitiveSearch].location != NSNotFound);
            BOOL isItalic = ([fontName rangeOfString:@"italic" options:NSCaseInsensitiveSearch].location != NSNotFound);
            UIFont *replacedFont = [CommonLayout getFontWithSize:font.pointSize isBold:isBold isItalic:isItalic];
            [sub performSelector:@selector(setFont:) withObject:replacedFont];
        } else {
            [CommonLayout setAppFontForSubviewsOfView:sub];
        }
    }
}

#pragma mark - Unit convertion
+ (BOOL)compareFloatingValue:(float)v1 with:(float)v2 {
    float delta = fabsf(v1 - v2);
    if (delta < EPSILON_COMPARE_FLOATING)
        return YES;
    return NO;
}

+ (NSString*)storageTextFromKB:(long long)kb {
    return [self storageTextFromKB:kb decimalPlaces:0];
}

+ (NSString*)storageTextFromKB:(long long)kb decimalPlaces:(int)decimalPlaces {
    int devide = 1;
    NSString *unit = @"KB";
    if (kb >= KB_TO_GB_UNIT) {
        devide = KB_TO_GB_UNIT;
        unit = @"GB";
    } else if (kb >= KB_TO_MB_UNIT) {
        devide = KB_TO_MB_UNIT;
        unit = @"MB";
    }
    
    float converted = (float)kb / devide;
    NSString *ret = [NSString stringWithFormat:@"%0.*f %@", decimalPlaces, converted, unit];
    return ret;
}

@end
