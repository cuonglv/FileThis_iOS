//
//  UploadingProgressView.m
//  FileThis
//
//  Created by Cuong Le on 1/16/14.
//
//

#import "UploadingProgressView.h"
#import "NSString+URLEncoding.h"
#import "CommonLayout.h"
#import "CommonVar.h"
#import "ThreadManager.h"
#import "EventManager.h"
#import "CommonDataManager.h"
#import "CacheManager.h"

@interface UploadingProgressView() <NSURLConnectionDelegate>

@property (nonatomic, strong) NSString *pdfLocalFilePath;
@property (nonatomic, strong) NSString *documentName;
@property (nonatomic, strong) NSData *uploadingData;
@property (nonatomic, strong) UIButton *cancelButton, *retryButton, *uploadAnotherButton, *goToDocumentButton;
@property (nonatomic, assign) id<UploadingProgressViewDelegate> delegate;

@property (nonatomic, strong) NSURLConnection *myConnection;

@property (assign) long fileSize;
@property (strong) NSString *fileSizeString;
@property (assign) double progressValue;

@end

@implementation UploadingProgressView

- (id)initWithDocumentName:(NSString*)documentName pdfLocalFilePath:(NSString*)pdfLocalFilePath uploadingData:(NSData*)uploadingData superView:(UIView*)superView delegate:(id<UploadingProgressViewDelegate>)delegate {
    if (self = [super initWithFrame:CGRectMake(0, 0, IS_IPHONE ? 300 : 350, 180)]) {
        self.documentName = documentName;
        self.pdfLocalFilePath = pdfLocalFilePath;
        self.uploadingData = uploadingData;
        self.delegate = delegate;
        
        self.backgroundColor = [UIColor whiteColor];
        self.layer.cornerRadius = 6;
        self.clipsToBounds = YES;
        
        self.progressView = [[MyProgressView alloc] initWithFrame:CGRectMake(20, 40, self.frame.size.width-40, 80) font:[CommonLayout getFont:(IS_IPHONE ? FontSizeSmall : FontSizeMedium) isBold:NO isItalic:YES] textColor:kTextGrayColor tintColor:kTextOrangeColor trackTintColor:kBorderLightGrayColor progressBarWidth:self.frame.size.width-40 superView:self];
        self.progressView.progressLabel.numberOfLines = 2;
        
        self.cancelButton = [CommonLayout createTextButton:CGRectMake(self.frame.size.width/2-40, self.frame.size.height - 60, 80, 35) fontSize:FontSizeMedium isBold:NO text:NSLocalizedString(@"ID_CANCEL", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleCancelButton) superView:self];
        self.retryButton = [CommonLayout createTextButton:self.cancelButton.frame fontSize:FontSizeMedium isBold:YES text:NSLocalizedString(@"ID_RETRY", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleRetryButton) superView:self];
        self.retryButton.hidden = YES;
        
        self.uploadAnotherButton = [CommonLayout createTextButton:CGRectMake(0, self.frame.size.height-45, self.frame.size.width/2, 45) fontSize:FontSizeMedium isBold:NO text:NSLocalizedString(@"ID_UPLOAD_ANOTHER", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleUploadAnotherButton) superView:self];
        self.uploadAnotherButton.hidden = YES;
        
        self.goToDocumentButton = [CommonLayout createTextButton:[self.uploadAnotherButton rectAtRight:-1 width:self.uploadAnotherButton.frame.size.width+1] fontSize:FontSizeMedium isBold:YES text:NSLocalizedString(@"ID_GO_TO_RECENT", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleGoToDocumentsButton) superView:self];
        self.goToDocumentButton.hidden = YES;
        
        self.layer.borderColor = self.cancelButton.layer.borderColor = self.retryButton.layer.borderColor =  self.uploadAnotherButton.layer.borderColor = self.goToDocumentButton.layer.borderColor = kBorderLightGrayColor.CGColor;
        self.layer.borderWidth = self.cancelButton.layer.borderWidth = self.retryButton.layer.borderWidth = self.uploadAnotherButton.layer.borderWidth = self.goToDocumentButton.layer.borderWidth = 1.0;
        self.cancelButton.layer.cornerRadius = self.retryButton.layer.cornerRadius = 3;
        
        [superView addSubview:self];
        [self moveToCenterOfSuperView];
    }
    return self;
}

