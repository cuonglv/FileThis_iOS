//
//  CheckmarkCell.h
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//

#import <UIKit/UIKit.h>

@interface CheckmarkCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier font:(UIFont*)font textColor:(UIColor*)textColor highlightColor:(UIColor*)highlightColor leftMargin:(float)leftMargin rightMargin:(float)rightMargin tableView:(UITableView*)tableView;

- (void)setText:(NSString*)text rightText:(NSString*)rightText selected:(BOOL)selected textColor:(UIColor*)textColor;
@end
