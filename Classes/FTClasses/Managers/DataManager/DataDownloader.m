//
//  DataDownloader.m
//  FileThis
//
//  Created by Loc Huu Cao on 5/16/14.
//
//

#import "DataDownloader.h"

@implementation DataDownloader

@synthesize
  urlDownload
, connectionDownload
, downloading
, success
;

#pragma mark - Initialize and Finalize
- (id)init
{
    return [self initWithUrlString:nil];
}

- (id)initWithUrlString:(NSString*)urlString
{
    if ((self = [super init]))
    {
        self.urlDownload = urlString;
        
        downloading = NO;
        success = NO;
        
        tempData = [[NSMutableData alloc] initWithCapacity:1000];
    }
    return self;
}

#pragma mark - Methods
- (NSData*)getDataDownloaded
{
    return tempData;
}

- (void)startDownload
{
    if (downloading)
    {
        return;
    }
    
    [tempData setLength:0];
    downloading = YES;
    success = NO;
    
    NSURL *url = [[NSURL alloc] initWithString:urlDownload];
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:15];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:request delegate:self];
    self.connectionDownload = conn;
}

- (void)cancelDownload
{
    if (!downloading)
    {
        return;
    }
    
    [connectionDownload cancel];
    
    downloading = NO;
    success = NO;
}

#pragma mark - NSURLConnectionDelegate
- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse
{
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    [tempData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite
{
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [tempData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    downloading = NO;
    success = YES;
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    downloading = NO;
    success = NO;
}

- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

@end
