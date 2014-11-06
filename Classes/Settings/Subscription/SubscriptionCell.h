//
//  SubscriptionCell.h
//  FileThis
//
//  Created by Drew Wilson on 1/15/13.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface SubscriptionCell : UITableViewCell

@property (nonatomic) SKProduct *product;
@property (readonly) NSString *title;

@end
