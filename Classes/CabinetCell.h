//
//  CabinetCell.h
//  FTMobileApp
//
//  Created by decuoi on 11/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface CabinetCell : UITableViewCell {
    UIImageView *imvBackground;
    UILabel *lblName, *lblCount;
@public
    NSString *sCabType;
}
@property (nonatomic, strong) UIImageView *imvBackground;
@property (nonatomic, strong) UILabel *lblName, *lblCount;
@property (assign) BOOL blnIsSelected;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier backgroundImg:(UIImage*)img;

- (void)setCabType:(NSString *)cabType;
- (void)setCount:(int)count;
@end
