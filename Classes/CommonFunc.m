//
//  CommonFunc.m
//  FTMobileApp
//
//  Created by decuoi on 11/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "CommonFunc.h"
#import "Constants.h"
#import "CommonVar.h"
#import "CheckNetworkStatus.h"
#import "Layout.h"

@implementation CommonFunc


#pragma mark Get Server Data
/*+ (NSString *)getServerData:(NSString *)link request:(NSString *)requestString {
    //create request
    NSURL *URL = [NSURL URLWithString:[NSString stringWithFormat:link, kServer]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy: NSURLCacheStorageNotAllowed timeoutInterval: 30];
    [request setHTTPMethod:@"POST"];
    //create the body
    NSMutableData *bodyData = [NSMutableData data];
    [bodyData appendData:[[NSString stringWithString:[NSString localizedStringWithFormat:@"%@", requestString]] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:bodyData];
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    NSString *theString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    return theString;
}*/

+ (UIImage *)serverGETImage:(NSString *)link {
    NSURL *URL = [NSURL URLWithString:link];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy: NSURLCacheStorageNotAllowed timeoutInterval: 30];
    [request setHTTPMethod:@"GET"];
    //create the body
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    return [UIImage imageWithData:data];
}

+ (NSString *)serverGET:(NSString *)link {
    NSURL *URL = [NSURL URLWithString:link];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL cachePolicy: NSURLCacheStorageNotAllowed timeoutInterval: 30];
    [request setHTTPMethod:@"GET"];
    //create the body
    NSURLResponse *response = nil;
    NSError *err = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    //NSLog(@"Response data length: %i", [data length]);
    if ([data length] == 0) {
        [Layout alertWarning:@"Server connection error" delegate:nil];
    }
    //NSLog(@"Response data: %@", [data description]);
    NSString *ret = [[NSString alloc] initWithData:data encoding:NSASCIIStringEncoding];
    return ret; //NSASCIIStringEncoding: very important
}

+ (BOOL)isTouchPointOutsideControl:(CGPoint)point forControl:(UIView *)view {
    return (point.x > view.frame.origin.x + view.frame.size.width) || (point.x < view.frame.origin.x) || (point.y > view.frame.origin.y + view.frame.size.height) || (point.y < view.frame.origin.y);
}

#pragma mark -
#pragma mark JSON

+ (id)jsonDictionaryFromString:(NSString *)content
{
    NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id dictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    NSAssert2(error == nil, @"error=%@ parsing JSON string %@", error, content);
    return dictionary;
}

+ (id)jsonObjGET:(NSString *)link
{
	NSString *jsonString = [self serverGET:link];
    return [self jsonDictionaryFromString:jsonString];
}

+ (NSDictionary *) jsonDictionaryGET:(NSString *)link 
{
    return [self jsonObjGET:link];
}

+ (NSString*)dateStringFromInt:(int)dateInt {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy hh:mma"];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateInt]];
}

+ (NSString*)dateStringShortFromInt:(int)dateInt {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateInt]];
}

#pragma mark -
#pragma mark URL Editing
/*+ (NSString *)createRequest:(NSString *)op params:(NSArray *)params {
    
}*/

#pragma mark Alert
+ (void)alert:(NSString*)mesg {
    UIAlertView *av = [[UIAlertView alloc] initWithTitle:@"FT Mobile" message:mesg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [av show];
}


#pragma mark Cabinet
+ (UIColor *)getCabColorByType:(NSString *)cabType {
    if ([cabType isEqualToString:kCabTypeAll])
        return kCabColorAll;
    else if ([cabType isEqualToString:kCabTypeVital])
        return kCabColorVital;
    else if ([cabType isEqualToString:kCabTypeBasic])
        return kCabColorBasic;
    else
        return kCabColorComputed;
}

+ (UIImage *)getCabBackgroundImageByType:(NSString *)cabType {
    if ([cabType isEqualToString:kCabTypeAll])
        return kImgCabAll;
    else if ([cabType isEqualToString:kCabTypeVital])
        return kImgCabVital;
    else if ([cabType isEqualToString:kCabTypeBasic])
        return kImgCabBasic;
    else
        return kImgCabComputed;
}

#pragma mark -
#pragma mark Read & Write File
+ (NSString *)readFile:(NSString *)path {
    NSString *ret = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
	if ([fileManager fileExistsAtPath:path]) {
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
		NSData *data = [fileHandle readDataToEndOfFile];
		ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return ret;
}

+ (NSString *)readFileInDocumentDir:(NSString *)filename {
    NSString *ret = nil;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths[0] stringByAppendingPathComponent:filename];
	if ([fileManager fileExistsAtPath:path]) {
		NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:path];
		NSData *data = [fileHandle readDataToEndOfFile];
		ret = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return ret;
}

+ (void)writeFileInDocumentDir:(NSString *)filename content:(NSString *)content {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths[0] stringByAppendingPathComponent:filename];
	NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
	if ([fileManager fileExistsAtPath:path])
		[fileManager createFileAtPath:path contents:data attributes:nil];
	else
		[data writeToFile:path atomically:YES];
}


+ (NSString *)getFilePathInDocumentDir:(NSString *)filename {
    //NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [paths[0] stringByAppendingPathComponent:filename];
    return path;
}


+ (NSString*)getFileSizeString:(unsigned long long)fileSize {
    double dFileSize = (double)fileSize;
    if (dFileSize < 1024) {
        return [NSString stringWithFormat:@"%.1f B", dFileSize];
    } else if (dFileSize < 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f KB", dFileSize/1024];
    } else if (dFileSize < 1024 * 1024 * 1024) {
        return [NSString stringWithFormat:@"%.1f MB", dFileSize/(1024 * 1024)];
    } else {
        return [NSString stringWithFormat:@"%.1f GB", dFileSize/(1024 * 1024 * 1024)];
    }
}

#pragma mark check network status
+ (BOOL)isNetworkAvailable {
	BOOL ret;
	CheckNetworkStatus *engine = [[CheckNetworkStatus alloc] init];
	ret = [engine connectedToNetwork];
	
    //Nam code: nothing    
    //Cuong code:
    if (ret) {
        //[engine release];
        //return YES;
    }
    //End Cuong code
    
    while (!engine.done) {
        [NSThread sleepForTimeInterval:.25];
	}
    ret = engine.isNetworkAvailable;
    
	return ret;
}
@end
