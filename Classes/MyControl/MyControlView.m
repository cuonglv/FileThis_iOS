//
//  MyControlView.m
//  GreatestRoad
//
//  Created by decuoi on 11/14/10.
//  Copyright 2010 Greatest Road Software. All rights reserved.
//

#import "MyControlView.h"
#import "Layout.h"
#import "Constants.h"
#import "CommonFunc.h"

@implementation MyLabel
@synthesize verticalAlignment = verticalAlignment_;

+ (id)newWithFrame:(CGRect)frame text:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor backColor:(UIColor *)backColor {
    MyLabel *ret = [[MyLabel alloc] initWithFrame:frame];
    ret.text = text;
    ret.font = font;
    ret.textColor = textColor;
    ret.backgroundColor = backColor;
    return ret;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        self.verticalAlignment = VerticalAlignmentMiddle;
    }
    return self;
}

- (void)setVerticalAlignment:(VerticalAlignment)verticalAlignment {
    verticalAlignment_ = verticalAlignment;
    [self setNeedsDisplay];
}

- (CGRect)textRectForBounds:(CGRect)bounds limitedToNumberOfLines:(NSInteger)numberOfLines {
    CGRect textRect = [super textRectForBounds:bounds limitedToNumberOfLines:numberOfLines];
    switch (self.verticalAlignment) {
        case VerticalAlignmentTop:
            textRect.origin.y = bounds.origin.y;
            break;
        case VerticalAlignmentBottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height;
            break;
        case VerticalAlignmentMiddle:
            // Fall through.
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) / 2.0;
    }
    return textRect;
}

-(void)drawTextInRect:(CGRect)requestedRect {
    CGRect actualRect = [self textRectForBounds:requestedRect limitedToNumberOfLines:self.numberOfLines];
    [super drawTextInRect:actualRect];
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


- (void)saveStableOrigin {
    stableOrigin = self.frame.origin;
}

- (void)moveToStableOrigin {
    self.frame = CGRectMake(stableOrigin.x, stableOrigin.y, self.frame.size.width, self.frame.size.height);
}
@end

#pragma mark -
@implementation MyTextField

+ (id)newWithFrame:(CGRect)frame placeHolder:(NSString *)text font:(UIFont *)font textColor:(UIColor *)textColor {
    MyTextField *ret = [[MyTextField alloc] initWithFrame:frame];
    ret.placeholder = text;
    ret.font = font;
    ret.textColor = textColor;
    ret.borderStyle = UITextBorderStyleRoundedRect;
    ret.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    return ret;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        maxLength = 0;
    }
    return self;
}


#pragma mark Public Func
- (void)saveStableOrigin {
    stableOrigin = self.frame.origin;
}

- (void)moveToStableOrigin {
    self.frame = CGRectMake(stableOrigin.x, stableOrigin.y, self.frame.size.width, self.frame.size.height);
}

#pragma mark Max Length
- (void)setMaxLength:(int)maxlength alert:(NSString *)message {
    maxLength = maxlength;
    maxLengthAlertMessage = [message copy];
}

- (void)setStandardMaxLength:(int)maxlength alert:(NSString *)localizedMessage {
    maxLength = maxlength;
    maxLengthAlertMessage = [NSString stringWithFormat:NSLocalizedString(localizedMessage,@""),maxlength];
}

#pragma mark Exceptional Chars
- (void)setExceptionalChars:(NSString *)stringOfChars alert:(NSString *)message {
    sExceptionalCharString = [stringOfChars copy];
    sExceptionalCharsAlertMessage = [message copy];
}

- (void)setDefaultExceptionalChars {
    sExceptionalCharString = kExceptionalCharacters;
    sExceptionalCharsAlertMessage = NSLocalizedString(@"ID_COMMON_TEXT_ALERT_EXCEPTIONALCHARS",@"");
}

#pragma mark Handle Text Event
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //NSLog(@"Change text: %@",string);
    if (maxLength > 0) {
        if ( ([self.text length] + string.length > maxLength) && range.length == 0) {
            [Layout alertWarning:maxLengthAlertMessage delegate:nil];
            return NO;
        }
    }
    //NSLog(@"Exceptional String: %@", sExceptionalCharString);
    if (sExceptionalCharString) {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:sExceptionalCharString]].length > 0) {
            [Layout alertWarning:sExceptionalCharsAlertMessage delegate:nil];
            return NO;
        }
    }
	return YES;
}

@end

#pragma mark -
@implementation MyTextView
@synthesize backgroundImageView;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */


#pragma mark Public Func
- (void)saveStableOrigin {
    stableOrigin = self.frame.origin;
}

