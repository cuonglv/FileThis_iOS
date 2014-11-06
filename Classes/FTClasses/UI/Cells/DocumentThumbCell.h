//
//  DocumentThumbCell.h
//  FileThis
//
//  Created by Manh nguyen on 1/12/14.
//
//

#import "BaseCollectionCell.h"

@interface DocumentThumbCell : BaseCollectionCell

@property (nonatomic, strong) UIImageView *thumbImage;
@property (nonatomic, strong) UILabel *lblDocName;
@property (nonatomic, assign) BOOL isSelected;
@property (nonatomic, strong) UIButton *checkButton;

- (void)refreshThumbnail;

@end
