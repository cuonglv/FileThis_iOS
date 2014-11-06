//
//  EventManager.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Enums.h"
#import "Event.h"
#import "EventProtocol.h"

@interface EventManager : NSObject {
    NSMutableDictionary         *dictChannel;
}
/**
 * create singleton instance for event manager
 */
+ (EventManager *)getInstance;

/**
 * add listener for upnp discovery device
 */
- (void)addListener:(id<EventProtocol>)listener channel:(CHANNEL_PIPE)channel;
/**
 *	remove listen
 */
- (void)removeListener:(id)listener channel:(CHANNEL_PIPE)channel;

/**
 *	remove listen by channel
 */
- (void)removeListenerByChannel:(CHANNEL_PIPE)channel;

/**
 *	remove all listen
 */
- (void)removeAllListener;
/**
 *	Call back to UI
 */
- (void)callbackToChannelProtocolWithEvent:(Event *)event channel:(CHANNEL_PIPE)channel;

- (BOOL)checkEventListenerAvailable:(CHANNEL_PIPE)channel;

@end
