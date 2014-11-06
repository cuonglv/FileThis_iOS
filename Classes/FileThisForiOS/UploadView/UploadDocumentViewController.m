//
//  UploadDocumentViewController.m
//  FileThis
//
//  Created by Cuong Le on 12/16/13.
//
//

#import <AssetsLibrary/AssetsLibrary.h>
#import "UploadDocumentViewController.h"
#import "CommonLayout.h"
#import "NumberHandler.h"
#import "FinishUploadingViewController.h"
#import "UploadDocumentCell.h"
#import "ScanView.h"
#import "EditPhotoViewController.h"
#import "Constants.h"
#import "UIImage+Resize.h"
#import "SnapshotPhotoPickerViewController.h"
#import "FTMobileAppDelegate.h"
#import "FTSession.h"
#import <AVFoundation/AVFoundation.h>
#import "AdjustPhotoViewController.h"

#define kAlertMessageTag_ConfirmDelete  1
#define kAlertMessageTag_ExeedSpace     2

#define kUploadDocumentViewController_PopoverContentSize CGSizeMake(400,340)

@interface UploadDocumentViewController () <ScanViewDelegate, UploadDocumentCellDelegate, EditPhotoViewControllerDelegate, AdjustPhotoViewControllerDelegate>
@property (nonatomic, strong) UILabel *descriptionLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIButton *pickPhotoFromLibraryButton, *takePictureButton, *finishButton;
@property (nonatomic, strong) UIImagePickerController *imagePickerController;
@property (nonatomic, strong) UIPopoverController *imagePopoverController;
@property (nonatomic, strong) NSMutableArray *takenImages;
@property (nonatomic, strong) UICollectionView *myCollectionView;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;
@property (nonatomic, strong) UIImageView *testImageView;
@property (assign) double totalTakenImagesDataSize;
@property (assign) double availableSpaceForAccount;

@property BOOL flashShouldOn;
@end

@implementation UploadDocumentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.totalTakenImagesDataSize = 0.0;
    self.takenImages = [[NSMutableArray alloc] init];
    self.titleLabel.text = @"Upload";
    self.loadingView = [[LoadingView alloc] init];
    
    FTAccountSettings *settings = [FTSession sharedSession].settings;
    self.availableSpaceForAccount = settings.storageQuota - settings.storage; //KB
    self.availableSpaceForAccount *= 1000; //Convert to bytes
    
    self.pickPhotoFromLibraryButton = [self addBottomCenterBarButton:NSLocalizedString(@"ID_PHOTO_LIBRARY", @"") image:[UIImage imageNamed:@"pic_icon_white.png"] target:self selector:@selector(handlePickPhotoFromLibraryButton:)];
    //if ([UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceRear]) {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        self.takePictureButton = [self addBottomCenterBarButton:NSLocalizedString(@"ID_SNAPSHOT", @"") image:[UIImage imageNamed:@"camera_icon_white.png"] target:self selector:@selector(handleTakePictureButton:)];
    }
    
    self.finishButton = [self addTopRightBarButton:NSLocalizedString(@"ID_DONE", @"") target:self selector:@selector(handleFinishButton:)];
    self.finishButton.hidden = YES;
    
    self.contentView.backgroundColor = [UIColor blackColor];
    self.descriptionLabel = [CommonLayout createLabel:CGRectMake(0, 5, self.contentView.frame.size.width - 10, (IS_IPHONE ? 100 : 60)) fontSize:(IS_IPHONE ? FontSizeXSmall : FontSizeMedium) isBold:NO isItalic:YES textColor:[UIColor whiteColor] backgroundColor:nil text:NSLocalizedString(@"ID_NO_PHOTO_TAKEN", @"") superView:self.contentView];
    self.descriptionLabel.textAlignment = NSTextAlignmentCenter;
    self.descriptionLabel.numberOfLines = (IS_IPHONE ? 4 : 2);
    [self.descriptionLabel moveToCenterOfSuperView];
    
    DraggableCollectionViewFlowLayout *layout = [[DraggableCollectionViewFlowLayout alloc] init];
    self.myCollectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(20, self.descriptionLabel.frame.size.height+20, self.contentView.frame.size.width - 40, self.contentView.frame.size.height - self.descriptionLabel.frame.size.height - 30) collectionViewLayout:layout];
    self.myCollectionView.draggable = YES;
    self.myCollectionView.dataSource = self;
    self.myCollectionView.delegate = self;
    [self.myCollectionView registerClass:[UploadDocumentCell class] forCellWithReuseIdentifier:@"cellIdentifier"];
    self.myCollectionView.allowsSelection = YES;
    self.myCollectionView.backgroundColor = [UIColor clearColor];
    [self.contentView addSubview:self.myCollectionView];
    
