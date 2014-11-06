//
//  MenuCell.m
//  FileThis
//
//  Created by Cuong Le on 12/11/13.
//
//

#import "MenuCell.h"
#import "MyDetailViewController.h"
#import "ImageFilter.h"

@interface MenuCell()
@property (nonatomic, weak) UITableView *myTable;
@end

@implementation MenuCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView*)tableview {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.myTable = tableview;
        
        float imageHeight = tableview.rowHeight -  10;
        self.leftImageView = [CommonLayout createImageView:CGRectMake(10, roundf(tableview.rowHeight/2 - imageHeight/2), imageHeight, imageHeight) image:nil contentMode:UIViewContentModeScaleAspectFit superView:self];
        self.rightImageView = [CommonLayout createImageView:CGRectMake(kMenuWidth-imageHeight-4, 8, imageHeight, imageHeight) image:nil contentMode:UIViewContentModeScaleAspectFit superView:self];
        self.myLabel = [CommonLayout createLabel:[self.leftImageView rectAtRight:10 width:tableview.frame.size.width-[self.leftImageView right]-30] fontSize:FontSizeMedium isBold:NO isItalic:NO textColor:kTextOrangeColor backgroundColor:nil text:@"" superView:self];
        //self.myLabel.adjustsFontSizeToFitWidth = YES;
        //self.myLabel.minimumScaleFactor = 0.6;
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setLeftImage:(UIImage *)leftImage rightImage:(UIImage*)rightImage text:(NSString*)text font:(UIFont*)font unselectedTextColor:(UIColor*)unselectedTextColor selected:(BOOL)selected {
    self.myLabel.text = text;
    if (selected) {
        self.backgroundColor = kTextOrangeColor;
        self.myLabel.textColor = [UIColor whiteColor];
        self.leftImageView.image = [ImageFilter brightness:100 image:leftImage];
        self.rightImageView.image = [ImageFilter brightness:100 image:rightImage];
    } else {
        self.backgroundColor = [UIColor whiteColor];
        self.myLabel.textColor = unselectedTextColor;
        self.leftImageView.image = leftImage;
        self.rightImageView.image = rightImage;
    }
    if (rightImage) {
        [self.rightImageView setRight:self.myTable.frame.size.width-4];
        [self.myLabel setLeft:[self.leftImageView right]+10 right:[self.rightImageView left]];
    } else {
        [self.myLabel setLeft:[self.leftImageView right]+10 right:self.myTable.frame.size.width-4];
    }
    self.myLabel.font = font;
}

@end
