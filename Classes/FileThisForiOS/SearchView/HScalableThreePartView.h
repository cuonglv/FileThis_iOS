//
//  HScalableThreePartView.h
//  FileThis
//
//  Created by Cuong Le on 1/17/14.
//
//

#import <UIKit/UIKit.h>
#import "CommonLayout.h"
#import "TagObject.h"
#import "HScalableThreePartBackgroundView.h"

#define kTagCollectionCell_Font          [CommonLayout getFont:FontSizeXSmall isBold:NO isItalic:NO]
#define kTagCollectionCell_ItalicFont    [CommonLayout getFont:FontSizeXSmall isBold:NO isItalic:YES]
#define kTagCollectionCell_MaxWidth      200.0
#define kTagCollectionCell_Height        26.0

typedef enum TagCollectionCellBackgroundType {
    TagCollectionCellBackgroundTypeTagOrangeX,
    TagCollectionCellBackgroundTypeTagOrange,
    TagCollectionCellBackgroundTypeTagWhite,
    TagCollectionCellBackgroundTypeCabinetX,
    TagCollectionCellBackgroundTypeCabinet,
    TagCollectionCellBackgroundTypeProfileX,
    TagCollectionCellBackgroundTypeProfile,
    TagCollectionCellBackgroundTypeTextX,
    TagCollectionCellBackgroundTypeText,
    TagCollectionCellBackgroundTypeDateX,
    TagCollectionCellBackgroundTypeDate,
    TagCollectionCellBackgroundTypeClear
} TagCollectionCellBackgroundType;

@interface HScalableThreePartView : UIView
- (void)setText:(NSString*)aText backgroundType:(TagCollectionCellBackgroundType)backgroundType;
- (void)setText:(NSString*)aText rightText:(NSString*)aRightText backgroundType:(TagCollectionCellBackgroundType)backgroundType;
+ (CGSize)fitSizeForText:(NSString*)text backgroundType:(TagCollectionCellBackgroundType)backgroundType;

@end
