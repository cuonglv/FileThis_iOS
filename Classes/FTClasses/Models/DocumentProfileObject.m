//
//  DocumentProfileObject.m
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "DocumentProfileObject.h"

@implementation DocumentProfileObject

- (id)init {
    self = [super init];
    if (self) {
        self.arrDocuments = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
