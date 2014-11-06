//
//  NSString+Custom.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "NSString+Custom.h"

@implementation NSString (Custom)

- (NSString*)md5 {
    // Create pointer to the string as UTF8
    const char *ptr = [self UTF8String];
    
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (uint32_t)strlen(ptr), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

- (NSString *)sha1 {
    const char *cstr = [self cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:self.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

- (NSString *)urlEncode {
    NSMutableString *output = [NSMutableString string];
    const unsigned char *source = (const unsigned char *)[self UTF8String];
    int sourceLen = strlen((const char *)source);
    for (int i = 0; i < sourceLen; ++i) {
        const unsigned char thisChar = source[i];
        if (thisChar == ' '){
            [output appendString:@"+"];
        } else if (thisChar == '.' || thisChar == '-' || thisChar == '_' || thisChar == '~' ||
                   (thisChar >= 'a' && thisChar <= 'z') ||
                   (thisChar >= 'A' && thisChar <= 'Z') ||
                   (thisChar >= '0' && thisChar <= '9')) {
            [output appendFormat:@"%c", thisChar];
        } else {
            [output appendFormat:@"%%%02X", thisChar];
        }
    }
    return output;
}

- (NSRange)rangeOfStringSearchByWord:(NSString*)searchString {
    NSRange range = [self rangeOfString:searchString options:NSCaseInsensitiveSearch];
    if (range.location != NSNotFound) {
        if (range.location == 0)
            return range;
        
        if ([[self substringWithRange:NSMakeRange(range.location - 1, 1)] isEqualToString:@" "])
            return range;
    }
    return NSMakeRange(NSNotFound, 0);
}

- (int)insertIntoOrderedArray:(NSMutableArray*)array {
    if ([array containsObject:self])
        return [array indexOfObject:self];
    
    for (int i = 0, count = [array count]; i < count; i++) {
        if ([self compare:[array objectAtIndex:i] options:NSCaseInsensitiveSearch] == NSOrderedAscending) {
            [array insertObject:self atIndex:i];
            return i;
        }
    }
    
    [array addObject:self];
    return [array count]-1;
}
@end
