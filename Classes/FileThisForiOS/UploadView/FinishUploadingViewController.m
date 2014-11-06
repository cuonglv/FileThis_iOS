//
//  FinishUploadingViewController.m
//  FileThis
//
//  Created by Cuong Le on 12/17/13.
//
//

#import "FinishUploadingViewController.h"
#import "Constants.h"
#import "PdfHandler.h"
#import "FTMobileAppDelegate.h"
#import "CommonVar.h"
#import "EnterDocumentNameView.h"
#import "NSString+URLEncoding.h"
#import "EventManager.h"
#import "UploadingProgressView.h"
#import "UIImage+Ext.h"
#import "UIImage+Resize.h"
#import "NetworkReachability.h"
#import "Utils.h"

#define kPdfPageWidth   612
#define kPdfPageHeight  792
#define kPdfMargin      40

#define kEnterDocumentNameViewWidth     (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 300.0 : 400.0)
#define kEnterDocumentNameViewHeight    (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 210.0 : 240.0)

@interface FinishUploadingViewController () <EnterDocumentNameViewDelegate, UploadingProgressViewDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSString *pdfLocalFilePath;
@property (nonatomic, strong) EnterDocumentNameView *enterDocumentNameView;
@property (nonatomic, strong) UIView *darkenOverlayView;
@property (nonatomic, strong) NSString *documentName;
@property (nonatomic, strong) UploadingProgressView *uploadingProgressView;
@end

@implementation FinishUploadingViewController

- (id)initWithTakenImages:(NSMutableArray*)takenImages {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        self.takenImages = takenImages;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleLabel.text = @"Preview";
    [self addTopRightBarButton:NSLocalizedString(@"ID_UPLOAD", @"") width:60 target:self selector:@selector(handleUploadButton)];
    
    self.loadingView = [[LoadingView alloc] init];
    
    self.darkenOverlayView = [[UIView alloc] initWithFrame:self.view.bounds];
    self.darkenOverlayView.backgroundColor = [UIColor blackColor];
    self.darkenOverlayView.alpha = 0.5f;
    [self.view addSubview:self.darkenOverlayView];
    self.darkenOverlayView.hidden = YES;
    
    self.enterDocumentNameView = [[EnterDocumentNameView alloc] initWithFrame:CGRectMake(self.view.frame.size.width/2-kEnterDocumentNameViewWidth/2, IS_IPHONE ? 120 : 160, kEnterDocumentNameViewWidth, kEnterDocumentNameViewHeight) superView:self.view delegate:self];
    self.enterDocumentNameView.hidden = YES;
    
    self.webView = [[UIWebView alloc] initWithFrame:self.contentView.bounds];
    self.webView.scalesPageToFit = YES;
    [self.contentView addSubview:self.webView];
    
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeDisplayPdf:threadObj:) argument:@""];
}

- (BOOL)shouldUseBackButton {
    return YES;
}

- (void)relayout {
    [super relayout];
    self.webView.frame = self.contentView.bounds;
    self.darkenOverlayView.frame = self.view.bounds;
    [self.enterDocumentNameView moveToHorizontalCenterOfSuperView];
    self.uploadingProgressView.center = self.enterDocumentNameView.center;
}

#pragma mark - EnterDocumentNameViewDelegate
- (void)enterDocumentNameView_DidCancel:(id)sender {
    self.topBarView.userInteractionEnabled = self.bottomBarView.userInteractionEnabled = self.contentView.userInteractionEnabled = YES;
    self.darkenOverlayView.hidden = YES;
    self.enterDocumentNameView.hidden = YES;
}

