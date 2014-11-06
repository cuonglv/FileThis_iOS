//
//  EditPhotoViewController.h
//  FileThis
//
//  Created by Cuong Le on 1/15/14.
//
//

#import "MyDetailViewController.h"

@protocol EditPhotoViewControllerDelegate <NSObject>

- (void)editPhotoViewController:(id)sender shouldDeleteImage:(UIImage*)img;
- (void)editPhotoViewController:(id)sender changedFromImage:(UIImage*)originalImage toNewImage:(UIImage*)newImage;

@end

@interface EditPhotoViewController : MyDetailViewController

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, assign) id<EditPhotoViewControllerDelegate> delegate;

@end
