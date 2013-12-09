//
//  KeyValueCell.m
//  FTMobile
//
//  Created by decuoi on 12/17/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "KeyValueCell.h"
#import "Layout.h"
#import "Constants.h"


@implementation KeyValueCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier key:(NSString*)key value:(NSString*)value isValueAtBottom:(BOOL)isValueAtBottom drawAccessory:(BOOL)drawAccessory {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        if (!value) {
            value = @"-";
        }
        CGRect rect;
        if (drawAccessory) {
            rect = CGRectMake(16, 4, self.frame.size.width - 52, 30);
            self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        } else
            rect = CGRectMake(16, 4, self.frame.size.width - 36, 30);
        
        lblKey = [Layout labelWithFrame:rect text:key font:[UIFont boldSystemFontOfSize:18] textColor:[UIColor blackColor] backColor:[UIColor clearColor]];
        
        if (isValueAtBottom) {  //for first section
            rect = CGRectInset(rect, 0, 8);
            lblValue = [Layout labelWithFrame:[Layout CGRectMoveBy:rect dx:0 dy:20] text:value font:[UIFont systemFontOfSize:13] textColor:kColorLightSteelBlue backColor:[UIColor clearColor]];
        } else {    //for 2 next sections
            lblValue = [Layout labelWithFrame:rect text:value font:[UIFont systemFontOfSize:18] textColor:kColorLightSteelBlue backColor:[UIColor clearColor]];
            lblValue.textAlignment = NSTextAlignmentRight;
        }
        lblValue.text = value;
        
        [self addSubview:lblKey];
        [self addSubview:lblValue];
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    if (selected) {
        lblValue.textColor = [UIColor whiteColor];
    } else {
        lblValue.textColor = kColorLightSteelBlue;
    }

    // Configure the view for the selected state
}




- (void)setCellValue:(NSString*)value {
    //NSLog(@"Set cell value: %@", value);
    lblValue.text = value;
}
@end
