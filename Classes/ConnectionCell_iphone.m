//
//  ConnectionCell_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 3/4/14.
//
//

#import "ConnectionCell_iphone.h"
#import "UIView+ExtLayout.h"

@implementation ConnectionCell_iphone

- (id)initWithTableView:(UITableView*)tableView reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithTableView:tableView reuseIdentifier:reuseIdentifier];
    if (self) {
        self.statusLabel.numberOfLines = 0;
        self.statusLabel.lineBreakMode = NSLineBreakByWordWrapping;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    //Left icon
    CGRect rect = self.iconImage.frame;
    rect.origin.x = 7;
    rect.size.width = 56;
    self.iconImage.frame = rect;
    
    //Right button
    int rightMargin = 10;
    rect = self.refreshButton.frame;
    rect.origin.x = self.frame.size.width - rect.size.width - rightMargin;
    rect.origin.y = (self.frame.size.height - rect.size.height) / 2;
    self.refreshButton.frame = rect;
    self.errorButton.frame = self.refreshButton.frame;
    self.resolveButton.frame = self.refreshButton.frame;
    self.activityIndicator.frame = self.refreshButton.frame;
    
    rect = self.arrowIndicatorImageView.frame;
    rect.origin.x = self.frame.size.width - rect.size.width - rightMargin;
    rect.origin.y = (self.frame.size.height - rect.size.height) / 2;
    self.arrowIndicatorImageView.frame = rect;
    
    //Text
    rect = [self.iconImage rectAtRight:7 width:10];
    rect.origin.y = 5;
    rect.size.width = self.refreshButton.frame.origin.x - rect.origin.x - 5;
    rect.size.height = 18;
    self.nameLabel.frame = rect;
    
    //Status
    rect = [self.nameLabel rectAtBottom:0 height:20];
    rect.size.height = self.frame.size.height - rect.origin.y;
    self.statusLabel.frame = rect;
    
    //Disclosure
    rect = self.arrowIndicatorImageView.frame;
    rect.origin.x = self.contentView.frame.size.width - 30;
    self.arrowIndicatorImageView.frame = rect;
}

@end
