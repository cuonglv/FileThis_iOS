//
//  MyLog.m
//  FileThis
//
//  Created by Cuong Le on 2/21/14.
//
//

#import "MyLog.h"

#define kMyLog_Boundary     @"**************************************************"

@implementation MyLog

+ (void)writeLogWithService:(BaseService*)service responseData:(NSData*)responseData {
#ifdef LOG_ENABLE
    @autoreleasepool {
        NSMutableString *newLog = [[NSMutableString alloc] init];
        [newLog appendFormat:@"\n\n%@",kMyLog_Boundary];
        [newLog appendFormat:@"\n%@",[DateHandler displayedStringFromDateTime:[DateHandler dateTimeComponentsFromDate:service.lastRequestDateTime]]];
        [newLog appendFormat:@"\nRequest URL: %@",service.lastRequestURL];
        if ([service.lastRequestBody length] > 0)
            [newLog appendFormat:@"\nRequest body: %@",service.lastRequestBody];
        
        [newLog appendFormat:@"\n\nResponse Status: %i",service.responseStatusCode];
        [newLog appendFormat:@"\n%@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]];
        [MyLog writeLogWithText:newLog];
    }
#endif
}

+ (void)writeLogWithText:(NSString*)text {
#ifdef LOG_ENABLE
    @autoreleasepool {
        NSMutableString *logString = [MyLog getAdjustedOldLogString];
        [logString appendString:text];
        [logString writeToFile:LOG_CACHE_PATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
    }
#endif
}

+ (NSMutableString*)getAdjustedOldLogString {
    NSMutableString *logString = [NSMutableString stringWithContentsOfFile:LOG_CACHE_PATH encoding:NSUTF8StringEncoding error:nil];
    if (logString) {
        long len = [logString length];
        while (len > kMyLog_MaxLength) {
            long index = [logString rangeOfString:kMyLog_Boundary].location;
            if (index == NSNotFound) {
                index = len - kMyLog_MaxLength;
            } else {
                index += [kMyLog_Boundary length];
                index = [logString rangeOfString:kMyLog_Boundary options:NSCaseInsensitiveSearch range:NSMakeRange(index,len-index)].location;
                if (index == NSNotFound)
                    index = len - kMyLog_MaxLength;
            }
            [logString deleteCharactersInRange:NSMakeRange(0, index)];
            len = [logString length];
        }
    } else
        logString = [[NSMutableString alloc] init];
    
    return logString;
}

+ (NSString*)getLog {
    return [NSString stringWithContentsOfFile:LOG_CACHE_PATH encoding:NSUTF8StringEncoding error:nil];
}

+ (void)clearLog {
    [@"" writeToFile:LOG_CACHE_PATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

@end
