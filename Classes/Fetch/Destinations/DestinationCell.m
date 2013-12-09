//
//  DestinationCell.m
//  FileThis
//
//  Created by Drew Wilson on 2/26/13.
//
//

#import "DestinationCell.h"

@interface DestinationCell ()

@end

@implementation DestinationCell

- (id)initWithCoder:(NSCoder *)aDecoder {
    if ((self = [super initWithCoder:aDecoder])) {
        ;
    }
    return self;
}

-(void)awakeFromNib {
}

-(void)prepareForReuse {
    NSLog(@"%@ prepares for resuse", self);
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

- (void)configure:(FTDestination *)destination {
    [destination configureForTextLabel:self.nameView withImageView:self.logoView];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    UIView *v = [self viewWithTag:3];
    UIView *v2 = [self viewWithTag:8];
    NSLog(@"%@ layout subviews, image=%@, label=%@", self, v, v2);
}

@end
