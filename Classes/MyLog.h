//
//  MyLog.h
//  FileThis
//
//  Created by Cuong Le on 2/21/14.
//
//

#import <Foundation/Foundation.h>
#import "DateHandler.h"
#import "BaseService.h"

#define LOG_ENABLE   0
#define LIBRARYCACHE_PATH   [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0]
#define LOG_CACHE_PATH      [LIBRARYCACHE_PATH stringByAppendingPathComponent:@"Log.txt"]

#define kMyLog_MaxLength   10000000

#define kMyLogText_AppDidBecomeActive               @"Application did become active"
#define kMyLogText_AppWillResignActive              @"Application will resign active"
//#define kMyLogText_AppDidEnterBackground            @"Application did enter background"

@interface MyLog : NSObject

+ (void)writeLogWithService:(BaseService*)service responseData:(NSData*)responseData;
+ (void)writeLogWithText:(NSString*)text;
+ (NSString*)getLog;
+ (void)clearLog;

@end
