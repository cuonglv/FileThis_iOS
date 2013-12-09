//
//  DestinationsListViewController.h
//  FileThis
//
//  Created by Drew Wilson on 1/6/13.
//
//

#import <UIKit/UIKit.h>

@class FTDestination;

@interface DestinationPickerViewController : UITableViewController

@property FTDestination *destination;
@property BOOL hidesBackButton;
@property BOOL firstTime;

- (IBAction)cancel:(id)sender;

- (IBAction)cancelPickingDestination:(UIStoryboardSegue *)segue;
- (IBAction)donePickingDestination:(UIStoryboardSegue *)segue;

@end