//    self.testImageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 100, 400, 400)];
//    [self.contentView addSubview:self.testImageView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.imagePopoverController) {
        [self.imagePopoverController dismissPopoverAnimated:NO];
        self.imagePopoverController = nil;
        self.imagePickerController = nil;
    }
}

- (void)relayout {
    [super relayout];
    [self.descriptionLabel setWidth:self.contentView.frame.size.width];
    if ([self.takenImages count] == 0) {
        [self.descriptionLabel moveToCenterOfSuperView];
    } else {
        [self.descriptionLabel setTop:10];
        [self.descriptionLabel moveToHorizontalCenterOfSuperView];
    }
    [self.myCollectionView setRightWithoutChangingLeft:self.contentView.frame.size.width-20 bottomWithoutChangingTop:self.contentView.frame.size.height-20];
    [self.myCollectionView reloadData];
    
    if (self.imagePopoverController.isPopoverVisible) {
        [self.imagePopoverController presentPopoverFromRect:[self.bottomBarView convertRect:self.pickPhotoFromLibraryButton.frame toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];
    }
}

- (BOOL)shouldHideToolBar {
    return NO;
}

#pragma mark - Override
- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    return (IS_IPHONE ? 15.0 : 40.0);
}

#pragma mark - CollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.takenImages count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UploadDocumentCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cellIdentifier" forIndexPath:indexPath];
    cell.delegate = self;
    [cell setImage:[self.takenImages objectAtIndex:indexPath.row]];
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(kUploadDocumentCell_Size,kUploadDocumentCell_Size);
}

- (BOOL)collectionView:(LSCollectionViewHelper *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)indexPath toIndexPath:(NSIndexPath *)toIndexPath {
    return YES;
}

- (void)collectionView:(LSCollectionViewHelper *)collectionView moveItemAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    UIImage *data = [self.takenImages objectAtIndex:fromIndexPath.row];
    [self.takenImages removeObjectAtIndex:fromIndexPath.row];
    [self.takenImages insertObject:data atIndex:toIndexPath.row];
}

