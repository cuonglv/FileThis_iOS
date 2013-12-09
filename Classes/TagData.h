//
//  TagData.h
//  FTMobile
//
//  Created by decuoi on 12/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TagData : NSObject {
    int iTagId, iDocCount;
    NSString *sTagName;
}
@property (assign) int iTagId, iDocCount;
@property (nonatomic, strong) NSString *sTagName;

- (id)initWithId:(int)tagId name:(NSString*)name count:(int)count;
- (id)initWithId:(int)tagId;
@end
