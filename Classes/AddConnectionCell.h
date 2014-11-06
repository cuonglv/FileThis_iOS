//
//  AddConnectionCell.h
//  FileThis
//
//  Created by Cuong Le on 11/21/13.
//
//

#import <UIKit/UIKit.h>

#define kAddConnectionCellHeight       (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ? 80.0 : 60.0)

@interface AddConnectionCell : UITableViewCell

@property (weak) UITableView *table;
@property (strong, nonatomic) UIImageView *addImageView;
@property (strong, nonatomic) UILabel *titleLabel;

- (id)initWithTableView:(UITableView*)tableview reuseIdentifier:(NSString *)reuseIdentifier;
- (void)layoutSubviewsByWidth:(float)width;

@end
