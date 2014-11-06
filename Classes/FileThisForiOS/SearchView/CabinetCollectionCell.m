//
//  CabinetCollectionCell.m
//  FileThis
//
//  Created by Cuong Le on 12/31/13.
//
//

#import "CabinetCollectionCell.h"

@interface CabinetCollectionCell ()
@property (nonatomic, strong) UILabel *textLabel;
@end

@implementation CabinetCollectionCell

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.textLabel = [CommonLayout createLabel:self.bounds font:kCabinetCollectionCell_Font textColor:kCabinetCollectionCell_DarkColor backgroundColor:kCabinetCollectionCell_LightColor text:@"" superView:self];
        self.textLabel.layer.cornerRadius = 3.0;
        self.textLabel.layer.borderColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1.0].CGColor;
        self.textLabel.layer.borderWidth = 1.0;
        self.useDarkBackground = self.clearBackground = NO;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

- (void)setText:(NSString*)aText clearBackground:(BOOL)clearBackground useDarkBackColor:(BOOL)useDarkBackColor {
    self.clearBackground = clearBackground;
    self.useDarkBackground = useDarkBackColor;
    if (self.clearBackground) {
        self.textLabel.textColor = kTextGrayColor;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.font = kCabinetCollectionCell_TextOnlyFont;
        self.textLabel.layer.borderWidth = 0.0;
        self.textLabel.textAlignment = NSTextAlignmentLeft;
    } else if (self.useDarkBackground) {
        self.textLabel.textColor = kCabinetCollectionCell_LightColor;
        self.textLabel.backgroundColor = kCabinetCollectionCell_DarkColor;
        self.textLabel.font = kCabinetCollectionCell_Font;
        self.textLabel.layer.borderWidth = 1.0;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    } else {
        self.textLabel.textColor = kCabinetCollectionCell_DarkColor;
        self.textLabel.backgroundColor = kCabinetCollectionCell_LightColor;
        self.textLabel.font = kCabinetCollectionCell_Font;
        self.textLabel.layer.borderWidth = 1.0;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    self.textLabel.frame = self.bounds;
    self.textLabel.text = aText;
}

@end
