//
//  NSString+Custom.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonHMAC.h>
#import <CommonCrypto/CommonCryptor.h>

@interface NSString (Custom)

- (NSString *)md5;
- (NSString *)sha1;
- (NSString *)urlEncode;
- (NSRange)rangeOfStringSearchByWord:(NSString*)searchString;
- (int)insertIntoOrderedArray:(NSMutableArray*)array;   //return the inserted index

@end
