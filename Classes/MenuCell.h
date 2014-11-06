//
//  MenuCell.h
//  FileThis
//
//  Created by Cuong Le on 12/11/13.
//
//

#import <UIKit/UIKit.h>

#define kMenuWidth  250.0

@interface MenuCell : UITableViewCell
@property (nonatomic, strong) UIImageView *leftImageView, *rightImageView;
@property (nonatomic, strong) UILabel *myLabel;
- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView*)tableview;
- (void)setLeftImage:(UIImage *)leftImage rightImage:(UIImage*)rightImage text:(NSString*)text font:(UIFont*)font unselectedTextColor:(UIColor*)unselectedTextColor selected:(BOOL)selected;
@end
