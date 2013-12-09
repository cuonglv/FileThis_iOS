//
//  DocumentCell.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "DocumentCell.h"
#import "Constants.h"
#import "Layout.h"
#import "CommonVar.h"
#import "DocumentDetailController.h"

@implementation DocumentCell
@synthesize imvThumb, lblName, lblDate, lblTags;
@synthesize dictDoc;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier borderColor:(UIColor*)borderColor {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        // Initialization code
        
        imvThumb = [[UIImageView alloc] initWithFrame:CGRectMake(0, -1, [CommonVar docThumbSmallWidth], [CommonVar docThumbSmallHeight]+1)];
        //imvThumb.image = [UIImage imageNamed:kThumbImage1];
        imvThumb.contentMode = UIViewContentModeScaleAspectFit;
        imvThumb.layer.borderColor = borderColor.CGColor;
        imvThumb.layer.borderWidth = 1.0;
        //imvThumb.layer.masksToBounds = YES;
        //imvThumb.layer.cornerRadius = 4.0;
        
        [self addSubview:imvThumb];
        
        lblName = [[UILabel alloc] initWithFrame:CGRectMake([CommonVar docThumbSmallWidth] + 4, 2, self.frame.size.width - [CommonVar docThumbSmallWidth] - 20, 15)];
        lblName.font = [UIFont boldSystemFontOfSize:kFontSizeSmall];
        [self addSubview:lblName];
        
        lblDate = [[UILabel alloc] initWithFrame:[Layout CGRectMoveBy:lblName.frame dx:0 dy:16]];
        lblDate.font = [UIFont systemFontOfSize:kFontSizeSmall];
        [self addSubview:lblDate];
        
        lblTags = [[UILabel alloc] initWithFrame:[Layout CGRectMoveBy:lblDate.frame dx:1 dy:16]];
        lblTags.font = [UIFont systemFontOfSize:kFontSizeXSmall];
        lblTags.textColor = [UIColor grayColor];
        //lblTags.text = @"entertainment, concert, comedy, romantic...";
        [self addSubview:lblTags];
        
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)updateImage {
    [imvThumb setNeedsDisplay];
}


#pragma mark -
#pragma mark Touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"DocMetadata - touchesEnded",@"");
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self];
        BOOL blnTouchOnText = YES;
        if ([Layout isPointOutsideControl:point forControl:imvThumb]) {
            //NSLog(@"DocumentCell - Thumb click", @"");
        } else {
            //NSLog(@"DocumentCell - Doc click", @"");
            blnTouchOnText = NO;
        }
        if (dictDoc) {
            UINavigationController *con = [CommonVar mainNavigationController];
            DocumentDetailController *target = [[DocumentDetailController alloc] initWithNibName:@"DocumentDetailController" bundle:[NSBundle mainBundle]];
            target.docCon = (DocumentController*)con.visibleViewController;
            target.dictDoc = dictDoc;
            target.blnIsMetadataActive = blnTouchOnText;
            [con pushViewController:target animated:YES];
        }
        return;
    }
}
@end
