//
//  TagTableView.h
//  FTMobile
//
//  Created by decuoi on 12/2/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TagCell.h"

@interface TagTableView : UITableView {
    BOOL blnViewOnly;   // SelectCabinet (blnViewOnly=NO)    ViewCabinetInfo (blnViewOnly=YES)
}
@property (assign) BOOL blnViewOnly;

#pragma mark -
- (void)checkCell:(TagCell*)tagCell;
- (void)uncheckCell:(NSIndexPath*)indexPath;
@end
