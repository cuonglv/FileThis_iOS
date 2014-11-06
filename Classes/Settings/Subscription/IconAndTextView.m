//
//  IconAndTextView.m
//  FileThis
//
//  Created by Cao Huu Loc on 3/11/14.
//
//

#import "IconAndTextView.h"
#import "Constants.h"
#import "CommonLayout.h"

@implementation IconAndTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeControl];
    }
    return self;
}

- (void)initializeControl {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self configureForIPad];
    } else {
        [self configureForIPhone];
    }
    
    self.backgroundColor = [UIColor clearColor];
    CGRect rect = CGRectMake(self.leftIconMargin, self.topTextMargin, self.iconSize.width, self.iconSize.height);
    UIImageView *imgview = [[UIImageView alloc] initWithFrame:rect];
    self.iconImage = imgview;
    [self addSubview:imgview];
    
    rect = CGRectMake(self.leftTextMargin, self.topTextMargin, self.bounds.size.width - self.leftTextMargin - self.rightTextMargin, 24);
    UILabel *label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kGrayColor;
    label.font = [self fontForLabel1];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    self.lblText1 = label;
    [self addSubview:label];
    
    rect = CGRectMake(self.leftTextMargin, [self.lblText1 bottom] + self.spaceTextElement, self.bounds.size.width - self.leftTextMargin - self.rightTextMargin, 24);
    label = [[UILabel alloc] initWithFrame:rect];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = kGrayColor;
    label.font = [self fontForLabel2];
    label.textAlignment = NSTextAlignmentLeft;
    label.numberOfLines = 0;
    self.lblText2 = label;
    [self addSubview:label];
}

- (void)configureForIPhone {
    self.iconSize = CGSizeMake(52, 52);
    self.leftIconMargin = 15;
    self.leftTextMargin = 15; //self.leftTextMargin = 78;
    self.rightTextMargin = 15;
    self.topTextMargin = 15;
    self.bottomTextMargin = 15;
    self.spaceTextElement = 8;
}

- (void)configureForIPad {
    self.iconSize = CGSizeMake(52, 52);
    self.leftIconMargin = 15;
    self.leftTextMargin = 40; //self.leftTextMargin = 104;
    self.rightTextMargin = 40;
    self.topTextMargin = 15;
    self.bottomTextMargin = 15;
    self.spaceTextElement = 8;
}

- (UIFont*)fontForLabel1 {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return [CommonLayout getFont:FontSizeXSmall isBold:YES isItalic:NO];
    return [CommonLayout getFont:FontSizeMedium isBold:YES isItalic:NO];
}

- (UIFont*)fontForLabel2 {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return [CommonLayout getFont:FontSizexXSmall isBold:NO isItalic:YES];
    return [CommonLayout getFont:FontSizeSmall isBold:NO isItalic:YES];
}

#pragma mark - Draw
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetLineWidth(context, 1.5);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:228/255.0 green:227/255.0 blue:230/255.0 alpha:1].CGColor);
    
    CGContextMoveToPoint(context, 0, self.bounds.size.height);
    CGContextAddLineToPoint(context, self.bounds.size.width, self.bounds.size.height);
    CGContextStrokePath(context);
}

#pragma mark - Public methods
- (void)setIcon:(UIImage*)icon text1:(NSString*)text1 text2:(NSString*)text2 {
    self.iconImage.image = icon;
    self.lblText1.text = text1;
    self.lblText2.text = text2;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)resizeByWidth:(float)width {
    CGRect rect;
    
    float textWidth = width - self.leftTextMargin - self.rightTextMargin;
    CGSize size = [self.lblText1.text sizeWithFont:self.lblText1.font constrainedToSize:CGSizeMake(textWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    rect = self.lblText1.frame;
    rect.size.width = size.width;
    rect.size.height = size.height;
    self.lblText1.frame = rect;
    
    size = [self.lblText2.text sizeWithFont:self.lblText2.font constrainedToSize:CGSizeMake(textWidth, 1000) lineBreakMode:NSLineBreakByWordWrapping];
    self.lblText2.frame = CGRectMake(self.leftTextMargin, [self.lblText1 bottom] + self.spaceTextElement, size.width, size.height);
    
    float bottomImage = [self.iconImage bottom];
    float bottomText = [self.lblText2 bottom];
    float heightView;
    if (bottomText > bottomImage) {
        heightView = bottomText + self.bottomTextMargin;
    } else {
        heightView = bottomImage + self.bottomTextMargin;
        
        float heightText = [self.lblText2 bottom] - [self.lblText1 top];
        float top = (heightView - heightText) / 2.0;
        [self.lblText1 setTop:top];
        [self.lblText2 setTop:[self.lblText1 bottom] + self.spaceTextElement];
    }
    
    rect = self.frame;
    rect.size.width = width;
    rect.size.height = heightView;
    self.frame = rect;
}
#pragma GCC diagnostic pop

@end