#pragma mark - URLConnectionDelegate
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
//    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
//    NSLog(@"---connection didReceiveResponse: statusCode = %i %@\n%@", httpResponse.statusCode, [httpResponse allHeaderFields], [response description]);
    NSLog(@"---connection didReceiveResponse: statusCode = %@", [response description]);
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {

    self.progressValue = (double)totalBytesWritten / (double)self.fileSize;
    
    NSLog(@"---Uploading data: %i of %ld", totalBytesWritten, self.fileSize);
    NSString *text;
    if (self.progressValue >= 0.995)
        text = [NSString stringWithFormat:@"Uploaded 100%% of %@.\nProcessing document... Please wait.",self.fileSizeString];
    else
        text = [NSString stringWithFormat:@"Uploading... %.0f%% of %@",roundf(self.progressValue*100),self.fileSizeString];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.progressView setProgressValue:self.progressValue text:text];
    });
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Post event upload new documents
    NSLog(@"---Uploading connectionDidFinishLoading:");
    self.myConnection = nil;
    
    // [manhnn] We just need to reload all documents on all cabinets in case Common Data is not available. Otherwise, we just reload documents on Recently Added Cabinet
    if (![[CommonDataManager getInstance] isCommonDataAvailableWithKey:DATA_COMMON_KEY]) {
        [CommonVar setNeedToReloadAllDocuments:YES];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.progressView setProgressValue:self.progressValue text:[NSString stringWithFormat:@"Upload finished"]];
        self.progressView.progressLabel.font = [CommonLayout getFont:FontSizeMedium isBold:YES isItalic:YES];
        self.cancelButton.hidden = YES;
        self.uploadAnotherButton.hidden = self.goToDocumentButton.hidden = NO;
        [self.retryButton setHidden:YES];
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    });
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog(@"---connection didReceiveResponse: %@", [error description]);
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //NSString *text = [NSString stringWithFormat:@"Uploaded %.0f%% of %@. Fail to upload!",roundf(self.progressValue*100),self.fileSizeString];
        NSString *text = @"Fail to upload!";
        
        [self.progressView setProgressValue:self.progressValue text:text];
        self.cancelButton.hidden = NO;
        self.retryButton.hidden = YES;
        [self.uploadAnotherButton setHidden:YES];
        [self.goToDocumentButton setHidden:YES];
        
        //[CommonLayout showAlertMessageWithTitle:@"Error" content:[error localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitle:nil];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    });
}


#pragma mark - Button
- (void)handleCancelButton {
    [self.myConnection cancel];
    [self.delegate uploadingProgressView_Canceled:self];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

- (void)handleRetryButton {
    self.myConnection = nil;
    [self startUploading];
}

- (void)handleUploadAnotherButton {
    [self.delegate uploadingProgressView_UploadAnother:self];
}

- (void)handleGoToDocumentsButton {
    [self.delegate uploadingProgressView_GoToDocuments:self];
}

#pragma mark - MyFunc
- (NSString *)getServerUrl {
    NSString *serverUrl = [[CacheManager getInstance] getServerUrl];
    if (serverUrl != nil && [serverUrl length] > 0) return serverUrl;
    
    return kServer;
}

- (void)startUploading {
    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    
    NSString *urlString = [[self getServerUrl] stringByAppendingFormat:@"compact=true&json=true&op=upload&ticket=%@&filename=%@.pdf&path=./file_this_for_ios.pdf",[CommonVar ticket],[self.documentName urlEncode]];
    
    self.uploadingData = [[NSData alloc] initWithContentsOfFile:[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory,NSUserDomainMask,YES) objectAtIndex:0] stringByAppendingPathComponent:@"file_this_for_ios.pdf"]];
    
    self.fileSize = (long)[self.uploadingData length];
    
    NSString *docBytesString;
    double size = (double)self.fileSize / 1024;
    if (size < 1024) {
        docBytesString = [NSString stringWithFormat:@"%.1f KB", size];
    } else {
        size /= 1024;
        if (size < 1024) {
            docBytesString = [NSString stringWithFormat:@"%.1f MB", size];
        } else {
            docBytesString = [NSString stringWithFormat:@"%.1f GB", size/1024];
        }
    }
    self.fileSizeString = docBytesString;
    
    NSLog(@"--- Upload data length: %ld %@", (long)[self.uploadingData length],urlString);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14990919979610469751091999738";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postData = [NSMutableData dataWithCapacity:[self.uploadingData length]+512];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"file\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", boundary, @"file_this_for_ios.pdf", @"application/pdf"] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:self.uploadingData];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postData];
    
    self.myConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    [self.myConnection start];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.progressView setProgressValue:0 text:@"Upload started..."];
    });
}
@end
