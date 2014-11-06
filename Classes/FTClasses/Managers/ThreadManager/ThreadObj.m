//
//  ThreadObj.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "ThreadObj.h"

@implementation ThreadObj

- (BOOL)isCancelled
{
    return [_invocationOperation isCancelled];
}

- (void)cancel
{
    [_invocationOperation cancel];
}

- (BOOL)isExecuting
{
    return [_invocationOperation isExecuting];
}

- (BOOL)isFinished
{
    return [_invocationOperation isFinished];
}

- (BOOL)isReady
{
    return [_invocationOperation isReady];
}

- (void)releaseOperation
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        self.invocationOperation = nil;
    });
}
@end
