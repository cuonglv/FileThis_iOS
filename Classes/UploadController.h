//
//  UploadController.h
//  FTMobile
//
//  Created by decuoi on 12/24/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface UploadController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    IBOutlet UIButton *btnTakePhoto, *btnBrowseLibrary;
    UIImagePickerController *imgPicker;
}
- (IBAction)handleBtn:(id)sender;

#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info;
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker;

@end
