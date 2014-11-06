//
//  MyDestinationCell.h
//  FileThis
//
//  Created by Cuong Le on 12/11/13.
//
//

#import <UIKit/UIKit.h>
#import "FTDestination.h"

@interface MyDestinationCell : UITableViewCell
@property (nonatomic, weak) UITableView *myTable;
@property (nonatomic, strong) UIImageView *logoView, *rightImageView;
@property (nonatomic, strong) UILabel *myLabel;

- (id)initWithTable:(UITableView*)table reuseIdentifier:(NSString *)reuseIdentifier;
- (void)configure:(FTDestination *)destination selected:(BOOL)selected authorizationError:(BOOL)authorizationError;

@end
