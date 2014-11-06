//
//  Event.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Event.h"
#import "Enums.h"

@interface Event : NSObject {
@private
	EVENTTYPE _eventType;
	EVENTSTATUS _eventStatus;
	id <NSObject> _data;
	NSString *_statusMessage;
	
}

@property (readwrite, strong) id <NSObject> _data;
@property (readwrite, copy) NSString *_statusMessage;
/**
 * initialize event with special type
 */
- (id)initEventWithType:(EVENTTYPE)eventType;

/**
 *	set event type
 */
- (void)setEventType:(EVENTTYPE)newEvent;
/**
 * Returns the event type
 * @return
 */
- (EVENTTYPE)getEventType;

/**
 * Set status code
 * @param statusCode
 */
- (void)setStatusCode:(EVENTSTATUS)eventStatus;

/**
 * Get status code
 * @return
 */
- (EVENTSTATUS)getStatusCode;

/**
 * Set status message
 * @param statusMessage
 */
- (void)setStatusMessage:(NSString *)statusMessage;

/**
 * Get status message
 * @return
 */
- (NSString *)getStatusMessage;

/**
 * Set event content object
 * @param content
 */
- (void)setContent:(id <NSObject>)content;

/**
 * Get event content object
 * @return
 */
- (id)getContent;

@end
