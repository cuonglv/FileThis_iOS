//
//  CommonVar.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "CommonVar.h"
#import "CommonFunc.h"
#import "KKPasscodeLock.h"

static NSString *sRequestURL = @"";
static NSUserDefaults *userDefaults;
static int iDocPageSize = 10;
static int iDocThumbSmallWidth = 50;
static int iDocThumbSmallHeight = 65;
static int iCacheThumbSmallCount = 30;
static int iCacheThumbMediumCount = 30;
static unsigned long long lDocCacheSize = 30 * 1024 * 1024;
static NSMutableArray *arrTagsChecked_ = nil, *arrTagsUnchecked_ = nil;

static NSMutableArray *arrThumbFilesSmall_ = nil, *arrThumbFilesMedium_ = nil, *arrDocFiles_ = nil;
static BOOL blnVarLoaded = NO;

/*
static int iCabId = kCabIdAll;
static NSString *sSortBy = @"name";
static BOOL blnSortDescending = NO;
static CabinetType cabType_ = CabinetTypeAll;
*/

@implementation CommonVar

+ (void)loadVar {
    @autoreleasepool { //call by detach new thread
    
        arrTagsChecked_ = [[NSMutableArray alloc] init];
        arrTagsUnchecked_ = [[NSMutableArray alloc] init];
        
        NSDictionary *defaults = [[NSDictionary alloc] initWithContentsOfFile:kPathSettings];
        if (userDefaults == nil)
            userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults registerDefaults:defaults];

        NSString *path = kPathDocThumb;
        NSError *error;
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:path]) {
            //NSLog(@"Create dir: %@",path);
            [fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:&error];
        }
        
        NSString *sFile = [kPathDocThumb stringByAppendingPathComponent:@"Small.json"];
        if ([fileManager fileExistsAtPath:sFile]) {
            arrThumbFilesSmall_ = [[NSMutableArray alloc] initWithContentsOfFile:sFile];
        } else {
            arrThumbFilesSmall_ = [[NSMutableArray alloc] init];
        }

        //NSLog(@"ComVar - loadVar - arrThumbSmall: %@", [arrThumbFilesSmall_ description]);
            
        sFile = [kPathDocThumb stringByAppendingPathComponent:@"Medium.json"];
        if ([fileManager fileExistsAtPath:sFile]) {
            arrThumbFilesMedium_ = [[NSMutableArray alloc] initWithContentsOfFile:sFile];
        } else {
            arrThumbFilesMedium_ = [[NSMutableArray alloc] init];
        }

        //NSLog(@"ComVar - loadVar - arrThumbMedium: %@", [arrThumbFilesMedium_ description]);
        
        sFile = [kPathDocThumb stringByAppendingPathComponent:@"DocFile.json"];
        if ([fileManager fileExistsAtPath:sFile]) {
            arrDocFiles_ = [[NSMutableArray alloc] initWithContentsOfFile:sFile];
        } else {
            arrDocFiles_ = [[NSMutableArray alloc] init];
        }

        //NSLog(@"ComVar - loadVar - arrDocFile: %@", [arrDocFiles_ description]);
        
        [CommonVar loadAtomicVar];
        blnVarLoaded = YES;
    
    }
}

+ (BOOL)varLoaded {
    return blnVarLoaded;
}

+ (void)loadAtomicVar {
    if (userDefaults == nil)
        userDefaults = [NSUserDefaults standardUserDefaults];
    iDocPageSize = [userDefaults integerForKey:@"DocPageSize"];
    iDocThumbSmallWidth = [userDefaults floatForKey:@"DocThumbSmallWidth"];
    iDocThumbSmallHeight = [userDefaults floatForKey:@"DocThumbSmallHeight"];
    iCacheThumbSmallCount = [userDefaults integerForKey:@"CacheThumbSmallCount"];
    iCacheThumbMediumCount = [userDefaults integerForKey:@"CacheThumbMediumCount"];
    lDocCacheSize = [userDefaults integerForKey:@"DocCacheSize"] * 1024 * 1024;
}

