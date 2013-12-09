//
//  TagData.m
//  FTMobile
//
//  Created by decuoi on 12/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "TagData.h"


@implementation TagData
@synthesize iTagId, iDocCount, sTagName;

- (id)initWithId:(int)tagId name:(NSString*)name count:(int)count {
    if ((self = [super init])) {
        self.iTagId = tagId;
        self.sTagName = name;
        self.iDocCount = count;
    }
    return self;
}

- (id)initWithId:(int)tagId {
    if ((self = [super init])) {
        self.iTagId = tagId;
    }
    return self;
}

@end
