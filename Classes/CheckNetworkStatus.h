//
//  CheckNetworkStatus.h
//  GreatestRoad
//
//  Created by Nam Phan on 5/21/10.
//  Copyright 2010 filethis.com. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckNetworkStatus : NSObject {
	BOOL					isNetworkAvailable;
	BOOL					done;
}

@property (nonatomic, assign) BOOL isNetworkAvailable;
@property (nonatomic, assign) BOOL done;

- (BOOL)connectedToNetwork;

@end
