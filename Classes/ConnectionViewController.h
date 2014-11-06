//
//  NewConnectionViewController.h
//  FileThis
//
//  Created by Cuong Le on 11/20/13.
//
//

#import <UIKit/UIKit.h>
#import "MyDetailViewController.h"

@interface ConnectionViewController : MyDetailViewController

- (IBAction)cancel:(UIStoryboardSegue *)segue;
- (IBAction)save:(UIStoryboardSegue *)segue;
- (IBAction)destinationConfigured:(UIStoryboardSegue *)segue;

@end
