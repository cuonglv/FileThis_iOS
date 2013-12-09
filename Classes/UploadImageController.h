//
//  UploadImageController.h
//  FTMobile
//
//  Created by decuoi on 12/15/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAnimatedView.h"

@interface UploadImageController : UIViewController {
    IBOutlet UILabel *lblUploadProgress;
    IBOutlet UIButton *btnUpload;
    IBOutlet UIImageView *imv;
    IBOutlet UITextField *tfFileName;
    
    MyAnimatedView *vwAnimated;
    
    NSMutableData *myData;
    
    long long lDocSize;
    UIImage *img;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage*)image;

#pragma mark -
#pragma mark Button
- (IBAction)handleUploadBtn;
@end
