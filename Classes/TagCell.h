//
//  TagCell.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagData.h"

@interface TagCell : UITableViewCell {
    UILabel *lblName, *lblCount;
    UIImageView *imvCheck;
    TagData *tagData_;
}
@property (nonatomic, strong) UILabel *lblName;
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier imageCheck:(UIImage*)imgCheck;
- (void)setCount:(int)count;
- (BOOL)changeCheck;
- (void)displayCheck;
- (void)setCheck:(BOOL)checked;

- (TagData*)tagData;
- (void)setTagData:(TagData*)value;
@end
