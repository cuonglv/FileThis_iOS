//
//  OnboardingViewController.h
//  FileThis
//
//  Created by Cuong Le on 11/15/13.
//
//

#import <UIKit/UIKit.h>
#import "CommonLayout.h"

@interface OnboardingViewController : UIViewController
@property (nonatomic, strong) UIImageView *bgImageView, *logoTextImageView, *contentImageView;
@property (nonatomic, strong) UIView *bodyTextView;
@property (nonatomic, strong) UILabel *lblText1, *lblText2;

- (void)relayout;

@end
