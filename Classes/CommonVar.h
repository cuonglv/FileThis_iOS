//
//  CommonVar.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Constants.h"


typedef enum {
    ThumbnailSizeSmall,
    ThumbnailSizeMedium,
    DocumentFile
} ThumbnailSize;

@interface CommonVar : NSObject {

}

+ (void)loadVar;
+ (BOOL)varLoaded;
+ (void)loadAtomicVar;

#pragma mark -
+ (NSString*)ticket;
+ (void)setTicket:(NSString*)value;

#pragma mark -
+ (NSString*)requestURL;
+ (void)setRequestURL:(NSString*)value;

#pragma mark -
+ (NSUserDefaults *)dictPlist;
+ (void)savePlist;

#pragma mark -
+ (int)docPageSize;
+ (int)docThumbSmallWidth;
+ (int)docThumbSmallHeight;
+ (int)cacheThumbSmallCount;

#pragma mark -
#pragma mark All Cab List
+ (NSMutableDictionary*)mdictAllCabs;
+ (void)loadAllCabs;
+ (NSDictionary*)getCab:(int)cabId;
//+ (NSString*)getCabName:(int)cabId;

#pragma mark -
#pragma mark All Tag List;
+ (NSArray*)arrAllCabs;
+ (NSMutableDictionary*)mdictAllTags;
+ (void)loadAllTags;
//+ (NSDictionary*)getTag:(int)tagId;
+ (NSString*)getTagName:(int)tagId;
+ (NSString*)getTagNames:(NSArray*)tagIds;

/*
#pragma mark -
+ (int)cabId;
+ (void)setCabId:(int)value;

#pragma mark -
+ (NSString*)sortBy;
+ (void)setSortBy:(NSString*)value;

#pragma mark -
+ (BOOL)sortDescending;
+ (void)setSortDescending:(BOOL)value;


#pragma mark -
+ (CabinetType)cabType;
+ (void)setCabType:(CabinetType)value;
 */

#pragma mark -
#pragma mark Thumb Files
+ (NSMutableArray*)arrThumbFilesSmall;
+ (NSMutableArray*)arrThumbFilesMedium;
+ (NSMutableArray*)arrCachedDocs;

#pragma mark -
#pragma mark Save & Read Images
+ (BOOL)saveThumb:(UIImage*)img docId:(int)docId size:(ThumbnailSize)thumbsize modifiedDate:(int)modifiedDate;
+ (UIImage*)openThumb:(int)docId size:(ThumbnailSize)thumbSize  modifiedDate:(int)modifiedDate;
+ (void)saveArrThumbFile:(ThumbnailSize)thumbSize;

#pragma mark -
#pragma mark Save and Read Document
+ (NSURL*)saveDoc:(NSData*)data docId:(int)docId modifiedDate:(int)modifiedDate fileExt:(NSString*)fileExt;
+ (NSURL*)getDocURL:(int)docId modifiedDate:(int)modifiedDate fileExt:(NSString*)fileExt;


+ (unsigned long long)getDirSize:(NSString*)path fileExtensions:(NSArray*)arrExt;
+ (unsigned long long)getDirSize:(NSString*)path fileExtension:(NSString*)sExt;

#pragma mark -
#pragma mark App version
+ (NSString*)appVersion;
+ (void)setAppVersion:(NSString*)value;

#pragma mark -
#pragma mark Main NavigationController
+ (UINavigationController*)mainNavigationController;
+ (void)setMainNavigationController:(UINavigationController*)value;

#pragma mark -
#pragma mark DocumentController
+ (NSObject*)docCon;
+ (void)setDocCon:(NSObject*)value;

#pragma mark -
#pragma mark Account Info
+ (void)loadAccountInfo;
+ (NSDictionary*)dictAccountInfo;
@end
