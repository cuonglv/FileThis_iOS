//
//  DataDownloader.h
//  FileThis
//
//  Created by Loc Huu Cao on 5/16/14.
//
//

#import <Foundation/Foundation.h>

@interface DataDownloader : NSObject <NSURLConnectionDelegate>
{
    NSString *urlDownload;
    NSMutableData *tempData;
    NSURLConnection *connectionDownload;
    BOOL downloading;
    BOOL success;
}

@property (nonatomic, copy) NSString *urlDownload;
@property (nonatomic, readonly, getter = getDataDownloaded) NSData *dataDownloaded;
@property (nonatomic, retain) NSURLConnection *connectionDownload;
@property (nonatomic, readonly, assign) BOOL downloading;
@property (nonatomic, readonly, assign) BOOL success;

- (id)initWithUrlString:(NSString*)urlString;
- (void)startDownload;
- (void)cancelDownload;

@end
