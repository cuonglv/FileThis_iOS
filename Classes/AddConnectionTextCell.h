//
//  AddConnectionTextCell.h
//  FileThis
//
//  Created by Cao Huu Loc on 1/22/14.
//
//

#import <UIKit/UIKit.h>

#define kAddConnectionTextCellHeight    50

@interface AddConnectionTextCell : UITableViewCell

@property (strong, nonatomic) UILabel *titleLabel;

- (id)initWithTableView:(UITableView*)tableview reuseIdentifier:(NSString *)reuseIdentifier;

@end
