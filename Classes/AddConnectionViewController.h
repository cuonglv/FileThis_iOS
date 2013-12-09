//
//  AddConnectionViewController.h
//  FileThis
//
//  Created by Drew on 5/1/12.
//  Copyright (c) 2012 filethis.com. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UICollectionViewFlowLayout.h>

@interface AddConnectionViewController : UIViewController
    <UISearchBarDelegate,UIPopoverControllerDelegate,
        UICollectionViewDataSource,UICollectionViewDelegate>

@property (weak) id cancelReceiver;
@property SEL cancelAction;
@property (weak) id doneReceiver;
@property SEL doneAction;

- (void)setCancelReceiver:(id)receiver withAction:(SEL)action;
- (void)setDoneReceiver:(id)receiver withAction:(SEL)action;

@end

