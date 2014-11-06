//
//  SubscriptionViewController.h
//  FileThis
//
//  Created by Drew Wilson on 1/15/13.
//
//

#import <UIKit/UIKit.h>
#import "MyDetailViewController.h"
#import "SubscriptionBenefitView.h"

@interface SubscriptionViewController : MyDetailViewController

@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) IBOutlet UIView *headerView;
@property (nonatomic, strong) IBOutlet UIImageView *bgImageHeader;
@property (nonatomic, strong) IBOutlet UILabel *yourCurrentAccountLabel;
@property (nonatomic, strong) IBOutlet UILabel *lblTitle1;
@property (nonatomic, strong) IBOutlet UILabel *lblTitle2;
@property (nonatomic, strong) IBOutlet UILabel *lblTitle3;

@property (nonatomic, strong) IBOutlet UIView *purchaseButtonsView;
@property (strong, nonatomic) IBOutlet UIButton *premiumMonthlyButton;
@property (strong, nonatomic) IBOutlet UIButton *premiumAnnuallyButton;
@property (strong, nonatomic) IBOutlet UIButton *ultimateMonthlyButton;
@property (strong, nonatomic) IBOutlet UIButton *ultimateAnnuallyButton;

@property (nonatomic, strong) IBOutlet UILabel *lblBenefit;
@property (nonatomic, strong) IBOutlet SubscriptionBenefitView *benefitView;

@property BOOL useBackButton;

@end
