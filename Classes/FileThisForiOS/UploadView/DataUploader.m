//
//  DataUploader.m
//  OnMat
//
//  Created by Cuong Le Viet on 8/22/13.
//
//

#import "DataUploader.h"

@implementation DataUploader

- (id)initWithURL:(NSString*)url fileName:(NSString*)fileName data:(NSData*)data dataParamName:(NSString*)dataParamName dataContentType:(NSString*)dataContentType otherParamNames:(NSArray*)otherParamNames otherParamValues:(NSArray*)otherParamValues delegate:(id<DataUploaderDelegate>)delegate {
    if (self = [super init]) {
        self.uploadingURL = url;
        self.fileName = fileName;
        self.dataParamName = dataParamName;
        self.dataContentType = dataContentType;
        self.uploadingData = data;
        self.otherParamNames = otherParamNames;
        self.otherParamValues = otherParamValues;
        dataUploaderDelegate = delegate;
    }
    return self;
}

- (void)dealloc {
    [_uploadingURL release];
    [_fileName release];
    [_dataParamName release];
    [_dataContentType release];
    [_uploadingData release];
    [_otherParamNames release];
    [_otherParamValues release];
    [super dealloc];
}

static long fileSize = 1;

#pragma mark - URLConnectionDelegate
- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
    //NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
    //NSLog(@"---connection didReceiveResponse: statusCode = %i %@", httpResponse.statusCode, [httpResponse allHeaderFields]);
}

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
//    int percentage = totalBytesWritten * 100 / fileSize;
//    if (percentage > 100)
//        percentage = 100;
    
    //NSLog(@"---Uploading data: %i", totalBytesWritten);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    [dataUploaderDelegate dataUploaderFinishedUploading:self];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    //NSLog(@"---connection didReceiveResponse: %@", [error description]);
    [dataUploaderDelegate dataUploaderFailToUpload:self];
}

#pragma mark - MyFunc
- (NSData*)upload {
    NSString *urlString;
    
    switch ([DataPlistManager server]) {
        case 1:
            urlString = [kDevelopmentServerURL stringByAppendingPathComponent:self.uploadingURL];
            break;
        case 2:
            urlString = [[DataPlistManager stagingServer1URL] stringByAppendingPathComponent:self.uploadingURL];
            break;
        default:
            urlString = [kProductServerURL stringByAppendingPathComponent:self.uploadingURL];
            break;
    }
    
    fileSize = (long)[self.uploadingData length];
    
    //NSLog(@"--- Upload data length: %ld %@", (long)[self.uploadingData length],urlString);
    
    //NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:NSURLCacheStorageNotAllowed timeoutInterval:120];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:urlString] cachePolicy:0 timeoutInterval:120];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundary = @"---------------------------14990919979610469751091999738";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary] forHTTPHeaderField:@"Content-Type"];
    
    NSMutableData *postData = [NSMutableData dataWithCapacity:[self.uploadingData length]+512];
    for (int i = 0, count = [self.otherParamNames count]; i < count; i++) {
        [postData appendData:[[NSString stringWithFormat:@"--%@\r\nContent-Disposition: form-data; name=\"%@\"\r\n\r\n\r\n%@\r\n",boundary,[self.otherParamNames objectAtIndex:i],[self.otherParamValues objectAtIndex:i]] dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@\r\nContent-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\nContent-Type: %@\r\n\r\n", boundary, self.dataParamName, self.fileName, self.dataContentType] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [postData appendData:self.uploadingData];
    
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:postData];
    
    // create the connection with the request and start loading the data
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    if (err) {
        return nil;
    } else {
        return data;
    }
}
@end
