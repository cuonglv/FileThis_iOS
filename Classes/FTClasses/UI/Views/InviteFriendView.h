//
//  InviteFriendView.h
//  FileThis
//
//  Created by Cao Huu Loc on 5/30/14.
//
//

#import <UIKit/UIKit.h>
#import "ImageTextButton.h"

@interface InviteFriendView : UIView
@property (nonatomic, strong) UILabel *lblDescription;
@property (nonatomic, strong) ImageTextButton *btnInvite;

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action;

@end
