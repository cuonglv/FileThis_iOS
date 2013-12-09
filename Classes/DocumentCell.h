//
//  DocumentCell.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface DocumentCell : UITableViewCell {
    UIImageView *imvThumb;
    UILabel *lblName, *lblDate, *lblTags;

    NSMutableDictionary *dictDoc;
}
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier borderColor:(UIColor*)borderColor;
@property (nonatomic, strong) UIImageView *imvThumb;
@property (nonatomic, strong) UILabel *lblName, *lblDate, *lblTags;
@property (nonatomic, strong) NSMutableDictionary *dictDoc;
- (void)updateImage;
@end
