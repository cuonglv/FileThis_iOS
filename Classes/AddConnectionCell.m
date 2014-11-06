//
//  AddConnectionCell.m
//  FileThis
//
//  Created by Cuong Le on 11/21/13.
//
//

#import "AddConnectionCell.h"
#import "CommonLayout.h"

@implementation AddConnectionCell

- (id)initWithTableView:(UITableView*)tableview reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.table = tableview;
        //self.addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableview.frame.size.width - 40, tableview.rowHeight/2 - 20, 40, 40)];
        //self.addImageView.image = [UIImage imageNamed:@"glyphicons_190_circle_plus.png"];
        
        self.addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, kAddConnectionCellHeight/2 - 20, 40, 40)]; //Loc Cao
        self.addImageView.image = [UIImage imageNamed:@"plus_icon.png"]; //Loc Cao
        self.addImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.addImageView];
        
        //+++++Loc Cao
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, tableview.frame.size.width, kAddConnectionCellHeight)];
        self.titleLabel.text = NSLocalizedString(@"Add new Connection", @"row title");
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.titleLabel.font = [CommonLayout getFont:18 isBold:NO];
        self.titleLabel.textColor = kTextOrangeColor;
        [self.contentView addSubview:self.titleLabel];
        self.backgroundColor = [UIColor colorWithRedInt:242 greenInt:240 blueInt:246];
    }
    return self;
}

//+++++Loc Cao
- (void)layoutSubviews
{
    [super layoutSubviews];
    [self layoutSubviewsByWidth:self.table.frame.size.width];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)layoutSubviewsByWidth:(float)width
{
    CGSize size = [self.titleLabel.text sizeWithFont:self.titleLabel.font forWidth:width lineBreakMode:NSLineBreakByTruncatingTail];
    float space = 5;
    float x = (width - size.width - space) / 2.0;
    
    CGRect rect = self.addImageView.frame;
    rect.origin.x = roundf(x);
    self.addImageView.frame = rect;
    
    rect = self.titleLabel.frame;
    rect.origin.x = self.addImageView.frame.origin.x + self.addImageView.frame.size.width + space;
    rect.size.width = size.width;
    self.titleLabel.frame = rect;
}
#pragma GCC diagnostic pop
//-----

@end
