//
//  CommonFunc.h
//  FTMobileApp
//
//  Created by decuoi on 11/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CommonFunc : NSObject {
}

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

#pragma mark Alert
+ (void)alert:(NSString*)mesg;

#pragma mark Cabinet
+ (UIColor *)getCabColorByType:(NSString *)cabType;
+ (UIImage *)getCabBackgroundImageByType:(NSString *)cabType;

#pragma mark -
#pragma mark Read & Write File
+ (NSString *)readFile:(NSString *)path;
+ (NSString *)readFileInDocumentDir:(NSString *)filename;
+ (void)writeFileInDocumentDir:(NSString *)filename content:(NSString *)content; 
+ (NSString *)getFilePathInDocumentDir:(NSString *)filename;

+ (NSString*)getFileSizeString:(unsigned long long)fileSize;

+ (BOOL)isNetworkAvailable;
@end
