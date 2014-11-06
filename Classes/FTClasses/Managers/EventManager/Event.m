//
//  Event.m
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import "Event.h"


@implementation Event

@synthesize _data, _statusMessage;

/**
 * initialize event with special type
 */
- (id)initEventWithType:(EVENTTYPE)eventType
{
	if ( self = [super init] )
	{
		_eventType = eventType;
		_eventStatus = STATUS_OK;
	}
	return self;
}

/**
 *	set event type
 */
- (void)setEventType:(EVENTTYPE)newEvent
{
	_eventType = newEvent;
}

/**
 * Returns the event type
 * @return
 */
- (EVENTTYPE)getEventType
{
	return _eventType;
}

/**
 * Set status code
 * @param statusCode
 */
- (void)setStatusCode:(EVENTSTATUS)eventStatus
{
	_eventStatus = eventStatus;
}

/**
 * Get status code
 * @return
 */
- (EVENTSTATUS)getStatusCode
{
	return _eventStatus;
}

/**
 * Set status message
 * @param statusMessage
 */
- (void)setStatusMessage:(NSString *)statusMessage
{
	self._statusMessage = statusMessage;
}

/**
 * Get status message
 * @return
 */
- (NSString *)getStatusMessage
{
	return self._statusMessage;
}

/**
 * Set event content object
 * @param content
 */
- (void)setContent:(id <NSObject>)content
{
	self._data = content;
}

/**
 * Get event content object
 * @return
 */
- (id)getContent
{
	return self._data;
}

@end
