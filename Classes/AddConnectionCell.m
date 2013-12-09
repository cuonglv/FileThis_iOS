//
//  AddConnectionCell.m
//  FileThis
//
//  Created by Cuong Le on 11/21/13.
//
//

#import "AddConnectionCell.h"

@implementation AddConnectionCell

- (id)initWithTableView:(UITableView*)tableview reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.addImageView = [[UIImageView alloc] initWithFrame:CGRectMake(tableview.frame.size.width - 40, tableview.rowHeight/2 - 20, 40, 40)];
        self.addImageView.image = [UIImage imageNamed:@"glyphicons_190_circle_plus.png"];
        self.addImageView.contentMode = UIViewContentModeCenter;
        [self addSubview:self.addImageView];
        
        self.textLabel.text = NSLocalizedString(@"Add Connection", @"row title");
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.font = [UIFont italicSystemFontOfSize:18.0];
    }
    return self;
}

@end
