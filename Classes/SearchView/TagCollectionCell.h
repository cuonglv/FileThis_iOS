//
//  TagCollectionCell.h
//  FileThis
//
//  Created by Cuong Le on 12/19/13.
//
//

#import <UIKit/UIKit.h>
#import "CommonLayout.h"
#import "TagObject.h"
#import "HScalableThreePartBackgroundView.h"

#define kTagCollectionCell_Font          [CommonLayout getFont:FontSizeXSmall isBold:NO isItalic:NO]
#define kTagCollectionCell_ItalicFont    [CommonLayout getFont:FontSizeXSmall isBold:NO isItalic:YES]
#define kTagCollectionCell_Height        28.0

typedef enum TagCollectionCellBackgroundType {
    TagCollectionCellBackgroundTypeTagOrange,
    TagCollectionCellBackgroundTypeTagOrangeX,
    TagCollectionCellBackgroundTypeTagOrangeWithTail,
    TagCollectionCellBackgroundTypeTagWhite,
    TagCollectionCellBackgroundTypeTagWhiteX,
    TagCollectionCellBackgroundTypeTagWhiteWithTail,
    TagCollectionCellBackgroundTypeCabinet,
    TagCollectionCellBackgroundTypeCabinetX,
    TagCollectionCellBackgroundTypeRectWhite,
    TagCollectionCellBackgroundTypeRectWhiteX,
    TagCollectionCellBackgroundTypeRectWhiteWithTail,
    TagCollectionCellBackgroundTypeRectOrange,
    TagCollectionCellBackgroundTypeRectOrangeX,
    TagCollectionCellBackgroundTypeRectOrangeWithTail,
    TagCollectionCellBackgroundTypeProfile,
    TagCollectionCellBackgroundTypeProfileX,
    TagCollectionCellBackgroundTypeText,
    TagCollectionCellBackgroundTypeTextX,
    TagCollectionCellBackgroundTypeDate,
    TagCollectionCellBackgroundTypeDateX,
    TagCollectionCellBackgroundTypeClear
} TagCollectionCellBackgroundType;

@interface TagCollectionCell : UICollectionViewCell
- (void)setText:(NSString*)aText backgroundType:(TagCollectionCellBackgroundType)backgroundType;
- (void)setText:(NSString*)aText rightText:(NSString*)aRightText backgroundType:(TagCollectionCellBackgroundType)backgroundType;
+ (CGSize)fitSizeForText:(NSString*)text backgroundType:(TagCollectionCellBackgroundType)backgroundType maxWidth:(float)maxWidth;
@end