#pragma mark - UIImagePickerControllerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowShowPickerPopover = YES;
    
    if (![self checkTotalDataSize]) {
        [self dismissViewControllerAnimated:YES completion:nil];
        return;
    }
    
    NSString *sMediaType = [info valueForKey:UIImagePickerControllerMediaType];
    
    if ([sMediaType rangeOfString:@"image"].length > 0) { //ensure that user select only image (not movie or something else)
        UIImage *img = [info valueForKey:UIImagePickerControllerEditedImage];
        if (!img)
            img = [info valueForKey:UIImagePickerControllerOriginalImage];
        
        [self dismissViewControllerAnimated:YES completion:nil];
        self.imagePickerController = nil;
        //[self.myCollectionView reloadData];
        
        if (img.size.width < 100 || img.size.height < 100) {
            [CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_PHOTO_MINIMUM_SIZE", @"") errorMessage:nil delegate:nil];
        } else {
            AdjustPhotoViewController *target = [[AdjustPhotoViewController alloc] initWithNibName:@"AdjustPhotoViewController" bundle:[NSBundle mainBundle]];
            target.delegate = self;
            target.originalImage = img;
            [self.navigationController pushViewController:target animated:YES];
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.allowShowPickerPopover = YES;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UIAlertView
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kAlertMessageTag_ConfirmDelete) {
        if (buttonIndex == 0) {
            if (self.selectedIndexPath) {
                if (self.selectedIndexPath.row < [self.takenImages count]) {
                    UIImage *image = [self.takenImages objectAtIndex:self.selectedIndexPath.row];
                    self.totalTakenImagesDataSize -= [image calculatedSize];
                    NSLog(@"-- UploadDocumentViewController - totalTakenImagesDataSize %.0f",self.totalTakenImagesDataSize);
                    [self.takenImages removeObjectAtIndex:self.selectedIndexPath.row];
                }
            }
        }
        [(UploadDocumentCell*)[self.myCollectionView cellForItemAtIndexPath:self.selectedIndexPath] setHighlighted:NO];
        self.selectedIndexPath = nil;
        [self.myCollectionView reloadData];
        return;
    }
    
    if (alertView.tag == kAlertMessageTag_ExeedSpace) {
        NSLog(@"%d", buttonIndex);
        FTMobileAppDelegate *app = (FTMobileAppDelegate*)[UIApplication sharedApplication].delegate;
        if (buttonIndex == 1) { //Upgrade
            [app gotoPurchase];
        } else if (buttonIndex == 2) { //Invite new friend
            [app goToInviteFriend];
        }
    }
}

#pragma mark - AdjustPhotoViewControllerDelegate
- (void)adjustPhotoViewController:(id)sender doneWithImage:(UIImage *)image {
    UIImage *resizedImage = [image resizedImageToFitSize:kUploadDocumentViewController_MaxCachedImageSize];
    [self.takenImages addObject:resizedImage];
    self.totalTakenImagesDataSize += [resizedImage calculatedSize];
    [self.myCollectionView reloadData];
    
    self.descriptionLabel.text = NSLocalizedString(@"ID_PHOTOS_GUIDE", @"");
    [self.descriptionLabel setTop:10];
    [self.descriptionLabel moveToHorizontalCenterOfSuperView];
    self.finishButton.hidden = NO;
}

#pragma mark - ScanViewDelegate
- (void)scanViewExit:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)scanViewSwitchCamera:(id)sender {
    if (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront) {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    } else {
        self.imagePickerController.cameraDevice = UIImagePickerControllerCameraDeviceFront;
    }
    [self setFlashLightOn:NO];
}

- (void)scanViewTakePhoto:(id)sender {
    /*if (self.flashShouldOn) {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOn;
    } else {
        self.imagePickerController.cameraFlashMode = UIImagePickerControllerCameraFlashModeOff;
    }*/
    
    [self.imagePickerController takePicture];
}

- (void)scanViewSwitchFlashStatus:(id)sender {
    self.flashShouldOn = !self.flashShouldOn;
    [self setFlashLightOn:self.flashShouldOn];
}

#pragma mark - UploadDocumentCellDelegate
- (void)uploadDocumentCellTouched:(id)sender {
    UploadDocumentCell *cell = (UploadDocumentCell*)sender;
    NSIndexPath *indexPath = [self.myCollectionView indexPathForCell:cell];
    if (indexPath) {
        if (indexPath.row < [self.takenImages count]) {
            EditPhotoViewController *target = [[EditPhotoViewController alloc] init];
            target.image = [self.takenImages objectAtIndex:indexPath.row];
            target.delegate = self;
            [self.navigationController pushViewController:target animated:YES];
        }
    }
}

