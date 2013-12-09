//
//  UploadController.m
//  FTMobile
//
//  Created by decuoi on 12/24/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "UploadController.h"
#import "UploadImageController.h"

@implementation UploadController

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    imgPicker = nil;
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    if ([[UIApplication sharedApplication] isStatusBarHidden]) {
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}



#pragma mark -
#pragma mark Button
- (IBAction)handleBtn:(id)sender {
    // Set up the image picker controller and add it to the view
    if (!imgPicker) {
        imgPicker = [[UIImagePickerController alloc] init];
        imgPicker.delegate = self;
        [self.view.window addSubview:imgPicker.view];
    }
    imgPicker.sourceType = (sender == btnBrowseLibrary ? UIImagePickerControllerSourceTypePhotoLibrary : UIImagePickerControllerSourceTypeCamera);
    imgPicker.view.hidden = NO;
    [self presentModalViewController:imgPicker animated:YES];
}


#pragma mark -
#pragma mark UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    //NSLog(@"UploadCon - select image - info: %@", [info description]);
    NSString *sMediaType = [info valueForKey:UIImagePickerControllerMediaType];
    
    //NSLog(@"Img type: %@", sMediaType);
    if ([sMediaType rangeOfString:@"image"].length > 0) { //ensure that user select only image (not movie or something else)
        [picker dismissModalViewControllerAnimated:NO];
        picker.view.hidden = YES;
        
        UIImage *img = [info valueForKey:UIImagePickerControllerEditedImage];
        if (!img)
            img = [info valueForKey:UIImagePickerControllerOriginalImage];
        
        //NSLog(@"Image selected",@"");
        
        //go to Upload File screen
        UploadImageController *target = [[UploadImageController alloc] initWithNibName:@"UploadImageController" bundle:[NSBundle mainBundle] image:img];
        [self.navigationController pushViewController:target animated:YES];
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // Dismiss the image selection and close the program
    [picker dismissModalViewControllerAnimated:YES];
    picker.view.hidden = YES;
}
@end
