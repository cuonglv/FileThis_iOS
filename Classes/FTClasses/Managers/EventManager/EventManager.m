//
//  EventManager.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "EventManager.h"

@interface EventManager()
@property (nonatomic, retain)   NSMutableDictionary         *dictChannel;
- (NSString *)keyForChannel:(CHANNEL_PIPE)channel;
@end
@implementation EventManager

@synthesize dictChannel;

/**
 * create singleton instance for device manager
 */
+ (EventManager *)getInstance
{
    static EventManager *eventManager = nil;
	if (eventManager)
	{
		return eventManager;
	}
	@synchronized(self)
	{
		if (eventManager == nil)
		{
			eventManager = [[EventManager alloc] init];
		}
	}
	return eventManager;
}

- (id)init
{
    self = [super init];
	if (self)
	{
        self.dictChannel = [NSMutableDictionary dictionaryWithCapacity:8];
	}
	return self;
}

#pragma mark -
- (void)addListener:(id<EventProtocol>)listener channel:(CHANNEL_PIPE)channel
{
    @synchronized(self) {
        NSMutableArray *array = [dictChannel objectForKey:[self keyForChannel:channel]];
        if (array == nil) {
            [dictChannel setObject:[NSMutableArray array] forKey:[self keyForChannel:channel]];
            array = [dictChannel objectForKey:[self keyForChannel:channel]];
            }
        if (![array containsObject:listener]) {
            [array addObject:listener];
        }
    }
}

- (void)removeListener:(id)listener channel:(CHANNEL_PIPE)channel
{
    @synchronized(self) {
        NSMutableArray *array = [self.dictChannel objectForKey:[self keyForChannel:channel]];
        if ([array containsObject:listener]) {
            [array removeObject:listener];
        }
    }
}

- (void)removeListenerByChannel:(CHANNEL_PIPE)channel
{
    @synchronized(self) {
        [self.dictChannel removeObjectForKey:[self keyForChannel:channel]];
        NSLog(@"self.dictChannel allKey count = %d", [[self.dictChannel allKeys] count]);
    }
}

- (void)removeAllListener
{
    @synchronized(self) {
        [self.dictChannel removeAllObjects];
    }
}

- (BOOL)checkEventListenerAvailable:(CHANNEL_PIPE)channel
{
    @synchronized(self) {
        NSMutableArray *array = [self.dictChannel objectForKey:[self keyForChannel:channel]];
        if (array != nil && [array count] > 0) return YES;
        return NO;
    }
}

- (void)callbackToChannelProtocolWithEvent:(Event *)event channel:(CHANNEL_PIPE)channel
{
    NSMutableArray *array = [self.dictChannel objectForKey:[self keyForChannel:channel]];
    if (array) {
        NSArray *objects = [NSArray arrayWithArray:array];
        for (id delegate in objects) {
                if ([delegate conformsToProtocol:@protocol(EventProtocol)]) {
                    [delegate didReceiveEvent:event];
                }
            }
        }
    }

#pragma mark - Private api
- (NSString *)keyForChannel:(CHANNEL_PIPE)channel
        {
    NSString *str;
    switch (channel) {
        case CHANNEL_UI:
            str = @"CHANNEL_UI";
            break;
        default:
            str = @"UNKNOWN";
            break;
    }
    return str;
}

@end
