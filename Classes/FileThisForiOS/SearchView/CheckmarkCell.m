//
//  CheckmarkCell.m
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//

#import "CheckmarkCell.h"
#import "CommonLayout.h"

@interface CheckmarkCell()
@property (nonatomic, weak) UITableView *myTable;
@property (nonatomic, strong) UILabel *myLabel, *rightLabel;
@property (nonatomic, strong) UIImageView *checkmarkImageView;
@property (nonatomic, strong) UIColor *textColor, *highlightColor;
@end

@implementation CheckmarkCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier font:(UIFont*)font textColor:(UIColor*)textColor highlightColor:(UIColor*)highlightColor leftMargin:(float)leftMargin rightMargin:(float)rightMargin tableView:(UITableView*)tableView {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.myTable = tableView;
        self.textColor = textColor;
        self.highlightColor = highlightColor;
        
        float iconSize = roundf(self.myTable.rowHeight * 0.25) * 2;
        self.checkmarkImageView = [CommonLayout createImageView:CGRectMake(self.myTable.frame.size.width-rightMargin-iconSize,self.myTable.rowHeight/2-iconSize/2,iconSize,iconSize) image:[UIImage imageNamed:@"checkmark_icon_orange.png"] contentMode:UIViewContentModeScaleAspectFit superView:self];
        self.checkmarkImageView.hidden = YES;
        
        self.rightLabel = [CommonLayout createLabel:CGRectMake(self.myTable.frame.size.width-rightMargin-40, 2, 40, self.myTable.rowHeight-4) font:font textColor:self.textColor backgroundColor:nil text:@"" superView:self];
        self.rightLabel.textAlignment = NSTextAlignmentRight;
        self.rightLabel.adjustsFontSizeToFitWidth = YES;
        self.rightLabel.minimumScaleFactor = 0.9;
        
        self.myLabel = [CommonLayout createLabel:CGRectMake(leftMargin,2,[self.rightLabel left]-leftMargin-2,self.myTable.rowHeight-4) font:font textColor:self.textColor backgroundColor:nil text:@"" superView:self];
        self.myLabel.adjustsFontSizeToFitWidth = YES;
        self.myLabel.minimumScaleFactor = 0.9;
    }
    return self;
}

- (void)setText:(NSString*)text rightText:(NSString*)rightText selected:(BOOL)selected textColor:(UIColor*)textColor {
    self.myLabel.text = text;
    self.rightLabel.text = rightText;
    if (selected) {
        self.myLabel.textColor = self.rightLabel.textColor = self.highlightColor;
        self.checkmarkImageView.hidden = NO;
    } else {
        self.myLabel.textColor = self.rightLabel.textColor = textColor;
        self.checkmarkImageView.hidden = YES;
    }
    if ([rightText length] == 0 && !selected)
        [self.myLabel setRightWithoutChangingLeft:self.myTable.frame.size.width-12];
    else
        [self.myLabel setRightWithoutChangingLeft:[self.rightLabel left]-2];
}

@end
