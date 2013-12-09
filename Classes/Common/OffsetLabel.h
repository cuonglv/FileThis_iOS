//
//  OffsetLabel.h
//  TKD
//
//  Created by decuoi on 6/22/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offset.h"

@interface OffsetLabel : UILabel {
    Offset offset;
    Offset borderWidths;
    UIColor *borderColor;
}
@property (atomic, assign) Offset offset;
@property (atomic, assign) Offset borderWidths;
@property (nonatomic, retain) UIColor *borderColor;
- (id)initWithFrame:(CGRect)frame offset:(Offset)offsetValue borderColor:(UIColor*)bordercolor borderWidths:(Offset)borderwidths superView:(UIView*)superView;
- (id)initWithFrame:(CGRect)frame offset:(Offset)offsetValue superView:(UIView*)superView;
@end
