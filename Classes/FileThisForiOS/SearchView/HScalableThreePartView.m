//
//  HScalableThreePartView.m
//  FileThis
//
//  Created by Cuong Le on 1/17/14.
//
//

#import "HScalableThreePartView.h"

@interface HScalableThreePartView ()
@property (nonatomic, strong) UILabel *textLabel, *rightTextLabel;
@property (nonatomic, strong) HScalableThreePartBackgroundView *hScalableThreePartBackgroundView;
@end

@implementation HScalableThreePartView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.hScalableThreePartBackgroundView = [[HScalableThreePartBackgroundView alloc] initWithFrame:self.bounds leftImage:[UIImage imageNamed:@"tag_bg_white_left.png"] centerImage:[UIImage imageNamed:@"tag_bg_white_center.png"] rightImage:[UIImage imageNamed:@"tag_bg_white_right.png"] superView:self];
        self.textLabel = [CommonLayout createLabel:self.hScalableThreePartBackgroundView.contentView.frame font:kTagCollectionCell_Font textColor:kTextGrayColor backgroundColor:nil text:@"" superView:self];
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.adjustsFontSizeToFitWidth = YES;
        self.textLabel.minimumScaleFactor = 0.75;
        
        self.rightTextLabel = [CommonLayout createLabel:self.hScalableThreePartBackgroundView.rightBackgroundView.frame font:kTagCollectionCell_Font textColor:kTextGrayColor backgroundColor:nil text:@"" superView:self];
        self.rightTextLabel.textAlignment = NSTextAlignmentCenter;
        self.rightTextLabel.adjustsFontSizeToFitWidth = YES;
        self.rightTextLabel.minimumScaleFactor = 0.75;
    }
    return self;
}

- (void)setText:(NSString*)aText backgroundType:(TagCollectionCellBackgroundType)backgroundType {
    [self setText:aText rightText:@"" backgroundType:backgroundType];
}

