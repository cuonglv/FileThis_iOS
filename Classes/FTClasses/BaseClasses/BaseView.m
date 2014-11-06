//
//  BaseView.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "BaseView.h"

@implementation BaseView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self initializeView];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
        [self initializeView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self relayout];
}

- (void)initializeView {
    // TODO on childs
}

- (void)setupViewForIdiom:(UIUserInterfaceIdiom)aIdiom {
    // TODO on childs
}

- (void)reloadView {
    // TODO on childs
}

- (void)relayout {
    // TODO on childs
}

- (void)closeKeyboard {
    // TODO on childs
}

- (void)makeEmpty {
    // TODO on childs
}

- (void)resetView {
    // TODO on childs
}

- (void)clearData {
    // TODO on childs
}

@end
