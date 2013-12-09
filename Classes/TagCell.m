//
//  TagCell.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "TagCell.h"
#import "Layout.h"
#import "Constants.h"

@implementation TagCell
@synthesize lblName;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageCheck:(UIImage*)imgCheck {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        tagData_ = nil;
        // Initialization code
        imvCheck = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width - 20, 8, 15, 16)];
        imvCheck.image = imgCheck;
        imvCheck.hidden = YES;
        [self addSubview:imvCheck];
        
        lblName = [[UILabel alloc] initWithFrame:[Layout CGRectResize:self.frame newHeight:kTagCellHeight-1]];
        lblName.font = [UIFont boldSystemFontOfSize:kFontSizeLarge];
        lblName.backgroundColor = [UIColor clearColor];
        lblName.textColor = [UIColor whiteColor];
        [self addSubview:lblName];
        
        lblCount = [[UILabel alloc] initWithFrame:[Layout CGRectResize:self.frame newHeight:kTagCellHeight-1]];
        lblCount.font = [UIFont boldSystemFontOfSize:kFontSizeLarge];
        lblCount.backgroundColor = [UIColor clearColor];
        lblCount.textColor = [UIColor whiteColor];
        [self addSubview:lblCount];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    //[super setSelected:selected animated:animated];
    // Configure the view for the selected state
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

- (BOOL)changeCheck {
    imvCheck.hidden = !imvCheck.hidden;
    [self displayCheck];
    if (imvCheck.hidden) {
        return NO;
    } else { 
        return YES;
    }
}

- (void)displayCheck {
    if (imvCheck.hidden) {
        lblName.textColor = [UIColor whiteColor];
        lblCount.textColor = [UIColor whiteColor];
    } else {
        lblName.textColor = kColorMyOrange;
        lblCount.textColor = kColorMyOrange;
    }
    [self setNeedsDisplay];
}

- (void)setCheck:(BOOL)checked {
    if (imvCheck.hidden == checked) {
        imvCheck.hidden = !checked;
        [self displayCheck];
    }
}

- (TagData*)tagData {
    return tagData_;
}

- (void)setTagData:(TagData*)value {
    if (tagData_ != value) {
        tagData_ = value;
    }
    lblName.text = [NSString stringWithFormat:@"   %@", tagData_.sTagName];
    [self setCount:tagData_.iDocCount];
}
@end
