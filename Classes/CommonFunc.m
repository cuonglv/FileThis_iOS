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
#import "NSString+Custom.h"
#import "FTSession.h"
#import "DocumentObject.h"
#import "DocumentCabinetObject.h"
#import "FTMobileAppDelegate.h"

@implementation CommonFunc

+ (Class)idiomClassWithName:(NSString*)className
{
    Class ret;
    NSString *specificName = nil;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        specificName = [[NSString alloc] initWithFormat:@"%@_ipad", className];
    }
    else
    {
        specificName = [[NSString alloc] initWithFormat:@"%@_iphone", className];
    }
    
    ret = NSClassFromString(specificName);
    if (!ret)
    {
        ret = NSClassFromString(className);
    }
    
    return ret;
}

+ (BOOL)isTallScreen //iPhone 5
{
    BOOL phone = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone);
    CGFloat height = [UIScreen mainScreen].bounds.size.height * [UIScreen mainScreen].scale;
    
    return ( phone && (height >= 1136) );
}

+ (NSObject*)findObjectWithValue:(id)value bykey:(NSString*)key fromArray:(NSArray*)array {
    for (NSObject *obj in array) {
        @try {
            NSObject *objectValue = [obj valueForKey:key];
            if ([objectValue isEqual:value])
                return obj;
        } @catch (NSException *e) {
        }
    }
    return nil;
}

#pragma mark Get Server Data
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
    return [self dateStringFromInt:dateInt format:@"MMM dd, yyyy hh:mma"];
}

+ (NSString*)dateStringShortFromInt:(int)dateInt {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MMM dd, yyyy"];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateInt]];
}

+ (NSString*)dateStringFromInt:(int)dateInt format:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:dateInt]];
}

+ (NSString*)dateStringFromInterval:(NSTimeInterval)interval format:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    return [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:interval]];
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
+ (NSString*)fullPathFromDocumentDirectory:(NSString*)filename
{
    NSArray *searchPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if (searchPaths.count == 0)
        return @"";
    NSString *documentPath = [searchPaths objectAtIndex:0];
    return  [documentPath stringByAppendingPathComponent:filename];
}

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

+ (NSString *)getSecretKey {
    NSString *serverName = [FTSession hostName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *latestLoginInfo = [defaults objectForKey:[NSString stringWithFormat:@"%@_latestlogininfo", serverName]];
    if (latestLoginInfo) {
        NSString *strKey = [NSString stringWithFormat:@"%@:%@", [latestLoginInfo objectForKey:@"username"], [latestLoginInfo objectForKey:@"password"]];
        return [strKey md5];
    }
    
    return nil;
}

+ (NSString *)getUsername {
    NSString *serverName = [FTSession hostName];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *latestLoginInfo = [defaults objectForKey:[NSString stringWithFormat:@"%@_latestlogininfo", serverName]];
    if (latestLoginInfo) {
        return [latestLoginInfo objectForKey:@"username"];
    }
    
    return nil;
}

// http://stackoverflow.com/questions/800123/best-practices-for-validating-email-address-in-objective-c-on-ios-2-0
+ (BOOL)validateEmail:(NSString*)email {
    NSString *lower = [email lowercaseString];
    NSString *emailRegex =
    @"(?:[a-z0-9!#$%\\&'*+/=?\\^_`{|}~-]+(?:\\.[a-z0-9!#$%\\&'*+/=?\\^_`{|}"
    @"~-]+)*|\"(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21\\x23-\\x5b\\x5d-\\"
    @"x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])*\")@(?:(?:[a-z0-9](?:[a-"
    @"z0-9-]*[a-z0-9])?\\.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?|\\[(?:(?:25[0-5"
    @"]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-"
    @"9][0-9]?|[a-z0-9-]*[a-z0-9]:(?:[\\x01-\\x08\\x0b\\x0c\\x0e-\\x1f\\x21"
    @"-\\x5a\\x53-\\x7f]|\\\\[\\x01-\\x09\\x0b\\x0c\\x0e-\\x7f])+)\\])";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    return [emailTest evaluateWithObject:lower];
}

+ (NSMutableArray*)emailsListFromString:(NSString*)emails {
    NSMutableArray *ret = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *components = [emails componentsSeparatedByString:@";"];
    for (NSString *s in components) {
        NSArray *subList = [s componentsSeparatedByString:@","];
        for (NSString *item in subList) {
            NSString *mail = [item stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            if ([self validateEmail:mail]) {
                [ret addObject:mail];
            }
        }
    }
    return ret;
}

+ (void)sortDocuments:(NSMutableArray *)documents sortBy:(SORTBY)sortBy {
    [documents sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DocumentObject *doc1 = obj1;
        DocumentObject *doc2 = obj2;
        if (sortBy == Name_A_Z) {
            NSString *docName1 = doc1.docname?doc1.docname:doc1.filename;
            NSString *docName2 = doc2.docname?doc2.docname:doc2.filename;
            return [[docName1 lowercaseString] compare:[docName2 lowercaseString]];
        } else if (sortBy == Name_Z_A) {
            NSString *docName1 = doc1.docname?doc1.docname:doc1.filename;
            NSString *docName2 = doc2.docname?doc2.docname:doc2.filename;
            return [[docName2 lowercaseString] compare:[docName1 lowercaseString]];
        } else if (sortBy == RelevantDate_NewestFirst) {
            return [doc2.relevantDate compare:doc1.relevantDate];
        } else if (sortBy == RelevantDate_OldestFirst) {
            return [doc1.relevantDate compare:doc2.relevantDate];
        } else if (sortBy == DateCreated_NewestFirst) {
            return [doc2.created compare:doc1.created];
        } else if (sortBy == DateCreated_OldestFirst) {
            return [doc1.created compare:doc2.created];
        } else if (sortBy == DateAdded_NewestFirst) {
            return [doc2.added compare:doc1.added];
        } else if (sortBy == DateAdded_OldestFirst) {
            return [doc1.added compare:doc2.added];
        }
        
        return NSOrderedSame;
    }];
}

+ (void)sortDocumentCabinets:(NSMutableArray *)documentCabinets {
    [documentCabinets sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DocumentCabinetObject *docCab1 = obj1;
        DocumentCabinetObject *docCab2 = obj2;
        NSString *cabName1 = [docCab1.cabinetObj.name lowercaseString];
        NSString *cabName2 = [docCab2.cabinetObj.name lowercaseString];
        
        if ([docCab1.cabinetObj.type compare:docCab2.cabinetObj.type] != NSOrderedSame)
        {
            if (docCab1.cabinetObj.groupOrder < docCab2.cabinetObj.groupOrder) {
                return NSOrderedAscending;
            }
            if (docCab1.cabinetObj.groupOrder > docCab2.cabinetObj.groupOrder) {
                return NSOrderedDescending;
            }
            
            return [docCab1.cabinetObj.type compare:docCab2.cabinetObj.type];
        }
        return [cabName1 compare:cabName2];
    }];
}

+ (void)sortDocumentProfiles:(NSMutableArray *)documentProfiles {
    [documentProfiles sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        DocumentProfileObject *docProf1 = obj1;
        DocumentProfileObject *docProf2 = obj2;
        NSString *name1 = [docProf1.profileObj.name lowercaseString];
        NSString *name2 = [docProf2.profileObj.name lowercaseString];
        return [name1 compare:name2];
    }];
}

+ (void)selectMenu:(MenuItem)menuItem animated:(BOOL)animated {
    [(FTMobileAppDelegate*)[UIApplication sharedApplication].delegate selectMenu:menuItem animated:animated];
}
@end
