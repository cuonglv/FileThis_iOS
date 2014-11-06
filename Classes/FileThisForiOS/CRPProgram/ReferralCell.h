//
//  ReferralCell.h
//  FileThis
//
//  Created by Cao Huu Loc on 6/3/14.
//
//

#import <UIKit/UIKit.h>
#import "ReferralObject.h"

@interface ReferralCell : UITableViewCell
@property (nonatomic, strong) UILabel *lblEmail;
@property (nonatomic, strong) UIImageView *line1;
@property (nonatomic, strong) UILabel *lblExpire;
@property (nonatomic, strong) UIImageView *line2;
@property (nonatomic, strong) UILabel *lblStorage;
@property (nonatomic, strong) UIImageView *line3;
@property (nonatomic, strong) UILabel *lblConnection;

- (void)loadData:(ReferralObject*)obj;

@end