- (void)moveToStableOrigin {
    self.frame = CGRectMake(stableOrigin.x, stableOrigin.y, self.frame.size.width, self.frame.size.height);
    if (backgroundImageView) {
        backgroundImageView.frame = self.frame;
    }
}

#pragma mark Max Length
- (void)setMaxLength:(int)maxlength alert:(NSString *)message {
    maxLength = maxlength;
    maxLengthAlertMessage = [message copy];
}

- (void)setStandardMaxLength:(int)maxlength alert:(NSString *)localizedMessage {
    maxLength = maxlength;
    maxLengthAlertMessage = [NSString stringWithFormat:NSLocalizedString(localizedMessage,@""),maxlength];
}

#pragma mark Exceptional Chars
- (void)setExceptionalChars:(NSString *)stringOfChars alert:(NSString *)message {
    sExceptionalCharString = [stringOfChars copy];
    sExceptionalCharsAlertMessage = [message copy];
}

- (void)setDefaultExceptionalChars {
    sExceptionalCharString = kExceptionalCharacters;
    sExceptionalCharsAlertMessage = NSLocalizedString(@"ID_COMMON_TEXT_ALERT_EXCEPTIONALCHARS",@"");
}

#pragma mark Virtual TextViewDelegate
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    if ( ([self.text length] + string.length > maxLength) && range.length == 0) {
		[Layout alertWarning:maxLengthAlertMessage delegate:nil];
		return NO;
	}
    if (sExceptionalCharString) {
        if ([string rangeOfCharacterFromSet:[NSCharacterSet characterSetWithCharactersInString:sExceptionalCharString]].length > 0) {
            [Layout alertWarning:sExceptionalCharsAlertMessage delegate:nil];
            return NO;
        }
    }
	return YES;
}

#pragma mark BackgroundImage
- (void)setBackgroundImage:(NSString *)imageFile {
    backgroundImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageFile]];
    backgroundImageView.frame = self.frame;
    self.backgroundColor = [UIColor clearColor];
    [self.superview addSubview:backgroundImageView];
    [self.superview sendSubviewToBack:backgroundImageView];
}

@end


#pragma mark -
@implementation MyLinkLabel

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = [UIColor clearColor];
        self.userInteractionEnabled = TRUE;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextSetStrokeColorWithColor(context, self.textColor.CGColor);
    CGContextStrokePath(context);
}


#pragma mark CommonFunc
- (void)setFont:(UIFont *)font text:(NSString *)text textColor:(UIColor *)textColor {
    self.font = font;
    self.text = text;
    self.textColor = textColor;
}
@end


@implementation MyLinkButton

- (id)initWithFrame:(CGRect)frame {
    self = [UIButton buttonWithType:UIButtonTypeCustom];
    self.frame = frame;
    self.backgroundColor = [UIColor clearColor];
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextMoveToPoint(context, 0, rect.size.height);
    CGContextAddLineToPoint(context, rect.size.width, rect.size.height);
    CGContextSetStrokeColorWithColor(context, self.titleLabel.textColor.CGColor);
    CGContextStrokePath(context);
}



#pragma mark CommonFunc
- (void)setFont:(UIFont *)font text:(NSString *)text textColor:(UIColor *)textColor {
    self.titleLabel.font = font;
    self.titleLabel.text = text;
    self.titleLabel.textColor = textColor;
}

- (void)saveStableOrigin {
    stableOrigin = self.frame.origin;
}

- (void)moveToStableOrigin {
    self.frame = CGRectMake(stableOrigin.x, stableOrigin.y, self.frame.size.width, self.frame.size.height);
}
@end


/*
@implementation MyBackBarButton

+ (id)initWithTitle:(NSString *)title imageName:(NSString *)imageName target:(id)target action:(SEL)action {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    [button sizeToFit];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
	
	MyLabel *label = [MyLabel newWithFrame:CGRectMake(6, 0, 1, 1) text:title font:[UIFont boldSystemFontOfSize:12] textColor:[UIColor whiteColor] backColor:[UIColor clearColor]];
    label.textAlignment = UITextAlignmentCenter;
    [label sizeToFit];
    label.frame = CGRectMake((button.frame.size.width - label.frame.size.width)/2, (button.frame.size.height - label.frame.size.height)/2, label.frame.size.width, label.frame.size.height);
    
	UIView *view = [[[UIView alloc] initWithFrame:button.frame] autorelease];
	[view addSubview:button];
	[view addSubview:label];
    [view sizeToFit];
    
    UIBarButtonItem *ret = [[UIBarButtonItem alloc] initWithCustomView:view];
    return ret;
}
@end*/
 