#pragma mark -
+ (NSString*)ticket {
    return [userDefaults objectForKey:@"Ticket"];
}

+ (void)setTicket:(NSString*)value {
    [userDefaults setObject:value forKey:@"Ticket"];
    [userDefaults synchronize];
}

#pragma mark -
+ (NSString*)requestURL {
    return sRequestURL;
}

+ (void)setRequestURL:(NSString*)value {
    if (sRequestURL != value) {
        sRequestURL = value;
    }
}


#pragma mark -
+ (NSUserDefaults *)dictPlist {
    return userDefaults;
}

+ (void)savePlist {
    [userDefaults synchronize];
}

#pragma mark -
#pragma mark Info Settings
+ (int)docPageSize {
    return iDocPageSize;
}

+ (int)docThumbSmallWidth {
    return iDocThumbSmallWidth;
}

+ (int)docThumbSmallHeight {
    return iDocThumbSmallHeight;
}

+ (int)cacheThumbSmallCount {
    return iCacheThumbSmallCount;
}

#pragma mark -
#pragma mark All Cab List
static NSArray *arrAllCabs_;
static NSMutableDictionary *mdictAllCabs_;
+ (NSArray*)arrAllCabs {
    return arrAllCabs_;
}
+ (NSMutableDictionary*)mdictAllCabs {
    return mdictAllCabs_;
}
+ (void)loadAllCabs {
    NSString *req = [[CommonVar requestURL] stringByAppendingString:@"cablist"];
    NSDictionary *dictCabinet = [CommonFunc jsonDictionaryGET:req];
    dictCabinet = [dictCabinet allValues][0];    //go into "account" object
    arrAllCabs_ = dictCabinet[@"cabs"];
    
    mdictAllCabs_ = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dict in arrAllCabs_) {
        mdictAllCabs_[[dict valueForKey:@"id"]] = dict;
    }
}
+ (NSDictionary*)getCab:(int)cabId {
    return mdictAllCabs_[@(cabId)];
}
/*
+ (NSString*)getCabName:(int)cabId {
    NSDictionary *dict = [mdictAllCabs_ objectForKey:[NSNumber numberWithInt:cabId]];
    return [dict valueForKey:@"name"];
}*/

#pragma mark -
#pragma mark All Tag List
static NSMutableDictionary *mdictAllTags_;
+ (NSMutableDictionary*)mdictAllTags {
    return mdictAllTags_;
}
+ (void)loadAllTags {
    NSString *req = [[CommonVar requestURL] stringByAppendingString:@"taglist"];
    NSDictionary *dict = [CommonFunc jsonDictionaryGET:req];
    dict = [dict allValues][0];  //go into "account" object
    NSArray *arrAllTags = dict[@"tags"];
    mdictAllTags_ = [[NSMutableDictionary alloc] init];
    for (NSDictionary *dictTemp in arrAllTags) {
        mdictAllTags_[[dictTemp valueForKey:@"id"]] = dictTemp;
    }    
}
/*+ (NSDictionary*)getTag:(int)tagId {
    return [mdictAllTags_ objectForKey:[NSNumber numberWithInt:tagId]];
}*/
+ (NSString*)getTagName:(int)tagId {
    NSDictionary *dict = mdictAllTags_[@(tagId)];
    return [dict valueForKey:@"name"];
}
+ (NSString*)getTagNames:(NSArray*)tagIds {
    if (!tagIds)
        return @"";
    if ([tagIds count] == 0)
        return @"";
    
    NSString *ret = [self getTagName:[tagIds[0] intValue]];
    for (int i=1,count=[tagIds count]; i<count; i++) {
        ret = [ret stringByAppendingFormat:@", %@", [self getTagName:[tagIds[i] intValue]]];
    }
    return ret;
}

