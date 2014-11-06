//
//  BaseCell.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UILabel+Style.h"
#import "UIView+ExtLayout.h"

@interface BaseCell : UITableViewCell
{
    NSObject *m_obj;
}

@property (nonatomic, strong) NSObject *m_obj;
- (void)updateCellWithObject:(NSObject *)obj;

@end
