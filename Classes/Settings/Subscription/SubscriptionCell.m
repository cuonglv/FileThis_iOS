//
//  SubscriptionCell.m
//  FileThis
//
//  Created by Drew Wilson on 1/15/13.
//
//

#import "SubscriptionCell.h"
#import "UIKitExtensions.h"

@interface SubscriptionCell ()
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;

@end

@implementation SubscriptionCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (NSString *)makeTitle:(SKProduct *)product
{
    NSString *titleSuffix;
    if ([product.productIdentifier rangeOfString:@"monthly"].length != 0) {
        titleSuffix = NSLocalizedString(@"1 month", @"subscription suffix");
    } else if ([product.productIdentifier rangeOfString:@"annual"].length != 0) {
        titleSuffix = NSLocalizedString(@"1 year", @"subscription suffix");
    } else if ([product.productIdentifier rangeOfString:@"weekly"].length != 0) {
        titleSuffix = NSLocalizedString(@"1 week", @"subscription suffix");
    } else if ([product.productIdentifier rangeOfString:@"daily"].length != 0) {
        titleSuffix = NSLocalizedString(@"1 day", @"subscription suffix");
    } else {
        self.titleLabel.text = product.localizedTitle;
    }
    if (titleSuffix)
        return [NSString stringWithFormat:@"%@ %@",titleSuffix, product.localizedTitle];
    else
        return product.localizedTitle;
}

- (void)setProduct:(SKProduct *)product
{
    _product = product;
    self.descriptionLabel.text = product.localizedDescription;
    self.priceLabel.text = product.localizedPrice;
    self.titleLabel.text = [self makeTitle:product];
}

- (NSString *)title
{
    return self.titleLabel.text;
}

@end
