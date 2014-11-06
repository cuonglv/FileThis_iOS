//
//  AdjustPhotoViewController.m
//  FileThis
//
//  Created by Cuong Le on 7/28/14.
//
//

#import "AdjustPhotoViewController.h"
#import "ThreadManager.h"

@interface AdjustPhotoViewController() <UIScrollViewDelegate> {
    NSMutableArray *threadObjs;
    BOOL isFirstLoading;
    BOOL isKeepingOriginal;
}

@end

@implementation AdjustPhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isFirstLoading = YES;
    isKeepingOriginal = NO;
    threadObjs = [[NSMutableArray alloc] init];

    self.topVerticalSpacingConstraint.constant = [self.topBarView bottom] + 8;
    
    self.titleLabel.text = @"Adjust Photo";
    [self addTopRightBarButton:@"Done" width:60 target:self selector:@selector(handleDoneButton)];
    
    self.loadingView = [[LoadingView alloc] init];
    self.scrollView.delegate = self;
    
    //load last settings
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *photoAdjustmentSettingsDictionary = [defaults objectForKey:@"photoAdjustmentSettings"];
    if (photoAdjustmentSettingsDictionary) {
        NSNumber *keepOrginal = [photoAdjustmentSettingsDictionary objectForKey:@"keepOriginal"];
        if (keepOrginal) {
            if ([keepOrginal boolValue]) {
                isKeepingOriginal = YES;
            } else { //swith to "Adjust photo" option
                NSNumber *isGrayscale = [photoAdjustmentSettingsDictionary objectForKey:@"isGrayscale"];
                if (isGrayscale)
                    self.convertToGrayscaleSwitch.on = [isGrayscale boolValue];
                
                NSNumber *brightness = [photoAdjustmentSettingsDictionary objectForKey:@"brightness"];
                if (brightness)
                    self.brightnessSlider.value = [brightness floatValue];
                
                NSNumber *contrast = [photoAdjustmentSettingsDictionary objectForKey:@"contrast"];
                if (contrast)
                    self.contrastSlider.value = [contrast floatValue];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    //adjust scroll view and image view
    float width, height;
    if (self.originalImage.size.width < self.scrollView.frame.size.width)
        width = self.scrollView.frame.size.width;
    else
        width = self.originalImage.size.width;
    
    if (self.originalImage.size.height < self.scrollView.frame.size.height)
        height = self.scrollView.frame.size.height;
    else
        height = self.originalImage.size.height;
    
    self.scrollView.contentSize = CGSizeMake(width, height);
    [self.imageView removeFromSuperview];
    self.imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, width, height)];
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.scrollView addSubview:self.imageView];
    
    float minScale = self.scrollView.frame.size.width  / self.imageView.frame.size.width;
    self.scrollView.minimumZoomScale = minScale;
    self.scrollView.maximumZoomScale = 2.0;
    self.scrollView.zoomScale = minScale;
    
    //first load
    if (isFirstLoading)
        [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executePreprocessImage:threadObj:) argument:@""];
    else
        [self enableControlsForSelectedButton];
}

- (BOOL)shouldUseBackButton {
    return YES;
}

- (void)relayout {
    [super relayout];
}


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

#pragma mark - Controls
- (IBAction)handleConvertToGrayscaleSwitchValueChanged:(id)sender {
    [self applyChange];
}

- (IBAction)handleContrastSliderValueChanged:(id)sender {
    [self applyChange];
}

- (IBAction)handleBrightnessSliderValueChanged:(id)sender {
    [self applyChange];
}

#pragma mark - Button
- (IBAction)handleKeepOriginButton:(id)sender {
    isKeepingOriginal = YES;
    [self enableControlsForSelectedButton];
}

- (IBAction)handleAdjustPhotoButton:(id)sender {
    isKeepingOriginal = NO;
    [self enableControlsForSelectedButton];
}

- (void)handleDoneButton {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    //save current settings, for later reference
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *photoAdjustmentSettingsDictionary;
    if (isKeepingOriginal) {
        photoAdjustmentSettingsDictionary = @{@"keepOriginal" : [NSNumber numberWithBool:YES], @"isGrayscale" : [NSNumber numberWithBool:NO], @"brightness" : [NSNumber numberWithFloat:1.0], @"contrast" : [NSNumber numberWithFloat:1.0]};
    } else {
        photoAdjustmentSettingsDictionary = @{@"keepOriginal" : [NSNumber numberWithBool:NO], @"isGrayscale" : [NSNumber numberWithBool:self.convertToGrayscaleSwitch.on], @"brightness" : [NSNumber numberWithFloat:self.brightnessSlider.value], @"contrast" : [NSNumber numberWithFloat:self.contrastSlider.value]};
    }
    [defaults setObject:photoAdjustmentSettingsDictionary forKey:@"photoAdjustmentSettings"];
	[defaults synchronize];
    
    //call back delegate
    [self.delegate adjustPhotoViewController:self doneWithImage:self.imageView.image];
    
    //quit screen
    [self.navigationController popViewControllerAnimated:YES];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

#pragma mark - MyFunc
- (void)executePreprocessImage:(id)img threadObj:(id<ThreadProtocol>)threadObj {
    //UIImage *resizedImage = [img resizedImageAroundFileLength:kUploadDocumentViewController_MaxDisplayedImageFileLength];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.loadingView startLoadingInView:self.view frame:CGRectMake(self.scrollView.center.x-90, self.scrollView.center.y-90, 180, 180) message:@"Processing..."];
    });
    
    //resize displayed image to reduce memory usage, avoid app crash
    NSData *imageData = UIImageJPEGRepresentation(self.originalImage, 0.9);
    UIImage *adjustedImage = [UIImage imageWithData:imageData];
    self.originalImage = [adjustedImage resizedImageToFitSize:kUploadDocumentViewController_MaxCachedImageSize];
    
