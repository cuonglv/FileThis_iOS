//
//  AddConnectionCell.h
//  FileThis
//
//  Created by Cuong Le on 11/21/13.
//
//

#import <UIKit/UIKit.h>

@interface AddConnectionCell : UITableViewCell

@property (strong, nonatomic) UIImageView *addImageView;

- (id)initWithTableView:(UITableView*)tableview reuseIdentifier:(NSString *)reuseIdentifier;

@end
