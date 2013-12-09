//
//  KeyValueCell.h
//  FTMobile
//
//  Created by decuoi on 12/17/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface KeyValueCell : UITableViewCell {
    UILabel *lblKey, *lblValue;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier key:(NSString*)key value:(NSString*)value isValueAtBottom:(BOOL)isValueAtBottom drawAccessory:(BOOL)drawAccessory;

- (void)setCellValue:(NSString*)value;
@end
