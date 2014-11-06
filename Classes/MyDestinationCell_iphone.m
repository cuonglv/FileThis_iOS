//
//  MyDestinationCell_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 3/5/14.
//
//

#import "MyDestinationCell_iphone.h"
#import "UIView+ExtLayout.h"

@implementation MyDestinationCell_iphone

- (id)initWithTable:(UITableView*)table reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithTable:table reuseIdentifier:reuseIdentifier];
    if (self) {
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGRect rect = self.logoView.frame;
    rect.size.width = 85;
    self.logoView.frame = rect;
    
    rect = [self.logoView rectAtRight:10 width:10];
    rect.size.width = self.rightImageView.frame.origin.x - rect.origin.x - 5;
    self.myLabel.frame = rect;
}

@end