#pragma mark -
#pragma mark Thumb Files
+ (NSMutableArray*)arrThumbFilesSmall {
    return arrThumbFilesSmall_;
}
+ (NSMutableArray*)arrThumbFilesMedium {
    return arrThumbFilesMedium_;
}
+ (NSMutableArray*)arrCachedDocs {
    return arrDocFiles_;
}
/*
 + (void)sortArrTagChecked {
 for (int i=0,count=[arrTagsChecked_ count]; i<count; i++) {
 NSMutableDictionary *mdictTop = [arrTagsChecked_ objectAtIndex:i];
 NSString *sTopName = [mdictTop valueForKey:@"name"];
 BOOL blnTopChecked = [[mdictTop valueForKey:@"checked"] boolValue];
 for (int j=i; j<count; j++) {
 NSMutableDictionary *mdictCurrent = [arrTagsChecked_ objectAtIndex:j];
 NSString *sCurrentName = [mdictCurrent valueForKey:@"name"];
 BOOL blnCurrentChecked = [[mdictCurrent valueForKey:@"checked"] boolValue];
 if (!blnTopChecked && blnCurrentChecked) {
 //swap
 NSMutableDictionary *mdictTemp = [mdictTop retain];
 [arrTagsChecked_ replaceObjectAtIndex:i withObject:mdictCurrent];
 [arrTagsChecked_ replaceObjectAtIndex:j withObject:mdictTemp];
 } else if ([sTopName compare:sCurrentName] == NSOrderedDescending) {
 //swap
 NSMutableDictionary *mdictTemp = [mdictTop retain];
 [arrTagsChecked_ replaceObjectAtIndex:i withObject:mdictCurrent];
 [arrTagsChecked_ replaceObjectAtIndex:j withObject:mdictTemp];
 }
 }
 }
 }*/


/*
 static NSMutableArray *arrTagChecks_;
 + (NSMutableArray*)arrTagChecks {
 return [arrTagChecks_ retain];
 }
 + (void)setArrTagChecks:(NSMutableArray*)value {
 if (arrTagChecks_ != value) {
 [arrTagChecks_ release];
 arrTagChecks_ = [value retain];
 }
 }*/

/*
 #pragma mark -
 + (int)cabId {
 return iCabId;
 }
 
 + (void)setCabId:(int)value {
 iCabId = value;
 }
 
 #pragma mark -
 + (NSString*)sortBy {
 return [sSortBy retain];
 }
 
 + (void)setSortBy:(NSString*)value {
 if (sSortBy != value) {
 [sSortBy release];
 sSortBy = [value retain];
 }
 }
 
 #pragma mark -
 + (BOOL)sortDescending {
 return blnSortDescending;
 }
 
 + (void)setSortDescending:(BOOL)value {
 blnSortDescending = value;
 }
 
 #pragma mark -
 + (CabinetType)cabType {
 return cabType_;
 }
 
 + (void)setCabType:(CabinetType)value {
 cabType_ = value;
 }
 */


