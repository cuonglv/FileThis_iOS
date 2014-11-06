//
//  CabinetCollectionCell.h
//  FileThis
//
//  Created by Cuong Le on 12/31/13.
//
//

#import <UIKit/UIKit.h>
#import "CommonLayout.h"
#import "CabinetObject.h"
#import "HScalableThreePartBackgroundView.h"

#define kCabinetCollectionCell_TextOnlyFont  [CommonLayout getFont:FontSizeSmall isBold:NO isItalic:NO]
#define kCabinetCollectionCell_Font          [CommonLayout getFont:FontSizeSmall isBold:NO isItalic:YES]
#define kCabinetCollectionCell_DarkColor        kTextOrangeColor
#define kCabinetCollectionCell_LightColor       [UIColor whiteColor]

@interface CabinetCollectionCell : UICollectionViewCell

@property (assign) BOOL *clearBackground, useDarkBackground;

- (void)setText:(NSString*)aText clearBackground:(BOOL)clearBackground useDarkBackColor:(BOOL)useDarkBackColor;

@end