- (void)uploadDocumentCellRemoved:(id)sender {
    UploadDocumentCell *cell = (UploadDocumentCell*)sender;
    NSIndexPath *indexPath = [self.myCollectionView indexPathForCell:cell];
    if (indexPath) {
        if (indexPath.row < [self.takenImages count]) {
            self.selectedIndexPath = indexPath;
            [cell setHighlighted:YES];
            [CommonLayout showConfirmAlert:NSLocalizedString(@"ID_CONFIRM_DELETE_PHOTO", @"") tag:kAlertMessageTag_ConfirmDelete delegate:self];
        }
    }
}

#pragma mark - EditPhotoViewControllerDelegate
- (void)editPhotoViewController:(id)sender shouldDeleteImage:(UIImage *)img {
    self.totalTakenImagesDataSize -= [img calculatedSize];
    NSLog(@"-- UploadDocumentViewController - totalTakenImagesDataSize %.0f",self.totalTakenImagesDataSize);
    [self.takenImages removeObject:img];
    if ([self.takenImages count] == 0) {
        self.descriptionLabel.text = NSLocalizedString(@"ID_NO_PHOTO_TAKEN", @"");
        [self.descriptionLabel moveToCenterOfSuperView];
    }
    [self.myCollectionView reloadData];
}

- (void)editPhotoViewController:(id)sender changedFromImage:(UIImage*)originalImage toNewImage:(UIImage*)newImage {
    self.totalTakenImagesDataSize += [newImage calculatedSize] - [originalImage calculatedSize];
    NSLog(@"-- UploadDocumentViewController - totalTakenImagesDataSize %.0f",self.totalTakenImagesDataSize);
    [self.takenImages replaceObjectAtIndex:[self.takenImages indexOfObject:originalImage] withObject:newImage];
    [self.myCollectionView reloadData];
}

#pragma mark - Button
- (void)handlePickPhotoFromLibraryButton:(id)sender {
    if (![self checkTotalDataSize])
        return;
    
    // Photo Library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        void(^blk)() =  ^() {
            self.imagePickerController = [[UIImagePickerController alloc] init];
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            self.imagePickerController.delegate = self;
            self.imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
            
            FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
            if (!appDelegate.allowShowPickerPopover) {
                return;
            }
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.imagePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.imagePickerController];
                [self.imagePopoverController setPopoverContentSize:kUploadDocumentViewController_PopoverContentSize];
                [self.imagePopoverController presentPopoverFromRect:[self.bottomBarView convertRect:self.pickPhotoFromLibraryButton.frame toView:self.view] inView:self.view permittedArrowDirections:UIPopoverArrowDirectionDown animated:NO];
            } else {
                [self presentViewController:self.imagePickerController animated:YES completion:nil];
            }
            
            //[self presentViewController:self.imagePickerController animated:YES completion:nil];
        };
        
        // Make sure we have permission, otherwise request it first
        ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
        ALAuthorizationStatus authStatus;
        authStatus = [ALAssetsLibrary authorizationStatus];
        
        if (authStatus == ALAuthorizationStatusAuthorized) {
            blk();
        } else if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted) {
            [CommonLayout showWarningAlert:@"Grant permission to your photos. Go to Settings App > Privacy > Photos." errorMessage:nil delegate:nil];
        } else if (authStatus == ALAuthorizationStatusNotDetermined) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                // Catch the final iteration, ignore the rest
                if (group == nil)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        blk();
                    });
                *stop = YES;
            } failureBlock:^(NSError *error) {
                // failure :(
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CommonLayout showWarningAlert:@"Grant permission to your photos. Go to Settings App > Privacy > Photos." errorMessage:nil delegate:nil];
                });
            }];
        }
    }
}

