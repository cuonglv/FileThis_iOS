//
//  SubscriptionView.h
//  FileThis
//
//  Created by Cao Huu Loc on 6/2/14.
//
//

#import <UIKit/UIKit.h>

@interface SubscriptionView : UIView
@property (nonatomic, strong) IBOutlet UIView *topView;
@property (nonatomic, strong) IBOutlet UIImageView *planImageView;
@property (nonatomic, strong) IBOutlet UILabel *lblPlanTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblPlanText;
@property (nonatomic, strong) IBOutlet UIImageView *line1ImageView;

@property (nonatomic, strong) IBOutlet UIView *storageView;
@property (nonatomic, strong) IBOutlet UIImageView *storageImageView;
@property (nonatomic, strong) IBOutlet UILabel *lblStorageTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblStorageText;
@property (nonatomic, strong) IBOutlet UIImageView *line2ImageView;

@property (nonatomic, strong) IBOutlet UIView *connectionView;
@property (nonatomic, strong) IBOutlet UIImageView *connectionImageView;
@property (nonatomic, strong) IBOutlet UILabel *lblConnectionTitle;
@property (nonatomic, strong) IBOutlet UILabel *lblConnectionText;

@property (nonatomic, strong) IBOutlet UIView *upgradeView;
@property (nonatomic, strong) IBOutlet UIButton *btnUpgrade;

@property (nonatomic, assign) UIInterfaceOrientation interfaceOrientation;

- (void)refreshGUI;

@end
