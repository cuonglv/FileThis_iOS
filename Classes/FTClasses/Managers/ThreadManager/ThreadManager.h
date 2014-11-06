//
//  ThreadManager.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ThreadObj.h"

@interface ThreadManager : NSObject

+ (ThreadManager *)getInstance;
- (id<ThreadProtocol>)dispatchToNormalThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument;
- (id<ThreadProtocol>)dispatchToLowThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument;
@end