- (void)handleTakePictureButton:(id)sender {
    if (![self checkTotalDataSize])
        return;
    
    // Photo Library
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        void(^blk)() =  ^() {
            self.imagePickerController = [[SnapshotPhotoPickerViewController alloc] init];
            self.imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
            self.imagePickerController.delegate = self;
            self.imagePickerController.toolbarHidden = YES;
            self.imagePickerController.showsCameraControls = NO;
            self.imagePickerController.modalPresentationStyle = UIModalPresentationFullScreen;
            self.flashShouldOn = NO;
            
            ScanView *scanView = [[ScanView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) delegate:self];
            self.imagePickerController.cameraOverlayView = scanView;
            scanView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            [self presentViewController:self.imagePickerController animated:YES completion:nil];
        };
        
        // Make sure we have permission, otherwise request it first
        ALAssetsLibrary* assetsLibrary = [[ALAssetsLibrary alloc] init];
        ALAuthorizationStatus authStatus;
        authStatus = [ALAssetsLibrary authorizationStatus];
        
        if (authStatus == ALAuthorizationStatusAuthorized) {
            blk();
        } else if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted) {
            [CommonLayout showWarningAlert:@"Grant permission to your photos. Go to Settings App > Privacy > Photos." errorMessage:nil delegate:nil];
        } else if (authStatus == ALAuthorizationStatusNotDetermined) {
            [assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
                // Catch the final iteration, ignore the rest
                if (group == nil)
                    dispatch_async(dispatch_get_main_queue(), ^{
                        blk();
                    });
                *stop = YES;
            } failureBlock:^(NSError *error) {
                // failure
                dispatch_async(dispatch_get_main_queue(), ^{
                    [CommonLayout showWarningAlert:@"Grant permission to your photos. Go to Settings App > Privacy > Photos." errorMessage:nil delegate:nil];
                });
            }];
        }
    }
} //

- (void)handleFinishButton:(id)sender {
    if ([self.takenImages count] == 0) {
        [CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_TAKE_PHOTO_FIRST", @"") errorMessage:nil delegate:nil];
        return;
    }
    FinishUploadingViewController *target = [[FinishUploadingViewController alloc] initWithTakenImages:self.takenImages];
    [self.navigationController pushViewController:target animated:YES];
}

#pragma mark - Func
- (BOOL)checkTotalDataSize {
    if (self.totalTakenImagesDataSize > self.availableSpaceForAccount) {
        //[CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_EXCEED_AVAILABLE_SPACE", @"") errorMessage:nil delegate:nil];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"More Space Needed" message:NSLocalizedString(@"ID_WARNING_EXCEED_AVAILABLE_SPACE", @"") delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:NSLocalizedString(@"ID_OPTION_UPGRADE", @""), NSLocalizedString(@"ID_OPTION_INVITE", @""), nil];
        alert.tag = kAlertMessageTag_ExeedSpace;
        [alert show];
        return NO;
    }
    
    if (self.totalTakenImagesDataSize > kUploadDocumentViewController_MaxTotalUploadedPhotoDataSize) {
        [CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_TOTAL_UPLOADED_DATA_SIZE", @"") errorMessage:nil delegate:nil];
        return NO;
    }
    return YES;
}

- (void)setFlashLightOn:(BOOL)on
{
    if (on && (self.imagePickerController.cameraDevice == UIImagePickerControllerCameraDeviceFront)) {
        return;
    }
    
    AVCaptureTorchMode mode;
    AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    self.flashShouldOn = on;
    if (on) {
        mode = AVCaptureTorchModeOn;
    } else {
        mode = AVCaptureTorchModeOff;
    }
    
	if ([device hasFlash] && [device isTorchModeSupported:mode])
	{
		NSError *error = nil;
		if ([device lockForConfiguration:&error])
		{
			[device setTorchMode:mode];
			[device unlockForConfiguration];
		}
		else
		{
			self.flashShouldOn = NO;
		}
	} else {
        self.flashShouldOn = NO;
    }
    
    ScanView *scanView = (ScanView*)self.imagePickerController.cameraOverlayView;
    if ([scanView isKindOfClass:[ScanView class]]) {
        [scanView updateFlashIcon:self.flashShouldOn];
    }
}

@end
