//
//  DownloadPhotoThread.m
//  FileThis
//
//  Created by Loc Huu Cao on 5/16/14.
//
//

#import "DownloadPhotoThread.h"
#import "CacheManager.h"
#import "DocumentDataManager.h"
#import "DocumentService.h"

#define NUM_OF_IMAGE_TO_NOTIFY  2

@implementation DownloadPhotoThread

#pragma mark - Initialize and Finalize
- (id)init
{
    if ((self = [super init])) {
    }
    return self;
}

#pragma mark - Methods
- (void)cancelDownload
{
    [self cancel];
    [self.datadownload cancelDownload];
}

#pragma mark - MAIN function
- (void)main
{
    @autoreleasepool {
        int count = 0;
        DocumentObject *doc = [[DocumentDataManager getInstance] popDocumentToDownloadThumbnail];
        while (doc) {
            @autoreleasepool { //Inner pool for each downloaded data
                //Execute download image
                UIImage *downloadImage = nil;
                DocumentService *service = [[DocumentService alloc] initWithAction:kActionGetDocumentThumbnail isDictionaryResponse:NO];
                service.docObj = doc;
                service.documentThumbSize = ThumbnailSizeMedium;
                id data = [service sendRequestToServer];
                if (data)
                    downloadImage = [UIImage imageWithData:data];
                
                if (downloadImage) {
                    count++;
                    doc.docThumbImage = downloadImage;
                    [[CacheManager getInstance] setDocumentThumbnailCache:doc size:ThumbnailSizeMedium];
                    
                    if (count >= NUM_OF_IMAGE_TO_NOTIFY) {
                        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDownloadThumb object:nil];
                        count = 0;
                    }
                }
            }
            
            if (self.isCancelled)
                break;
            
            //Next loop to download thumbnail
            doc = [[DocumentDataManager getInstance] popDocumentToDownloadThumbnail];
        }
        
        //Trigger "finish list" notifycation
        [[NSNotificationCenter defaultCenter] postNotificationName:NotificationDownloadThumb object:nil];
    }
}

@end
