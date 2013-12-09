//
//  CheckNetworkStatus.m
//  GreatestRoad
//
//  Created by Nam Phan on 5/21/10.
//  Copyright 2010 filethis.com. All rights reserved.
//

#import "CheckNetworkStatus.h"
#import <SystemConfiguration/SystemConfiguration.h>
#include <netinet/in.h>

@implementation CheckNetworkStatus

@synthesize isNetworkAvailable, done;

- (BOOL)connectedToNetwork {	
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
	
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
	
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
	
	done = NO;
	isNetworkAvailable = NO;
    if (!didRetrieveFlags)
    {
        //NSLog(@"Error. Could not recover network reachability flags");
		done = YES;
        return isNetworkAvailable;
    }

    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
	BOOL nonWiFi = flags & kSCNetworkReachabilityFlagsTransientConnection;
	
	NSURL *testURL = [NSURL URLWithString:@"http://www.apple.com/"];
	NSURLRequest *testRequest = [NSURLRequest requestWithURL:testURL cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
	NSURLConnection *testConnection = [[NSURLConnection alloc] initWithRequest:testRequest delegate:self];
	if ( testConnection != nil) {
        do {
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }  while (!done);
    }
    return ((isReachable && !needsConnection) || nonWiFi) ? isNetworkAvailable : NO;
}

#pragma mark NSURLConnection Delegate methods

/*
 Disable caching so that each time we run this app we are starting with a clean slate. You may not want to do this in your application.
 */
- (NSCachedURLResponse *)connection:(NSURLConnection *)aConnection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    return nil;
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ( response )
	{
		//NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//		NSLog(@"network status code = %d   reason = %@", [httpResponse statusCode], [NSHTTPURLResponse localizedStringForStatusCode:[httpResponse statusCode]] );
		isNetworkAvailable = YES;
		done = YES;
		[connection cancel];
	}
}

// Forward errors to the delegate.
- (void)connection:(NSURLConnection *)aConnection didFailWithError:(NSError *)error {
    done = YES;
}


// Called when a chunk of data has been downloaded.
- (void)connection:(NSURLConnection *)aConnection didReceiveData:(NSData *)data {
}

- (void)connectionDidFinishLoading:(NSURLConnection *)aConnection {
    done = YES; 
}

@end
