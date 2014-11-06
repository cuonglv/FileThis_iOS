//
//  EventProtocol.h
//  FileThis
//
//  Created by Manh Nguyen Ngoc on 12/03/13.
//  Copyright (c) 2013 PlanvSoftware. All rights reserved.
//

#import <Foundation/Foundation.h>
#import	"Event.h"

@protocol EventProtocol <NSObject>

- (void)didReceiveEvent:(Event *)event;

@end
