//
//  ConnectionErrorViewController.h
//  FileThis
//
//  Created by Drew Wilson on 12/28/12.
//
//

#import <UIKit/UIKit.h>
#import "FTConnection.h"
#import "ConnectionViewController.h"

@interface ConnectionErrorViewController : UIViewController <UIPopoverControllerDelegate>
@property (strong) UIPopoverController *popover;
@property (weak) ConnectionViewController *host;

- (void)setConnection:(FTConnection *)connection;
@end