//            [self.takenImages addObject:resizedImage];
//            self.totalTakenImagesDataSize += [resizedImage calculatedSize];
//            NSLog(@"-- UploadDocumentViewController - add new photo %.0f x %.0f - data size %i",resizedImage.size.width,resizedImage.size.height,[resizedImage calculatedSize]);
//            NSLog(@"-- UploadDocumentViewController - totalTakenImagesDataSize %.0f",self.totalTakenImagesDataSize);
            
//            self.descriptionLabel.text = NSLocalizedString(@"ID_PHOTOS_GUIDE", @"");
//            [self.descriptionLabel setTop:10];
//            [self.descriptionLabel moveToHorizontalCenterOfSuperView];
//            self.finishButton.hidden = NO;
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.loadingView stopLoading];
        [self enableControlsForSelectedButton];
        self.bottomContainerView.hidden = NO;
    });
    [threadObj releaseOperation];
}


- (void)enableControlsForSelectedButton {
    UIButton *activeButton, *inactiveButton;
    if (isKeepingOriginal) {
        activeButton = self.keepOriginalButton;
        inactiveButton = self.adjustPhotoButton;
    } else {
        activeButton = self.adjustPhotoButton;
        inactiveButton = self.keepOriginalButton;
    }
    
    activeButton.backgroundColor = kTextOrangeColor;
    [activeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    inactiveButton.backgroundColor = [UIColor colorWithRedInt:222 greenInt:222 blueInt:222];
    [inactiveButton setTitleColor:kTextOrangeColor forState:UIControlStateNormal];
    
    self.adjustPhotoControlsContainterView.hidden = isKeepingOriginal;
    
    if (isKeepingOriginal) {
        [self displayImage:self.originalImage];
    } else {
        [self applyChange];
    }
}

- (void)applyChange {
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeApplyChange:threadObj:) argument:@""];
}

- (void)executeApplyChange:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    [threadObjs addObject:threadObj];
    [NSThread sleepForTimeInterval:0.1];
    CIImage *inputImage = [CIImage imageWithCGImage:self.originalImage.CGImage];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.loadingView startLoadingInView:self.view frame:CGRectMake(self.scrollView.center.x-90, self.scrollView.center.y-90, 180, 180) message:@"Processing..."];
    });
    
    CIFilter *filter;
    if (self.convertToGrayscaleSwitch.on) {
        filter = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:@"inputImage", inputImage, @"inputColor", [CIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.0f], @"inputIntensity", [NSNumber numberWithFloat:1.f], nil]; // 3
        inputImage = filter.outputImage;
    }
    
    if ([threadObjs lastObject] == threadObj) { //always check this is last thread in queue, to continue
        filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, inputImage, @"inputPower", [NSNumber numberWithFloat:self.brightnessSlider.maximumValue-self.brightnessSlider.value], nil];
        inputImage = filter.outputImage;
        
        if ([threadObjs lastObject] == threadObj) { //always check this is last thread in queue, to continue
            filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:@"inputImage", inputImage, @"inputContrast", [NSNumber numberWithFloat:self.contrastSlider.value], nil];
            inputImage = filter.outputImage;
            
            //2nd loop converting
            if ([threadObjs lastObject] == threadObj) { //always check this is last thread in queue, to continue
                if (self.convertToGrayscaleSwitch.on) {
                    filter = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:@"inputImage", inputImage, @"inputColor", [CIColor colorWithRed:1.f green:1.f blue:1.f alpha:1.0f], @"inputIntensity", [NSNumber numberWithFloat:1.f], nil]; // 3
                    inputImage = filter.outputImage;
                }
                
                if ([threadObjs lastObject] == threadObj) { //always check this is last thread in queue, to continue
                    filter = [CIFilter filterWithName:@"CIGammaAdjust" keysAndValues:kCIInputImageKey, inputImage, @"inputPower", [NSNumber numberWithFloat:self.brightnessSlider.maximumValue-self.brightnessSlider.value], nil];
                    inputImage = filter.outputImage;
                    
                    if ([threadObjs lastObject] == threadObj) { //always check this is last thread in queue, to continue
                        filter = [CIFilter filterWithName:@"CIColorControls" keysAndValues:@"inputImage", inputImage, @"inputContrast", [NSNumber numberWithFloat:self.contrastSlider.value], nil];
                        inputImage = filter.outputImage;
                        
                        CIContext *context = [CIContext contextWithOptions:nil];
                        if ([threadObjs lastObject] == threadObj) { //this is last thread in queue, continue
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                CGImageRef cgImage = [context createCGImage:inputImage fromRect:inputImage.extent];
                                UIImageOrientation originalOrientation = self.originalImage.imageOrientation;
                                CGFloat originalScale = self.originalImage.scale;
                                [self displayImage:[UIImage imageWithCGImage:cgImage scale:originalScale orientation:originalOrientation]];
                                CGImageRelease(cgImage);
                            });
                        }
                    }
                }
            }
        }
    }
    @synchronized(threadObjs) {
        [threadObjs removeObject:threadObj];
        if ([threadObjs count] == 0) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self.loadingView stopLoading];
            });
        }
    }
    [threadObj releaseOperation];
    NSLog(@"threadObjs - count %i", [threadObjs count]);
}

- (void)displayImage:(UIImage*)image {
    CGPoint p = [self.scrollView contentOffset];
    self.imageView.image = image;
    self.scrollView.contentOffset = p;
    [self.scrollView setNeedsDisplay];
}

@end