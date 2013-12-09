//
//  Base64Tests.m
//  FileThis
//
//  Created by Gabrielle on 5/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Base64Tests.h"
#import "NSData+Base64.h"
#import <SenTestingKit/SenTestingKit.h>

@implementation Base64Tests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Tear-down code here.
    [super tearDown];
}

-(NSString *)decodeString:(const char *)s {
    size_t length = 0;
    void *d = NewBase64Decode(s, strlen(s), &length);
    
    NSString *s2 = [[NSString alloc] initWithBytes:d length:length encoding:NSUTF8StringEncoding];
    free(d);
    return s2;
}

- (char *)encodeString:(NSString *)s {
    bool separateLines = false;
    return NewBase64Encode([s cStringUsingEncoding:NSUTF8StringEncoding], [s length], separateLines, NULL);
}

-(void)testEncodeString {
    char filler[100];
    for (int i = 0; i < 32; i++) {
        filler[i] = '*'; filler[i + 1] = 0;
        NSString *s = [NSString stringWithFormat:@"Woo Hoo does this work? %s", filler];
        char *cString = [self encodeString:s];
        NSString *s2 = [self decodeString:cString];
        STAssertEqualObjects(s, s2, @"input == output");
        NSLog(@"encoded string %s from %@", cString, s);
        free(cString);
    }
    STAssertTrue(true,@"Unit tests are not implemented yet in FTServerUnitTests");
}

@end