#pragma mark -
#pragma mark Save & Read Images
+ (BOOL)saveThumb:(UIImage*)img docId:(int)docId size:(ThumbnailSize)thumbSize modifiedDate:(int)modifiedDate {
    NSString *sNewFileName = [NSString stringWithFormat:@"%i.jpg", modifiedDate];
    NSString *sThumbDirPath, *sDirPath, *sSize;
    NSMutableArray *arrThumbs;
    int iCacheThumbCount;
    switch (thumbSize) {
        case ThumbnailSizeSmall:
            sSize = @"Small";
            arrThumbs = arrThumbFilesSmall_;
            iCacheThumbCount = iCacheThumbSmallCount;
            break;
        case ThumbnailSizeMedium:
            sSize = @"Medium";
            arrThumbs = arrThumbFilesMedium_;
            iCacheThumbCount = iCacheThumbMediumCount;
            break;
        default:
            arrThumbs = arrThumbFilesSmall_;
            sSize = @"Small";
            iCacheThumbCount = iCacheThumbSmallCount;
            break;
    }
    sThumbDirPath = [kPathDocThumb stringByAppendingPathComponent:sSize];
    sDirPath = [sThumbDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i",docId]];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:sDirPath]) {
        //NSLog(@"dir existed", @"");
        [arrThumbs removeObject:@(docId)];
        if (![fileManager removeItemAtPath:sDirPath error:&error])
            return NO;
    }
    
    [fileManager createDirectoryAtPath:sDirPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    NSData *data = UIImageJPEGRepresentation(img, 1.0);
    sNewFileName = [sDirPath stringByAppendingPathComponent:sNewFileName];
    //NSLog(@"Save thumb: %@", sNewFileName);
    [arrThumbs addObject:@(docId)];
    
    int iNoOfItemToDelete = [arrThumbs count] - iCacheThumbCount;
    for (int i=0; i<iNoOfItemToDelete; i++) {
        //must delete top items on cache
        int iDocIdToDelete = [arrThumbs[0] intValue];
        //NSLog(@"Delete first item on cache: %i", iDocIdToDelete);
        sDirPath = [sThumbDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", iDocIdToDelete]]; //delete the dir which contains doc
        [fileManager removeItemAtPath:sDirPath error:&error];
        [arrThumbs removeObjectAtIndex:0];
    }
    //[self saveArrThumbFile:thumbSize];
    
    return [fileManager createFileAtPath:sNewFileName contents:data attributes:nil];
}

+ (UIImage*)openThumb:(int)docId size:(ThumbnailSize)thumbSize  modifiedDate:(int)modifiedDate {
    UIImage *ret = nil;
    NSNumber *numDocId;
    //NSLog(@"CommonVar - openThumb - docId: %i", docId);
    //NSLog(@"CommonVar - openThumb - arrThumbSmall: %@", [arrThumbFilesSmall_ description]);
    //NSLog(@"CommonVar - openThumb - arrThumbMedium: %@", [arrThumbFilesMedium_ description]);
    NSString *sNewFileName = [NSString stringWithFormat:@"%i.jpg", modifiedDate];
    NSString *sDirPath;
    NSMutableArray *arrThumbs;
    switch (thumbSize) {
        case ThumbnailSizeSmall:
            sDirPath = @"Small";
            arrThumbs = arrThumbFilesSmall_;
            break;
        case ThumbnailSizeMedium:
            sDirPath = @"Medium";
            arrThumbs = arrThumbFilesMedium_;
            break;
        default:
            sDirPath = @"Small";
            arrThumbs = arrThumbFilesSmall_;
            break;
    }
    sDirPath = [[kPathDocThumb stringByAppendingPathComponent:sDirPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i",docId]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:sDirPath]) {  //thumbnail (directory) existed, need to check modified date (file name) more...
        //NSLog(@"dir existed", @"");
        NSArray *arrFiles = [fileManager contentsOfDirectoryAtPath:sDirPath error:&error];
        if (arrFiles) {
            if ([arrFiles count] > 0) {
                NSString *sOldFileName = arrFiles[0];
                if ([sOldFileName isEqualToString:sNewFileName]) {
                    //NSLog(@"Found old thumb: %@", sOldFileName);
                    ret = [UIImage imageWithContentsOfFile:[sDirPath stringByAppendingPathComponent:sOldFileName]]; //correct version of thumb -> return
                    goto EndOpenThumb;
                }
            }
        }
        [fileManager removeItemAtPath:sDirPath error:&error];
    }
    
EndOpenThumb:
    
    numDocId = @(docId);
    if (arrThumbs) {
        if ([arrThumbs containsObject:numDocId]) {  //move the current id to bottom (because it's the lastest item accessed)
            [arrThumbs removeObject:numDocId];
            [arrThumbs addObject:numDocId];
        }
    }
    [self saveArrThumbFile:thumbSize];
    
    //NSLog(@"CommonVar - openThumb - end func", @"");
    return ret;
}

+ (void)saveArrThumbFile:(ThumbnailSize)thumbSize {
    switch (thumbSize) {
        case ThumbnailSizeSmall:
            //NSLog(@"CommonVar - saveArrThumbFile - arrThumbSmall: %@", [arrThumbFilesSmall_ description]);
            [arrThumbFilesSmall_ writeToFile:[kPathDocThumb stringByAppendingPathComponent:@"Small.json"] atomically:YES];
            break;
        case ThumbnailSizeMedium:
            //NSLog(@"CommonVar - saveArrThumbFile - arrThumbMedium: %@", [arrThumbFilesMedium_ description]);
            [arrThumbFilesMedium_ writeToFile:[kPathDocThumb stringByAppendingPathComponent:@"Medium.json"] atomically:YES];
            break;
        default:
            [arrThumbFilesSmall_ writeToFile:[kPathDocThumb stringByAppendingPathComponent:@"Small.json"] atomically:YES];
            break;
    }
    //NSLog(@"CommonVar - saveArrThumbFile - end func", @"");
}

#pragma mark -
#pragma mark Save and Read Document
+ (NSURL*)saveDoc:(NSData*)data docId:(int)docId modifiedDate:(int)modifiedDate fileExt:(NSString*)fileExt{
    NSString *sNewFileName = [NSString stringWithFormat:@"%i.%@", modifiedDate, fileExt];
    NSString *sDocDirPath, *sDirPath;
    sDocDirPath = [kPathDocThumb stringByAppendingPathComponent:@"DocFile"];
    sDirPath = [sDocDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i",docId]];
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    //check directory
    if ([fileManager fileExistsAtPath:sDirPath]) {
        //NSLog(@"dir existed", @"");
        [arrDocFiles_ removeObject:@(docId)];
        if (![fileManager removeItemAtPath:sDirPath error:&error])
            return NO;
    }
    [fileManager createDirectoryAtPath:sDirPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    //save file
    sNewFileName = [sDirPath stringByAppendingPathComponent:sNewFileName];
    //NSLog(@"CommonVar - saveDoc - new file name: %@", sNewFileName);
    [fileManager createFileAtPath:sNewFileName contents:data attributes:nil];
    
    //update list of cached doc id + delete old cached items if needed
    [arrDocFiles_ addObject:@(docId)];
    //NSLog(@"CommonVar - saveDoc - lDocCacheSize = %qu", lDocCacheSize);
    
    NSArray *arrExtensions = kSupportedFileExts;
    unsigned long long lMemoryUsed = [CommonVar getDirSize:sDocDirPath fileExtensions:arrExtensions];
    //NSLog(@"CommonVar - saveDoc - memory used = %qu", lMemoryUsed);
    
    //unsigned long long lNewFileSize = [[[fileManager attributesOfItemAtPath:sNewFileName error:&error] valueForKey:NSFileSize] unsignedLongLongValue];
    //NSLog(@"CommonVar - saveDoc - new file size = %qu", lNewFileSize);
    
    while ([arrDocFiles_ count] > 1 && lMemoryUsed > lDocCacheSize) {
        
        int iDocIdToDelete = [arrDocFiles_[0] intValue];
        //NSLog(@"CommonVar - Delete first item on doc cache: %i", iDocIdToDelete);
        sDirPath = [sDocDirPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%i", iDocIdToDelete]]; //delete the dir which contains doc
        
        lMemoryUsed -= [CommonVar getDirSize:sDirPath fileExtensions:arrExtensions];
        
        [fileManager removeItemAtPath:sDirPath error:&error];
        [arrDocFiles_ removeObjectAtIndex:0];
        
        //NSLog(@"CommonVar - saveDoc - memory used = %qu", lMemoryUsed);
    }
    
    [arrDocFiles_ writeToFile:[kPathDocThumb stringByAppendingPathComponent:@"DocFile.json"] atomically:YES];
    
    return [NSURL fileURLWithPath:sNewFileName];
}

+ (NSURL*)getDocURL:(int)docId modifiedDate:(int)modifiedDate fileExt:(NSString*)fileExt {
    //NSLog(@"CommonVar - openDoc - docId: %i", docId);
    NSURL *url = nil;
    NSNumber *numDocId;
    NSString *sNewFileName = [NSString stringWithFormat:@"%i.%@", modifiedDate, fileExt];
    NSString *sDirPath = [[kPathDocThumb stringByAppendingPathComponent:@"DocFile"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%i",docId]];;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    if ([fileManager fileExistsAtPath:sDirPath]) {  //thumbnail (directory) existed, need to check modified date (file name) more...
        //NSLog(@"dir existed", @"");
        NSArray *arrFiles = [fileManager contentsOfDirectoryAtPath:sDirPath error:&error];
        if (arrFiles) {
            if ([arrFiles count] > 0) {
                NSString *sOldFileName = arrFiles[0];
                if ([sOldFileName isEqualToString:sNewFileName]) {
                    url = [NSURL fileURLWithPath:[sDirPath stringByAppendingPathComponent:sOldFileName]]; //correct version of thumb -> return
                    //NSLog(@"Found old thumb: %@", url);
                    
                    goto EndOpenDoc;
                }
            }
        }
        [fileManager removeItemAtPath:sDirPath error:&error];
    }    
    
EndOpenDoc:
    numDocId = @(docId);
    if (arrDocFiles_) {
        if ([arrDocFiles_ containsObject:numDocId]) {  //move the current id to bottom (because it's the lastest item accessed)
            [arrDocFiles_ removeObject:numDocId];
            [arrDocFiles_ addObject:numDocId];
        }
    }
    [arrDocFiles_ writeToFile:[kPathDocThumb stringByAppendingPathComponent:@"DocFile.json"] atomically:YES];
    
    return url;
}


+ (unsigned long long)getDirSize:(NSString*)path fileExtensions:(NSArray*)arrExt {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:path];
    unsigned long long ret = 0;
    NSString *file;
    NSError *error;
    while (file = [dirEnum nextObject]) {
        if ([arrExt containsObject:[file pathExtension]]) {
            ret += [[[fm attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:&error] valueForKey:NSFileSize] unsignedLongLongValue];
        }
    }
    return ret;
}

+ (unsigned long long)getDirSize:(NSString*)path fileExtension:(NSString*)sExt {
    NSFileManager *fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator *dirEnum = [fm enumeratorAtPath:path];
    unsigned long long ret = 0;
    NSString *file;
    NSError *error;
    while (file = [dirEnum nextObject]) {
        if ([[file pathExtension] isEqualToString:sExt]) {
            ret += [[[fm attributesOfItemAtPath:[path stringByAppendingPathComponent:file] error:&error] valueForKey:NSFileSize] unsignedLongLongValue];
        }
    }
    return ret;
}


#pragma mark -
#pragma mark App version
static NSString *appVersion_ = @"1.2";

+ (NSString*)appVersion {
    return appVersion_;
}

+ (void)setAppVersion:(NSString*)value {
    if (appVersion_ != value) {
        appVersion_ = value;
    }
}


#pragma mark -
#pragma mark Main NavigationController
static UINavigationController *mainNavigationController_ = nil;
+ (UINavigationController*)mainNavigationController {
    return mainNavigationController_;
}

+ (void)setMainNavigationController:(UINavigationController*)value {
    if (mainNavigationController_ != value) {
        mainNavigationController_ = value;
    }
}

#pragma mark -
#pragma mark DocumentController
static NSObject *docCon_ = nil;
+ (NSObject*)docCon {
    return docCon_;
}

+ (void)setDocCon:(NSObject*)value {
    if (docCon_ != value) {
        docCon_ = value;
    }
}

#pragma mark -
#pragma mark Account Info
static NSDictionary *dictAccountInfo_ = nil;
+ (void) loadAccountInfo {
    NSString *request = [[CommonVar requestURL] stringByAppendingString:@"accountinfo"];
    NSDictionary *dict = [CommonFunc jsonDictionaryGET:request];
    if (dict) {
        dictAccountInfo_ = [dict valueForKey:@"account"];
    }
}
+ (NSDictionary*)dictAccountInfo {
    return dictAccountInfo_;
}
@end
