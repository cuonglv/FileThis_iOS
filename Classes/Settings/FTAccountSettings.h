//
//  FTAccountSettings.h
//  FileThis
//
//  Created by Drew Wilson on 12/12/12.
//
//

@class SKPaymentTransaction;

@interface FTAccountSettings : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;

@property NSString *firstName;
@property NSString *lastName;
@property NSString *email;
@property NSInteger logoutAfterMinutes; // 0 - no timeout

// notifications
@property BOOL emailCampaign;
@property BOOL emailFailures;
@property BOOL emailSuccesses;

@property (readonly) NSString *memberSince;
@property (readonly) NSString *lastLogin;
@property (readonly) NSString *autoRenewsOn;

@property (readonly) BOOL isSubscriber;
@property (readonly) BOOL isApplePayment;
@property (readonly) BOOL isRecurringPayment;

@property (readonly) NSString *localizedServicePlan; // e.g. "Premium Monthly"

- (void)applyPayment:(SKPaymentTransaction *)transaction;

- (void)save;

@end

