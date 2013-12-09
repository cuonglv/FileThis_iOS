//
//  TopAlignedLabel.h
//  TKD
//
//  Created by decuoi on 4/22/11.
//  Copyright 2011 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TopAlignedLabelDelegate <NSObject>
- (void)touchTopAlignedLabel:(id)label;
@end

@interface TopAlignedLabel : UILabel {
}
@property (nonatomic, assign) id<TopAlignedLabelDelegate> topAlignedLabelDelegate;
@end



