//
//  SubscriptionBenefitView.h
//  FileThis
//
//  Created by Cao Huu Loc on 3/11/14.
//
//

#import <UIKit/UIKit.h>
#import "IconAndTextView.h"

@interface SubscriptionBenefitView : UIView
@property (nonatomic, strong) NSMutableArray *benefitViews;

- (void)resizeByWidth:(float)width;

@end
