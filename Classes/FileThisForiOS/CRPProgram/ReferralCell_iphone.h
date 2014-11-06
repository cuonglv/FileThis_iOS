//
//  ReferralCell_iphone.h
//  FileThis
//
//  Created by Cao Huu Loc on 6/6/14.
//
//

#import <UIKit/UIKit.h>
#import "ReferralObject.h"

@interface ReferralCell_iphone : UITableViewCell
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UILabel *lblReferralTitle;
@property (nonatomic, strong) UILabel *lblEmail;
@property (nonatomic, strong) UILabel *lblLine;

@property (nonatomic, strong) UILabel *lblExpireTitle;
@property (nonatomic, strong) UILabel *lblExpire;

@property (nonatomic, strong) UILabel *lblStorageTitle;
@property (nonatomic, strong) UILabel *lblStorage;

@property (nonatomic, strong) UILabel *lblConnectionTitle;
@property (nonatomic, strong) UILabel *lblConnection;

- (void)loadData:(ReferralObject*)obj;

@end
