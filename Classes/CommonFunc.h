//
//  CommonFunc.h
//  FTMobileApp
//
//  Created by decuoi on 11/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SortCriteriaObject.h"
#import "TagObject.h"
#import "CommonDataManager.h"
#import "DocumentDataManager.h"
#import "MenuItem.h"

#define stringNotNil(x) (x)?(x):@""

@interface CommonFunc : NSObject {
}

+ (Class)idiomClassWithName:(NSString*)className;
+ (BOOL)isTallScreen;
+ (NSObject*)findObjectWithValue:(id)value bykey:(NSString*)key fromArray:(NSArray*)array;

#pragma mark Get Server Data
+ (UIImage *)serverGETImage:(NSString *)link;
+ (NSString *)serverGET:(NSString *)link;
+ (BOOL)isTouchPointOutsideControl:(CGPoint)point forControl:(UIView *)view;

#pragma mark -
#pragma mark JSON
+ (id)jsonDictionaryFromString:(NSString *)content;
+ (id)jsonObjGET:(NSString *)link;
+ (NSDictionary *) jsonDictionaryGET:(NSString *)link;

+ (NSString*)dateStringFromInt:(int)dateInt;
+ (NSString*)dateStringShortFromInt:(int)dateInt;
+ (NSString*)dateStringFromInt:(int)dateInt format:(NSString *)format;
+ (NSString*)dateStringFromInterval:(NSTimeInterval)interval format:(NSString *)format;

#pragma mark Alert
+ (void)alert:(NSString*)mesg;

#pragma mark Cabinet
+ (UIColor *)getCabColorByType:(NSString *)cabType;
+ (UIImage *)getCabBackgroundImageByType:(NSString *)cabType;

#pragma mark -
#pragma mark Read & Write File
+ (NSString*)fullPathFromDocumentDirectory:(NSString*)filename;
+ (NSString *)readFile:(NSString *)path;
+ (NSString *)readFileInDocumentDir:(NSString *)filename;
+ (void)writeFileInDocumentDir:(NSString *)filename content:(NSString *)content; 
+ (NSString *)getFilePathInDocumentDir:(NSString *)filename;

+ (NSString*)getFileSizeString:(unsigned long long)fileSize;

+ (BOOL)isNetworkAvailable;
+ (NSString *)getSecretKey;
+ (NSString *)getUsername;

+ (BOOL)validateEmail:(NSString*)email;
+ (NSMutableArray*)emailsListFromString:(NSString*)emails;

+ (void)sortDocuments:(NSMutableArray *)documents sortBy:(SORTBY)sortBy;
+ (void)sortDocumentCabinets:(NSMutableArray *)documentCabinets;
+ (void)sortDocumentProfiles:(NSMutableArray *)documentProfiles;

+ (void)selectMenu:(MenuItem)menuItem animated:(BOOL)animated;

@end
