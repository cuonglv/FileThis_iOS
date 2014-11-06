//
//  LoadingViewAlertHandler.m
//  FileThis
//
//  Created by Cuong Le on 2/25/14.
//
//

#import "LoadingViewAlertHandler.h"
#import "LoadingView.h"
#import "ThreadObj.h"
#import "EventManager.h"

@implementation LoadingViewAlertHandler

static LoadingViewAlertHandler *instance_ = nil;

+ (id)getInstance {
    @synchronized(self) {
        if (instance_ == nil) {
            instance_ = [[LoadingViewAlertHandler alloc] init];
        }
    }
    
    return instance_;
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if ([alertView isKindOfClass:[MyAlertView class]]) {
        if (buttonIndex == 0) {
            MyAlertView *myAlertView = (MyAlertView*)alertView;
            if (myAlertView.data) {
                if ([myAlertView.data isKindOfClass:[LoadingView class]]) {
                    LoadingView *loadingView = myAlertView.data;
                    if (loadingView.threadObj) {
                        if ([loadingView.threadObj conformsToProtocol:@protocol(ThreadProtocol)]) {
                            if ([loadingView.threadObj isExecuting])
                                [loadingView.threadObj cancel];
                            
                            [loadingView stopLoading];
                            
                            Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_CANCEL_LOADING_DATA];
                            [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
                        }
                    }
                }
            }
        }
    }
}

@end
