//
//  NewConnectionViewController.h
//  FileThis
//
//  Created by Cuong Le on 11/20/13.
//
//

#import <UIKit/UIKit.h>

@interface ConnectionViewController : UIViewController

- (IBAction)cancel:(UIStoryboardSegue *)segue;
- (IBAction)save:(UIStoryboardSegue *)segue;
- (IBAction)destinationConfigured:(UIStoryboardSegue *)segue;

@end
