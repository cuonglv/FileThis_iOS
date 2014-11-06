//
//  BorderView.h
//  TKD
//
//  Created by decuoi on 6/22/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Offset.h"

@interface BorderView : UIView {
    Offset borderWidths;
    UIColor *borderColor;
}
@property (atomic, assign) Offset borderWidths;
@property (nonatomic, strong) UIColor *borderColor;
- (id)initWithFrame:(CGRect)frame borderColor:(UIColor*)bordercolor borderWidths:(Offset)borderwidths superView:(UIView*)superView;
@end
