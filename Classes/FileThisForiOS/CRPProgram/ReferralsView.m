//
//  ReferralsView.m
//  FileThis
//
//  Created by Cao Huu Loc on 6/2/14.
//
//

#import "ReferralsView.h"
#import "ReferralObject.h"
#import "CommonLayout.h"
#import "CommonFunc.h"
#import "ImageTextButton.h"
#import "ReferralCell.h"
#import "ReferralTableHeaderView.h"
#import "ReferralViewConstants.h"

#define INVITE_GET_MORE_LEFT_MARGIN             60
#define INVITE_GET_MORE_LEFT_MARGIN_PHONE       20

#define TOP_CONTENTVIEW_MARGIN                  10
#define TOP_CONTENTVIEW_MARGIN_PHONE            0
#define BOTTOM_CONTENTVIEW_MARGIN               20
#define VER_SPACE_TO_INVITE_BUTTON              20

@implementation ReferralsView

#pragma mark - Initialize
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    FontSize titleFontSize = IS_IPHONE ? FontSizeSmall : FontSizeLarge;
    self.lblInvite = [CommonLayout createLabel:CGRectMake(INVITE_GET_MORE_LEFT_MARGIN, TOP_CONTENTVIEW_MARGIN, self.bounds.size.width - INVITE_GET_MORE_LEFT_MARGIN * 2, 60) fontSize:titleFontSize isBold:YES isItalic:NO textColor:kTextOrangeColor backgroundColor:[UIColor clearColor] text:NSLocalizedString(@"ID_GET_MORE_STORAGE", @"") superView:self];
    self.lblInvite.numberOfLines = 0;
    self.lblInvite.textAlignment = NSTextAlignmentCenter;
    
    self.tblReferrals = [[UITableView alloc] initWithFrame:CGRectZero];
    self.tblReferrals.backgroundColor = [UIColor clearColor];
    self.tblReferrals.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tblReferrals.scrollEnabled = NO;
    self.tblReferrals.dataSource = self;
    self.tblReferrals.delegate = self;
    self.tblReferrals.hidden = YES;
    [self addSubview:self.tblReferrals];
    
    int widthBtnInvite = 320;
    int heightBtnInvite = 57;
    FontSize buttonFontSize = FontSizeLarge;
    CGRect imageFrame = CGRectMake(30, 11, 44, 35);
    if (IS_IPHONE) {
        widthBtnInvite = 230;
        heightBtnInvite = 40;
        buttonFontSize = FontSizeSmall;
        imageFrame = CGRectMake(15, 7, 30, 26);
    }
    ImageTextButton *btn = [ImageTextButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, widthBtnInvite, heightBtnInvite);
    [btn setImage:[UIImage imageNamed:@"invite_icon.png"] forState:UIControlStateNormal];
    btn.backgroundColor = kBackgroundOrange;
    [btn setTitle:[NSLocalizedString(@"ID_INVITE_FRIEND", @"") uppercaseString] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    btn.titleLabel.textAlignment = NSTextAlignmentCenter;
    btn.titleLabel.font = [CommonLayout getFont:buttonFontSize isBold:YES];
    btn.imageFrame = imageFrame;
    self.btnInvite = btn;
    [self addSubview:btn];
    
    if (IS_IPHONE) {
        self.tblReferrals.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:239/255.0 alpha:1];
        self.tblReferrals.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1].CGColor;
        self.tblReferrals.layer.borderWidth = 1;
        self.backgroundColor = [UIColor whiteColor];
    } else {
        self.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:239/255.0 alpha:1];
        self.layer.borderColor = [UIColor colorWithRed:222/255.0 green:222/255.0 blue:222/255.0 alpha:1].CGColor;
        self.layer.borderWidth = 1;
    }
}

#pragma mark - Layout
- (void)layoutSubviews {
    int left = INVITE_GET_MORE_LEFT_MARGIN;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        left = INVITE_GET_MORE_LEFT_MARGIN_PHONE;
    }
    [self.lblInvite setLeft:left];
    [self.lblInvite setWidth:self.bounds.size.width - left * 2];
    
    int x = (self.bounds.size.width - self.btnInvite.frame.size.width) / 2;
    [self.btnInvite setLeft:x];
    [self.btnInvite setBottom:self.bounds.size.height - BOTTOM_CONTENTVIEW_MARGIN];
    
    int top = IS_IPHONE ? TOP_CONTENTVIEW_MARGIN_PHONE : TOP_CONTENTVIEW_MARGIN;
    int height = [self.btnInvite top] - VER_SPACE_TO_INVITE_BUTTON - top;
    self.tblReferrals.frame = CGRectMake(0, top, self.bounds.size.width, height);
}

#pragma mark - Private methods
- (int)calculateHeightToFitConstraint:(int)constraint {
    int maxHeight = NSIntegerMax;
    int ret = 0;
    if (constraint >0 )
        maxHeight = constraint;
    
    int header = IS_IPHONE ? 0 : kRefTblHeaderHeight;
    int top = IS_IPHONE ? TOP_CONTENTVIEW_MARGIN_PHONE : TOP_CONTENTVIEW_MARGIN;
    int rowheight = IS_IPHONE ? kRefTblRowHeight_phone : kRefTblRowHeight;
    if (self.arrReferrals.count > 0) {
        ret = header + self.arrReferrals.count * rowheight;
        ret += top + VER_SPACE_TO_INVITE_BUTTON + self.btnInvite.bounds.size.height + BOTTOM_CONTENTVIEW_MARGIN;
    } else {
        ret = top + self.lblInvite.bounds.size.height + VER_SPACE_TO_INVITE_BUTTON + self.btnInvite.bounds.size.height + BOTTOM_CONTENTVIEW_MARGIN;
    }
    
    return MIN(ret, maxHeight);
}

#pragma mark - Public methods
- (void)refreshGUI {
    self.lblInvite.hidden = (self.arrReferrals.count > 0);
    self.tblReferrals.hidden = !(self.arrReferrals.count > 0);
    [self.tblReferrals reloadData];
}

- (void)setHeightToFitConstraint:(int)constraint {
    int height = [self calculateHeightToFitConstraint:constraint];
    [self setHeight:height];
}

#pragma mark - UITableViewDataSource, UITabBarDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.arrReferrals.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (IS_IPHONE)
        return kRefTblRowHeight_phone;
    return kRefTblRowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (IS_IPHONE)
        return 0;
    return kRefTblHeaderHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (IS_IPHONE)
        return nil;
    ReferralTableHeaderView *header = [[ReferralTableHeaderView alloc] initWithFrame:CGRectZero];
    return header;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *cellIdentifier = @"ReferralCellIdentifier";
	cell = [self.tblReferrals dequeueReusableCellWithIdentifier:cellIdentifier];
    
	if (cell == nil) {
        cell = [[[CommonFunc idiomClassWithName:@"ReferralCell"] alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
		cell.accessoryType  = UITableViewCellAccessoryNone;
	}
    ReferralObject *obj = [self.arrReferrals objectAtIndex:indexPath.row];
    if ([cell respondsToSelector:@selector(loadData:)])
        [cell performSelector:@selector(loadData:) withObject:obj];
    
	return cell;
}

@end