- (void)enterDocumentNameView:(id)sender doneWithName:(NSString *)aName {
    if (![[NetworkReachability getInstance] checkInternetActiveManually]) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_NO_INTERNET_CONNECTION2", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    self.documentName = aName;
    
    self.uploadingProgressView = [[UploadingProgressView alloc] initWithDocumentName:self.documentName pdfLocalFilePath:self.pdfLocalFilePath uploadingData:self.uploadingData superView:self.view delegate:self];
    self.uploadingProgressView.center = self.enterDocumentNameView.center;
    
    self.uploadingProgressView.alpha = 0;
    [UIView animateWithDuration:0.8 animations:^{
        self.enterDocumentNameView.alpha = 0.0;
        self.uploadingProgressView.alpha = 1.0;
    }];
    self.enterDocumentNameView.hidden = YES;
    self.enterDocumentNameView.alpha = 1.0;
    [self.uploadingProgressView startUploading];
}

#pragma mark - UploadingProgressViewDelegate
- (void)uploadingProgressView_Canceled:(id)sender {
    [self.uploadingProgressView removeFromSuperview];
    self.uploadingProgressView = nil;
    self.enterDocumentNameView.hidden = NO;
}

- (void)uploadingProgressView_GoToDocuments:(id)sender {
    [(FTMobileAppDelegate*)[UIApplication sharedApplication].delegate selectMenu:MenuItemRecent animated:YES];
}

- (void)uploadingProgressView_UploadAnother:(id)sender {
    [(FTMobileAppDelegate*)[UIApplication sharedApplication].delegate selectMenu:MenuItemUpload animated:YES];
}

#pragma mark - Button
- (void)handleUploadButton {
    self.topBarView.userInteractionEnabled = self.bottomBarView.userInteractionEnabled = self.contentView.userInteractionEnabled = NO;
    self.darkenOverlayView.frame = self.view.bounds;
    self.darkenOverlayView.hidden = NO;
    self.enterDocumentNameView.hidden = NO;
    
    [self.view bringSubviewToFront:self.darkenOverlayView];
    [self.view bringSubviewToFront:self.enterDocumentNameView];
    
    [self.enterDocumentNameView.nameTextField becomeFirstResponder];
}

#pragma mark - MyFunc
- (void)executeDisplayPdf:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if (![threadObj isCancelled]) {
        NSString *pdfLocalFilePath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"file_this_for_ios.pdf"];
        if ([[NSFileManager defaultManager] fileExistsAtPath:pdfLocalFilePath]) {
            NSError *error = nil;
            [[NSFileManager defaultManager] removeItemAtPath:pdfLocalFilePath error:&error];
        }
        
        // Create the PDF context using the default page size of 612 x 792.
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.loadingView startLoadingInView:self.view frame:self.contentView.frame message:@"Processing photos..."];
            UIGraphicsBeginPDFContextToFile(pdfLocalFilePath, CGRectZero, nil);
        });
        // Mark the beginning of a new page.
        
        for (UIImage *image in self.takenImages) {
//            CGSize size = image.size;
//            if (size.width > kUploadDocumentViewController_MaxImageWidth) {
//                size.height = kUploadDocumentViewController_MaxImageWidth / size.width * size.height;
//                size.width = kUploadDocumentViewController_MaxImageWidth;
//            }
//            if (size.height > kUploadDocumentViewController_MaxImageHeight) {
//                size.width = kUploadDocumentViewController_MaxImageHeight / size.height * size.width;
//                size.height = kUploadDocumentViewController_MaxImageHeight;
//            }
            
            UIImage *resizedImage = image; //[image resizedImage:size interpolationQuality:kCGInterpolationDefault];
            CGRect rect = CGRectMake(0, 0, resizedImage.size.width + 2 * kPdfMargin, resizedImage.size.height + 2 * kPdfMargin);
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                UIGraphicsBeginPDFPageWithInfo(rect, nil);
                [resizedImage drawInRect:CGRectInset(rect, kPdfMargin, kPdfMargin)];
            });
        }
        // Close the PDF context and write the contents out.
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            UIGraphicsEndPDFContext();
        });
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.loadingView stopLoading];
        });
        
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:pdfLocalFilePath]]];
        });
    }
    [threadObj releaseOperation];
}

@end
