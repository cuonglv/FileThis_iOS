//
//  CabinetController.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CabinetCell.h"
#import "DocumentController.h"
#import "MyAnimatedView.h"

@interface CabinetController : UIViewController <UITableViewDelegate, UITableViewDataSource> {
    IBOutlet UITableView *myTableView;
    NSArray *arrCabinets;  // =nil when first load SelectCabinet    
    MyAnimatedView *vwAnimated;
    BOOL blnViewOnly;   // SelectCabinet (blnViewOnly=NO)    ViewCabinetInfo (blnViewOnly=YES)
}
@property (nonatomic, strong) UITableView *myTableView;
@property (nonatomic, strong) NSArray *arrCabinets;
@property (assign) BOOL blnViewOnly;
@end
