//
//  ScanView.m
//  FileThis
//
//  Created by Cuong Le on 1/15/14.
//
//

#import "ScanView.h"
#import "CommonLayout.h"
#import "FTMobileAppDelegate.h"

@interface ScanView()

@property (nonatomic, assign) id<ScanViewDelegate> delegate;
@property (nonatomic, strong) UIView *topBarView, *bottomBarView;
@property (nonatomic, strong) UIButton *exitButton, *switchCameraButton, *takePhotoButton;
@property (nonatomic, strong) UIButton *btnFlash;

@end

@implementation ScanView

- (id)initWithFrame:(CGRect)frame delegate:(id<ScanViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        
        self.topBarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 70)];
        self.topBarView.backgroundColor = [UIColor blackColor];
        self.topBarView.layer.opacity = 0.5;
        [self addSubview:self.topBarView];
        
        float buttonHeight = roundf((self.topBarView.frame.size.height - kIOS7CarrierbarHeight) * 0.9);
        self.exitButton = [CommonLayout createImageButton:CGRectMake(6, kIOS7CarrierbarHeight/2 + self.topBarView.frame.size.height/2 - buttonHeight/2, buttonHeight, buttonHeight) image:[UIImage imageNamed:@"x_icon_white.png"] contentMode:UIViewContentModeScaleAspectFit touchTarget:self touchSelector:@selector(handleExitButon) superView:self];
        
        if ([UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceRear]
            || [UIImagePickerController isFlashAvailableForCameraDevice:UIImagePickerControllerCameraDeviceFront]) {
            CGRect rect = CGRectMake([self.exitButton right] + 10, 30, 30, 30);
            self.btnFlash = [CommonLayout createImageButton:rect image:[UIImage imageNamed:@"icon_flash_off.png"] contentMode:UIViewContentModeScaleToFill touchTarget:self touchSelector:@selector(handleFlashButton:) superView:self];
        }
        
        if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront]
            && [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear])
        {
            self.switchCameraButton = [CommonLayout createImageButton:CGRectMake(self.topBarView.frame.size.width - 6 - buttonHeight, [self.exitButton top], buttonHeight, buttonHeight) image:[UIImage imageNamed:@"camera_switch_icon_white.png"] contentMode:UIViewContentModeScaleAspectFit touchTarget:self touchSelector:@selector(handleSwitchCameraButon) superView:self.topBarView];
        }
        
        self.bottomBarView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height - 120, self.frame.size.width, 120)];
        self.bottomBarView.backgroundColor = [UIColor blackColor];
        self.bottomBarView.layer.opacity = 0.5;
        [self addSubview:self.bottomBarView];
        
        buttonHeight = roundf(self.bottomBarView.frame.size.height * 0.9);
        self.takePhotoButton = [CommonLayout createImageButton:CGRectMake(self.bottomBarView.frame.size.width/2 - buttonHeight/2, self.bottomBarView.frame.size.height/2 - buttonHeight/2, buttonHeight, buttonHeight) image:[UIImage imageNamed:@"take_photo_icon.png"] contentMode:UIViewContentModeScaleAspectFit touchTarget:self touchSelector:@selector(handleTakePhotoButon) superView:self.bottomBarView];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.topBarView.frame = CGRectMake(0, 0, self.frame.size.width, 70);
    [self.switchCameraButton setRight:self.topBarView.frame.size.width-6];
    self.bottomBarView.frame = CGRectMake(0, self.frame.size.height - 120, self.frame.size.width, 120);
    [self.takePhotoButton moveToCenterOfSuperView];
}

#pragma mark - Public methods
- (void)updateFlashIcon:(BOOL)turnon {
    if (turnon) {
        [self.btnFlash setImage:[UIImage imageNamed:@"icon_flash_on.png"] forState:UIControlStateNormal];
    } else {
        [self.btnFlash setImage:[UIImage imageNamed:@"icon_flash_off.png"] forState:UIControlStateNormal];
    }
}

#pragma mark - Button events
- (void)handleExitButon {
    [self.delegate scanViewExit:self];
}

- (void)handleSwitchCameraButon {
    [self.delegate scanViewSwitchCamera:self];
}

- (void)handleTakePhotoButon {
    [self.delegate scanViewTakePhoto:self];
}

- (void)handleFlashButton:(id)sender {
    if (self.delegate) {
        [self.delegate scanViewSwitchFlashStatus:self];
    }
}

@end
