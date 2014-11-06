//
//  WhiteRoundRectPopupView.m
//  FileThis
//
//  Created by Cuong Le on 3/4/14.
//
//

#import <QuartzCore/QuartzCore.h>
#import "WhiteRoundRectPopupView.h"
#import "CommonLayout.h"

@implementation WhiteRoundRectPopupView

- (id)initWithSize:(CGSize)size titleOfPopup:(NSString*)titleOfPopup titleOfLeftButton:(NSString*)titleOfLeftButton titleOfRightButton:(NSString*)titleOfRightButton superView:(UIView*)superView delegate:(id<WhiteRoundRectPopupViewDelegate>)delegate {
    if (self = [super initWithFrame:[superView bounds]]) {
        self.delegate = delegate;
        
        self.darkBackView = [[UIView alloc] initWithFrame:[self bounds]];
        self.darkBackView.backgroundColor = [UIColor blackColor];
        self.darkBackView.alpha = 0.5f;
        [self addSubview:self.darkBackView];
        
        self.contentView = [[UIView alloc] initWithFrame:CGRectMake(superView.frame.size.width/2-size.width/2, superView.frame.size.height/2-size.height/2, size.width, size.height)];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.cornerRadius = 6;
        self.contentView.clipsToBounds = YES;
        [self addSubview:self.contentView];
        
        self.titleLabel = [CommonLayout createLabel:CGRectMake(0, 0, self.contentView.frame.size.width, 50) fontSize:FontSizeLarge isBold:YES isItalic:NO textColor:kTextGrayColor backgroundColor:nil text:titleOfPopup superView:self.contentView];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.leftButton = [CommonLayout createTextButton:CGRectMake(0, self.contentView.frame.size.height-45, self.contentView.frame.size.width/2, 45) fontSize:FontSizeMedium isBold:NO text:titleOfLeftButton textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleLeftButton) superView:self.contentView];
        self.rightButton = [CommonLayout createTextButton:[self.leftButton rectAtRight:-1 width:self.leftButton.frame.size.width+1] fontSize:FontSizeMedium isBold:YES text:titleOfRightButton textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleRightButton) superView:self.contentView];
        self.layer.borderColor = self.leftButton.layer.borderColor = self.rightButton.layer.borderColor = kBorderLightGrayColor.CGColor;
        self.layer.borderWidth = self.leftButton.layer.borderWidth = self.rightButton.layer.borderWidth = 1.0;
        [superView addSubview:self];
    }
    return self;
}

- (void)handleLeftButton {
    if ([self.delegate respondsToSelector:@selector(whiteRoundRectPopupView_ShouldCloseWithLeftButtonTouched:)])
        [self.delegate whiteRoundRectPopupView_ShouldCloseWithLeftButtonTouched:self];
    
    [self removeFromSuperview];
}

- (void)handleRightButton {
    if ([self.delegate respondsToSelector:@selector(whiteRoundRectPopupView_ShouldCloseWithLeftButtonTouched:)])
        [self.delegate whiteRoundRectPopupView_ShouldCloseWithRightButtonTouched:self];
}

@end