- (void)setText:(NSString*)aText rightText:(NSString*)aRightText backgroundType:(TagCollectionCellBackgroundType)backgroundType {
    self.hScalableThreePartBackgroundView.frame = self.bounds;
    if (backgroundType == TagCollectionCellBackgroundTypeTagOrangeX) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"tag_bg_orange_left.png"] centerImage:[UIImage imageNamed:@"tag_bg_orange_center.png"] rightImage:[UIImage imageNamed:@"tag_bg_orange_right_x.png"]];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = kTagCollectionCell_ItalicFont;
    } else if (backgroundType == TagCollectionCellBackgroundTypeTagOrange) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"tag_bg_orange_left.png"] centerImage:[UIImage imageNamed:@"tag_bg_orange_center.png"] rightImage:[UIImage imageNamed:@"tag_bg_orange_right_tail.png"]];
        self.textLabel.textColor = [UIColor whiteColor];
        self.textLabel.font = kTagCollectionCell_ItalicFont;
    } else if (backgroundType == TagCollectionCellBackgroundTypeTagWhite) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"tag_bg_white_left.png"] centerImage:[UIImage imageNamed:@"tag_bg_white_center.png"] rightImage:[UIImage imageNamed:@"tag_bg_white_right_tail.png"]];
        self.textLabel.textColor = kTextGrayColor;
        self.textLabel.font = kTagCollectionCell_ItalicFont;
    } else if (backgroundType == TagCollectionCellBackgroundTypeCabinetX) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"cabinet_bg_gray_left.png"] centerImage:[UIImage imageNamed:@"cabinet_bg_gray_center.png"] rightImage:[UIImage imageNamed:@"cabinet_bg_gray_right_x.png"]];
        self.textLabel.textColor = kTextOrangeColor;
        self.textLabel.font = kTagCollectionCell_Font;
    } else if (backgroundType == TagCollectionCellBackgroundTypeCabinet) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"cabinet_bg_gray_left.png"] centerImage:[UIImage imageNamed:@"cabinet_bg_gray_center.png"] rightImage:[UIImage imageNamed:@"cabinet_bg_gray_right.png"]];
        self.textLabel.textColor = kTextOrangeColor;
        self.textLabel.font = kTagCollectionCell_Font;
    } else if (backgroundType == TagCollectionCellBackgroundTypeProfileX) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"account_bg_gray_left.png"] centerImage:[UIImage imageNamed:@"cabinet_bg_gray_center.png"] rightImage:[UIImage imageNamed:@"cabinet_bg_gray_right_x.png"]];
        self.textLabel.textColor = kTextOrangeColor;
        self.textLabel.font = kTagCollectionCell_Font;
    } else if (backgroundType == TagCollectionCellBackgroundTypeProfile) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"account_bg_gray_left.png"] centerImage:[UIImage imageNamed:@"cabinet_bg_gray_center.png"] rightImage:[UIImage imageNamed:@"cabinet_bg_gray_right.png"]];
        self.textLabel.textColor = kTextOrangeColor;
        self.textLabel.font = kTagCollectionCell_Font;
    } else if (backgroundType == TagCollectionCellBackgroundTypeTextX) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"rect_bg_gray_left.png"] centerImage:[UIImage imageNamed:@"rect_bg_gray_center.png"] rightImage:[UIImage imageNamed:@"rect_bg_gray_right_x.png"]];
        self.textLabel.textColor = kTextGrayColor;
        self.textLabel.font = kTagCollectionCell_Font;
    } else if (backgroundType == TagCollectionCellBackgroundTypeText) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"rect_bg_gray_left.png"] centerImage:[UIImage imageNamed:@"rect_bg_gray_center.png"] rightImage:[UIImage imageNamed:@"rect_bg_gray_right.png"]];
        self.textLabel.textColor = kTextGrayColor;
        self.textLabel.font = kTagCollectionCell_Font;
    } else if (backgroundType == TagCollectionCellBackgroundTypeDateX) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"date_bg_left.png"] centerImage:[UIImage imageNamed:@"date_bg_center.png"] rightImage:[UIImage imageNamed:@"date_bg_right_x.png"]];
        self.textLabel.textColor = kTextGrayColor;
        self.textLabel.font = kTagCollectionCell_Font;
    } else if (backgroundType == TagCollectionCellBackgroundTypeDate) {
        [self.hScalableThreePartBackgroundView setLeftImage:[UIImage imageNamed:@"date_bg_left.png"] centerImage:[UIImage imageNamed:@"date_bg_center.png"] rightImage:[UIImage imageNamed:@"date_bg_right.png"]];
        self.textLabel.textColor = kTextGrayColor;
        self.textLabel.font = kTagCollectionCell_Font;
    } else {
        [self.hScalableThreePartBackgroundView setLeftImage:nil centerImage:nil rightImage:nil];
        self.textLabel.textColor = kTextGrayColor;
        self.textLabel.font = kTagCollectionCell_Font;
    }
    
    self.textLabel.frame = self.hScalableThreePartBackgroundView.contentView.frame;
    self.textLabel.text = aText;
    
    self.rightTextLabel.frame = self.hScalableThreePartBackgroundView.rightBackgroundView.frame;
    self.rightTextLabel.textColor = self.textLabel.textColor;
    self.rightTextLabel.text = aRightText;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (CGSize)fitSizeForText:(NSString*)text backgroundType:(TagCollectionCellBackgroundType)backgroundType {
    float ext;
    switch (backgroundType) {
        case TagCollectionCellBackgroundTypeTagOrangeX:
            ext = 50.0;
            break;
        case TagCollectionCellBackgroundTypeTagOrange:
            ext = 55.0;
            break;
        case TagCollectionCellBackgroundTypeTagWhite:
            ext = 55.0;
            break;
        case TagCollectionCellBackgroundTypeCabinetX:
        case TagCollectionCellBackgroundTypeProfileX:
            ext = 60.0;
            break;
        case TagCollectionCellBackgroundTypeCabinet:
        case TagCollectionCellBackgroundTypeProfile:
            ext = 45.0;
            break;
        case TagCollectionCellBackgroundTypeTextX:
            ext = 45.0;
            break;
        case TagCollectionCellBackgroundTypeText:
            ext = 25.0;
            break;
        case TagCollectionCellBackgroundTypeDateX:
            ext = 70.0;
            break;
        case TagCollectionCellBackgroundTypeDate:
            ext = 55.0;
            break;
        default:
            ext = 15.0;
            break;
    }
    CGSize fitSize = [text sizeWithFont:kTagCollectionCell_Font constrainedToSize:CGSizeMake(kTagCollectionCell_MaxWidth, 1000)];
    return CGSizeMake(fitSize.width + ext, kTagCollectionCell_Height);
}
#pragma GCC diagnostic pop

@end
