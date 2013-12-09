//
//  AppleStoreObserver.h
//  FileThis
//
//  Created by Drew Wilson on 1/15/13.
//
//

#import <Foundation/Foundation.h>
#import <StoreKit/StoreKit.h>

@interface SKPaymentTransaction (FileThisExtensions)

- (NSNumber *)expiration;
-(NSString *)ftDescription;

@end

@interface AppleStoreObserver : NSObject <SKPaymentTransactionObserver>

@property (readonly) NSArray *products;

- (void)login;
- (NSString *)localizedNameForAppleProductIdentifier:(NSString *)identifier;

+(AppleStoreObserver *)sharedObserver;

@end
