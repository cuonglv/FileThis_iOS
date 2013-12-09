//
//  CustomPageViewController.h
//  PageViewController
//
//  Created by Tom Fewster on 11/01/2012.
//

#import "PagerViewController.h"

@interface CustomPagerViewController : PagerViewController
- (void)signUpCompletedWithEmail:(NSString*)email password:(NSString*)password;

- (IBAction)login:(id)sender;
@end
