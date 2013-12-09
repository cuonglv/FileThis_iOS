//
//  TagController.h
//  FTMobile
//
//  Created by decuoi on 12/2/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TagTableView.h"
#import "MyAnimatedView.h"
#import "TagData.h"

@interface TagController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet TagTableView *myTableView;
    UIImage *imgCheck;
    MyAnimatedView *vwAnimated;
    
    BOOL blnViewOnly;   // SelectCabinet (blnViewOnly=NO)    ViewCabinetInfo (blnViewOnly=YES)
    NSArray *arrTagsInfo;   //just used for ViewTagInfo only
    
    NSString *sSearchFilter;
    
    NSMutableArray *marrTagsChecked, *marrTagsUnchecked, *marrTagIdsChecked;
}
@property (assign) BOOL blnViewOnly;
@property (nonatomic, strong) NSArray *arrTagsInfo;
@property (nonatomic, strong) NSString *sSearchFilter;

- (int)insertTagData:(TagData *)newTagData toCheckedArray:(BOOL)toCheckedArray;
- (void)removeTagChecked:(int)index;
- (void)loadData;
@end
