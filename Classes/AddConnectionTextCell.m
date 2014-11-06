//
//  AddConnectionTextCell.m
//  FileThis
//
//  Created by Cao Huu Loc on 1/22/14.
//
//

#import "AddConnectionTextCell.h"
#import "CommonLayout.h"

@implementation AddConnectionTextCell

- (id)initWithTableView:(UITableView*)tableview reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, tableview.frame.size.width, kAddConnectionTextCellHeight)];
        self.titleLabel.text = NSLocalizedString(@"Please select to add a connection", @"row title");
        self.titleLabel.textAlignment = NSTextAlignmentLeft;
        self.titleLabel.font = [CommonLayout getFont:16 isBold:NO isItalic:YES];
        self.titleLabel.textColor = kTextGrayColor;
        [self.contentView addSubview:self.titleLabel];
        self.backgroundColor = [UIColor colorWithRedInt:242 greenInt:240 blueInt:246];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
