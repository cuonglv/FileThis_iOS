//
//  DownloadPhotoThread.h
//  FileThis
//
//  Created by Loc Huu Cao on 5/16/14.
//
//

#import <Foundation/Foundation.h>
#import "DataDownloader.h"

@class DownloadPhotoThread;

@interface DownloadPhotoThread : NSThread
@property (nonatomic, retain) DataDownloader *datadownload;

- (void)cancelDownload;

@end
