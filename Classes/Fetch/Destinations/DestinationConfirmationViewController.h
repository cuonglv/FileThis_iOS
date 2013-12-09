//
//  DestinationConfirmationViewController.h
//  FileThis
//
//  Created by Drew Wilson on 2/26/13.
//
//

#import <UIKit/UIKit.h>

@class FTDestination;

@interface DestinationConfirmationViewController : UIViewController

- (IBAction)connect:(id)sender;

@property (nonatomic) NSInteger destinationId;
@property BOOL firstTime;
@property BOOL alertUser;
@property (strong) NSString *authenticationString;

@end
