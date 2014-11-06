//
//  ReferralsView.h
//  FileThis
//
//  Created by Cao Huu Loc on 6/2/14.
//
//

#import <UIKit/UIKit.h>

@interface ReferralsView : UIView <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, strong) UILabel *lblInvite;
@property (nonatomic, strong) UITableView *tblReferrals;
@property (nonatomic, strong) UIButton *btnInvite;

@property (nonatomic, strong) NSArray *arrReferrals;

- (void)refreshGUI;
- (void)setHeightToFitConstraint:(int)constraint;

@end
