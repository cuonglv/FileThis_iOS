//
//  EditPhotoViewController.m
//  FileThis
//
//  Created by Cuong Le on 1/15/14.
//
//

#import "EditPhotoViewController.h"
#import "Constants.h"
#import "PECropView.h"

#define kAlertMessageTag_ConfirmDelete  1

@interface EditPhotoViewController () <UIAlertViewDelegate>

@property (nonatomic, strong) UIButton *cancelButton, *doneButton, *editButton, *deleteButton;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) PECropView *peCropView;

@end

@implementation EditPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = NSLocalizedString(@"ID_EDIT_OR_DELETE_YOUR_PHOTO", @"");
    
    self.doneButton = [self addTopRightBarButton:NSLocalizedString(@"ID_DONE", @"") target:self selector:@selector(handleDoneButton)];
    
    self.cancelButton = [CommonLayout createTextButton:CGRectMake(10, [self.doneButton top], 80, self.doneButton.frame.size.height) font:self.doneButton.titleLabel.font text:NSLocalizedString(@"ID_CANCEL", @"") textColor:[UIColor whiteColor] touchTarget:self touchSelector:@selector(handleCancelButton) superView:self.topBarView];
    
    self.editButton = [self addBottomCenterBarButton:NSLocalizedString(@"ID_EDIT", @"") image:[UIImage imageNamed:@"edit_icon_white.png"] target:self selector:@selector(handleEditButton)];
    self.deleteButton = [self addBottomCenterBarButton:NSLocalizedString(@"ID_REMOVE", @"") image:[UIImage imageNamed:@"trash_icon_white.png"] target:self selector:@selector(handleDeleteButton)];
    
    float imageViewMargin;
    if (self.contentView.frame.size.width > self.contentView.frame.size.height)
        imageViewMargin = roundf(self.contentView.frame.size.height * 0.1);
    else
        imageViewMargin = roundf(self.contentView.frame.size.width * 0.1);
    
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectInset(self.contentView.bounds,imageViewMargin,imageViewMargin)];
    self.imageView.image = self.image;
    self.imageView.layer.borderWidth = 1;
    self.imageView.layer.borderColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0].CGColor;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.contentView addSubview:self.imageView];

    self.peCropView = [[PECropView alloc] initWithFrame:self.imageView.frame];
    self.contentView.backgroundColor = [UIColor blackColor];
    [self.contentView addSubview:self.peCropView];
    
    [self setEditControlsVisible:NO];
}

- (void)relayout {
    [super relayout];
    float imageViewMargin;
    if (self.contentView.frame.size.width > self.contentView.frame.size.height)
        imageViewMargin = roundf(self.contentView.frame.size.height * 0.1);
    else
        imageViewMargin = roundf(self.contentView.frame.size.width * 0.1);
    
    self.peCropView.frame = self.imageView.frame = CGRectInset(self.contentView.bounds,imageViewMargin,imageViewMargin);
}

- (BOOL)shouldHideToolBar {
    return NO;
}

- (BOOL)shouldUseBackButton {
    return YES;
}

//- (float)heightForBottomBar {
//    return 60.0;
//}

- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    return 40.0;
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertMessageTag_ConfirmDelete) {
        if (buttonIndex == 0) {
            [self.delegate editPhotoViewController:self shouldDeleteImage:self.image];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

#pragma mark - Button
- (void)handleCancelButton {
    [self setEditControlsVisible:NO];
}

- (void)handleDoneButton {
//    self.imageView.image = self.peCropView.croppedImage;
//    [self setEditControlsVisible:NO];
    [self.delegate editPhotoViewController:self changedFromImage:self.imageView.image toNewImage:self.peCropView.croppedImage];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)handleEditButton {
    self.peCropView.image = self.imageView.image;
    [self setEditControlsVisible:YES];
}

- (void)handleDeleteButton {
    [CommonLayout showConfirmAlert:NSLocalizedString(@"ID_CONFIRM_DELETE_PHOTO", @"") tag:kAlertMessageTag_ConfirmDelete delegate:self];
}

- (void)setEditControlsVisible:(BOOL)isEditting {
    self.imageView.hidden = self.backButton.hidden = isEditting;
    self.peCropView.hidden = self.cancelButton.hidden = self.doneButton.hidden = !isEditting;
    if (isEditting) {
        self.titleLabel.text = NSLocalizedString(@"ID_RESIZE_ROTATE_YOUR_PHOTO", @"");
        self.selectedBottomCenterBarButton = self.editButton;
    } else {
        self.titleLabel.text = NSLocalizedString(@"ID_EDIT_OR_DELETE_YOUR_PHOTO", @"");
        self.selectedBottomCenterBarButton = nil;
    }
}

@end
