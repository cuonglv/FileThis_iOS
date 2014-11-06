//
//  AdjustPhotoViewController.h
//  FileThis
//
//  Created by Cuong Le on 7/28/14.
//
//

#import "MyDetailViewController.h"
#import "UIImage+Resize.h"

#define kUploadDocumentViewController_MaxCachedImageSize     CGSizeMake(2000, 2000)

@protocol AdjustPhotoViewControllerDelegate <NSObject>
- (void)adjustPhotoViewController:(id)sender doneWithImage:(UIImage*)image;
@end

@interface AdjustPhotoViewController : MyDetailViewController

@property (nonatomic, strong) IBOutlet NSLayoutConstraint *topVerticalSpacingConstraint;
@property (nonatomic, strong) IBOutlet UIScrollView *scrollView;
@property (nonatomic, strong) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) IBOutlet UIView *bottomContainerView;
@property (nonatomic, strong) IBOutlet UIButton *keepOriginalButton, *adjustPhotoButton;
@property (nonatomic, strong) IBOutlet UIView *adjustPhotoControlsContainterView;
@property (nonatomic, strong) IBOutlet UILabel *convertToGrayscaleLabel, *brightnessLabel, *contrastLabel;
@property (nonatomic, strong) IBOutlet UISwitch *convertToGrayscaleSwitch;
@property (nonatomic, strong) IBOutlet UISlider *brightnessSlider, *contrastSlider;
@property (nonatomic, strong) UIImage *originalImage;
@property (weak) id<AdjustPhotoViewControllerDelegate> delegate;

@end
