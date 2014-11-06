//
//  SnapshotPhotoPickerViewController.m
//  FileThis
//
//  Created by Cuong Le on 1/28/14.
//
//

#import "SnapshotPhotoPickerViewController.h"

@interface SnapshotPhotoPickerViewController ()

@end

@implementation SnapshotPhotoPickerViewController

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    self.view.frame = CGRectMake(0, 0, self.view.frame.size.height, self.view.frame.size.width);
    self.cameraOverlayView.frame = self.view.bounds;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    self.cameraOverlayView.frame = self.view.bounds;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.cameraOverlayView.frame = self.view.bounds;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.cameraOverlayView.frame = self.view.bounds;
}

@end
