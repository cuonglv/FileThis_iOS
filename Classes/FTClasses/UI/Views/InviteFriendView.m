//
//  InviteFriendView.m
//  FileThis
//
//  Created by Cao Huu Loc on 5/30/14.
//
//

#import "InviteFriendView.h"
#import "CommonLayout.h"

@implementation InviteFriendView

- (id)initWithFrame:(CGRect)frame
{
    self = [self initWithFrame:frame target:nil action:nil];
    return self;
}

- (id)initWithFrame:(CGRect)frame target:(id)target action:(SEL)action {
    self = [super initWithFrame:frame];
    if (self) {
        int buttonHeight = 40;
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, frame.size.width - 15*2, frame.size.height - buttonHeight)];
        lbl.text = NSLocalizedString(@"ID_INVITE_TO_EARN_MORE", @"");
        lbl.font = [CommonLayout getFont:FontSizeXSmall isBold:NO isItalic:YES];
        lbl.textColor = kTextGrayColor;
        lbl.textAlignment = NSTextAlignmentCenter;
        lbl.numberOfLines = 0;
        self.lblDescription = lbl;
        [self addSubview:self.lblDescription];
        
        ImageTextButton *btn = [ImageTextButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(0, frame.size.height - buttonHeight, frame.size.width, buttonHeight);
        [btn setImage:[UIImage imageNamed:@"invite_icon.png"] forState:UIControlStateNormal];
        btn.backgroundColor = kBackgroundOrange;
        [btn setTitle:[NSLocalizedString(@"ID_INVITE_FRIEND", @"") uppercaseString] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
        btn.titleLabel.textAlignment = NSTextAlignmentCenter;
        btn.titleLabel.font = [CommonLayout getFont:FontSizexSmall isBold:YES];
        btn.imageFrame = CGRectMake(20, 7, 35, 26);
        self.btnInvite = btn;
        [self addSubview:btn];
    }
    return self;
}

@end
