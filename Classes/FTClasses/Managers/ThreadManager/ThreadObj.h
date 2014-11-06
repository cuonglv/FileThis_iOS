//
//  ThreadObj.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ThreadProtocol <NSObject>

- (BOOL)isCancelled;
- (void)cancel;
- (BOOL)isExecuting;
- (BOOL)isFinished;
- (BOOL)isReady;
- (void)releaseOperation;
@end

@interface ThreadObj : NSObject <ThreadProtocol>
@property (strong) NSInvocationOperation    *invocationOperation;
@end
