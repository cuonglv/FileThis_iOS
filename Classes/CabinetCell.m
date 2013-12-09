//
//  CabinetCell.m
//  FTMobileApp
//
//  Created by decuoi on 11/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "CabinetCell.h"
#import "Layout.h"
#import "CommonFunc.h"

@implementation CabinetCell
@synthesize imvBackground, lblName, lblCount, blnIsSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier backgroundImg:(UIImage*)img {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        imvBackground = [[UIImageView alloc] initWithFrame:[Layout CGRectResize:self.frame newHeight:kCabCellHeight-1]];
        imvBackground.contentMode = UIViewContentModeScaleToFill;
        imvBackground.image = img;
        [self addSubview:imvBackground];
        
        lblName = [[UILabel alloc] initWithFrame:[Layout CGRectResize:self.frame newHeight:kCabCellHeight-1]];
        lblName.font = [UIFont boldSystemFontOfSize:kFontSizeLarge];
        lblName.backgroundColor = [UIColor clearColor];
        [self addSubview:lblName];
        
        lblCount = [[UILabel alloc] initWithFrame:[Layout CGRectResize:self.frame newHeight:kCabCellHeight-1]];
        lblCount.font = [UIFont boldSystemFontOfSize:kFontSizeLarge];
        lblCount.backgroundColor = [UIColor clearColor];
        [self addSubview:lblCount];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    self.accessoryType = (selected ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone);
}


- (void)setCabType:(NSString *)cabType {
    sCabType = cabType;
    imvBackground.image = [CommonFunc getCabBackgroundImageByType:sCabType];
}

- (void)setCount:(int)count {
    if (count >= 0) {
        lblCount.text = [NSString stringWithFormat:@"%i",count];
    } else {
        lblCount.text = @"";
    }
    CGSize sizeFit = [lblCount sizeThatFits:CGSizeZero];
    lblCount.frame = CGRectMake(self.frame.size.width - 25 - sizeFit.width, 0, sizeFit.width, kCabCellHeight);
    lblName.frame = [Layout CGRectResize:lblName.frame newWidth:lblCount.frame.origin.x - 2];
}
@end
