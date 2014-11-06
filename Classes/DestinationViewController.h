//
//  DestinationViewController.h
//  FileThis
//
//  Created by Cuong Le on 12/11/13.
//
//

#import "MyDetailViewController.h"
#import "MyDestinationCell.h"

@interface DestinationViewController : MyDetailViewController <UITableViewDelegate, UITableViewDataSource>
@property (strong) UILabel *descriptionLabel;
@property (strong) UITableView *myTable;

//@property FTDestination *destination;
@property (assign) int selectedDestinationId;
@property BOOL firstTime;
@property (nonatomic, strong) NSMutableArray *destinations;
@property (copy, nonatomic) NSIndexPath *checkedRow;
@property (weak, nonatomic) UIBarButtonItem *nextButton;

+ (void)setGoFromFixIt:(BOOL)val;
@end
