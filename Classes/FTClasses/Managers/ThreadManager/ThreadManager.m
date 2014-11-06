//
//  ThreadManager.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "ThreadManager.h"

@interface ThreadManager()
@property (nonatomic, retain)   NSOperationQueue    *normalQueue;
@end

@implementation ThreadManager

- (id)init
{
    self = [super init];
    if (self) {
        _normalQueue = [[NSOperationQueue alloc] init];
        [_normalQueue setMaxConcurrentOperationCount:10];
    }
    return self;
}

+ (ThreadManager *)getInstance
{
    static ThreadManager *instance = nil;
    if (instance != nil) return instance;
    @synchronized(self) {
        if (instance == nil) {
            instance = [[ThreadManager alloc] init];
        }
    }
    return instance;
}

- (id<ThreadProtocol>)dispatchToNormalThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument
{
    if (argument == nil) return nil;
    NSMethodSignature *sig = [target methodSignatureForSelector:sel];
    ThreadObj *argumentThreadObj = [[ThreadObj alloc] init];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:target];
    [invocation setSelector:sel];
    [invocation setArgument:&argument atIndex:2];
    [invocation setArgument:&argumentThreadObj atIndex:3];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    [operation setQueuePriority:NSOperationQueuePriorityNormal];
    argumentThreadObj.invocationOperation = operation;
    [_normalQueue addOperation:operation];
    return argumentThreadObj;
}

- (id<ThreadProtocol>)dispatchToLowThreadWithTarget:(id)target selector:(SEL)sel argument:(id)argument
{
    if (argument == nil) return nil;
    NSMethodSignature *sig = [target methodSignatureForSelector:sel];
    ThreadObj *argumentThreadObj = [[ThreadObj alloc] init];
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sig];
    [invocation setTarget:target];
    [invocation setSelector:sel];
    [invocation setArgument:&argument atIndex:2];
    [invocation setArgument:&argumentThreadObj atIndex:3];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithInvocation:invocation];
    [operation setQueuePriority:NSOperationQueuePriorityLow];
    argumentThreadObj.invocationOperation = operation;
    [_normalQueue addOperation:operation];
    return argumentThreadObj;
}

@end
