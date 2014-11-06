
//  AppleStoreObserver.m
//  FileThis
//
//  Created by Drew Wilson on 1/15/13.
//

#import <StoreKit/StoreKit.h>
#import "FTAccountSettings.h"

#import "MF_Base64Additions.h"
#import "AppleStoreObserver.h"
#import "FTSession.h"
#import "UIKitExtensions.h"

@implementation SKPaymentTransaction (FileThisExtensions)

- (NSString *)stateString {
    switch (self.transactionState) {
        case SKPaymentTransactionStatePurchasing:
            return @"purchasing";
        case SKPaymentTransactionStatePurchased:
            return @"purchased";
        case SKPaymentTransactionStateFailed:
            return @"failed";
        case SKPaymentTransactionStateRestored:
            return @"restored";
    }
    return nil;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (NSDictionary *)purchaseInfo {
    NSDictionary *purchaseInfo = nil;
    if (self.transactionReceipt) {
        NSError *error;
        NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:self.transactionReceipt
                                                                        options:0 format:0 error:&error];
        NSString *purchaseInfoString = plist[@"purchase-info"];
        NSData  *encodedData = [NSData dataWithBase64String:purchaseInfoString];
        purchaseInfo = [NSPropertyListSerialization propertyListWithData:encodedData
                                                                 options:0 format:0 error:&error];
    }
    return purchaseInfo;
}

-(NSString *)ftDescription {
    NSString *expirationString = nil;
    if (self.transactionReceipt) {
        NSError *error;
        NSDictionary *plist = [NSPropertyListSerialization propertyListWithData:self.transactionReceipt
                                                                        options:0 format:0 error:&error];
        NSString *purchaseInfoString = plist[@"purchase-info"];
        NSData  *encodedData = [NSData dataWithBase64String:purchaseInfoString];
        plist = [NSPropertyListSerialization propertyListWithData:encodedData
                                                          options:0 format:0 error:&error];
        expirationString = plist[@"expires-date-formatted"];
    }
    
    NSString *s = [NSString stringWithFormat:@"%@ %@ %@ %@ at %@",
                   self.debugDescription,
                   self.transactionIdentifier,
                   [self stateString],
                   self.payment.productIdentifier,
                   self.transactionDate];
    if (expirationString)
        s = [s stringByAppendingFormat:@", expires %@", expirationString];
    if (self.originalTransaction) {
        s = [s stringByAppendingFormat:@", original transaction %@ on %@",
             self.originalTransaction.transactionIdentifier,
             self.originalTransaction.transactionDate];
    }
    return s;
}
#pragma GCC diagnostic pop

- (NSNumber *)expiration {
    NSDictionary *info = [self purchaseInfo];
    if (info) {
        NSString *s = info[@"expires-date"];
        long long ll = [s longLongValue] / 1000;
        NSNumber *expiration = [NSNumber numberWithLongLong:ll];
        return expiration;
    }
    return [NSNumber numberWithLongLong:0];
}

@end

@interface AppleStoreObserver () <SKProductsRequestDelegate> {
    NSDictionary *_fileThisToAppleProductMap;
}

@property (strong, nonatomic) NSArray *products;
@property (strong, nonatomic) SKProductsRequest *request;
@property (strong, nonatomic) NSDictionary *appleToFileThisProductMap;
@end

@implementation AppleStoreObserver

+(AppleStoreObserver *)sharedObserver {
    static AppleStoreObserver *_sharedObserver;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedObserver = [[AppleStoreObserver alloc] init];
    });
    return _sharedObserver;
}

- (id)init {
    self = [super init];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gotProductIdentifiers:) name:FTGetProductIdentifiers object:nil];
        NSURL *url = [self cachedProductIdentifiersURL:NO];
        if ([[NSFileManager defaultManager] fileExistsAtPath:[url path]]) {
            self.fileThisToAppleProductMap = [NSDictionary dictionaryWithContentsOfURL:url];
        }
    }
    return self;
}

- (NSString *)localizedNameForAppleProductIdentifier:(NSString *)identifier
{
    return self.appleToFileThisProductMap[identifier];
}

- (NSDictionary *)fileThisToAppleProductMap {
    return _fileThisToAppleProductMap;
}

- (void)setFileThisToAppleProductMap:(NSDictionary *)map {
    if (![map isEqualToDictionary:_fileThisToAppleProductMap]) {
        _fileThisToAppleProductMap = map;
        NSArray *objects = [map allValues];
        NSArray *keys = [map allKeys];
        self.appleToFileThisProductMap = [NSDictionary dictionaryWithObjects:keys forKeys:objects];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^() {
            [self requestProducts];
        });
    }
}

- (void)requestProducts {
    NSSet *productIdentifiers = [NSSet setWithArray:[self.fileThisToAppleProductMap allValues]];
    self.request = [[SKProductsRequest alloc] initWithProductIdentifiers:productIdentifiers];
    self.request.delegate = self;
    [self.request start];
}

- (NSURL *)cachedProductIdentifiersURL:(BOOL)create {
    static NSURL *url = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSError *error;
        NSURL *cacheURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:create error:&error];
        if (error)
            NSLog(@"ERROR creating cache directory: %@", error);
        url = [NSURL URLWithString:@"productIdentifiers.plist" relativeToURL:cacheURL];
    });
    return url;
}

- (void)gotProductIdentifiers:(NSNotification *)notification {
    // run on main thread - doesn't work in background
    self.fileThisToAppleProductMap = notification.object;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), ^() {
        // save product identifiers in temporary cache
        [self.fileThisToAppleProductMap writeToURL:[self cachedProductIdentifiersURL:YES] atomically:YES];
    });
}

- (void)login {
    // always request product identifiers - in case they've changed
    [[FTSession sharedSession] getProductIdentifiers];
    // real work happens in gotProductIdentifiers observer
}

- (void)checkDefaultTransactionQueue:(id)unused {
    [self paymentQueue:[SKPaymentQueue defaultQueue] updatedTransactions:[SKPaymentQueue defaultQueue].transactions];
#ifdef DEBUG
    NSTimeInterval oneMinute = 1 * 60;
    [self performSelector:@selector(checkDefaultTransactionQueue:) withObject:nil afterDelay:oneMinute];
#endif
}

// Sent when the transaction array has changed (additions or state changes).
// Client should check state of transactions and finish as appropriate.
- (void)paymentQueue:(SKPaymentQueue *)queue updatedTransactions:(NSArray *)transactions
{
    if (![FTSession sharedSession].validated)
        return;
    
    // resume processing when user logs in.
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"processing %d transactions", transactions.count);
#endif
    for (SKPaymentTransaction *transaction in transactions) {
        switch (transaction.transactionState) {
                // Transaction was restored from user's purchase history.
            case SKPaymentTransactionStateRestored:
#ifdef ENABLE_NSLOG_REQUEST
                NSLog(@"restoring transaction %@", [transaction ftDescription]);
#endif
                [self restoreTransaction:transaction];
                break;
                // Transaction is in queue, user has been charged.
                // Client should complete the transaction.
            case SKPaymentTransactionStatePurchased:
                [self purchasedTransaction:transaction];
                break;
                // Transaction was cancelled or failed before being added to the server queue.
            case SKPaymentTransactionStateFailed:
#ifdef ENABLE_NSLOG_REQUEST
                NSLog(@"failed transaction %@", [transaction ftDescription]);
#endif
                [self failedTransaction:transaction];
                break;
                // Transaction is being added to the server queue.
            case SKPaymentTransactionStatePurchasing:
#ifdef ENABLE_NSLOG_REQUEST
                NSLog(@"purchasing transaction %@", transaction.payment.productIdentifier);
#endif
                break;
        }
    }
}

//#pragma mark - optional methods
//// Sent when transactions are removed from the queue (via finishTransaction:).
//- (void)paymentQueue:(SKPaymentQueue *)queue removedTransactions:(NSArray *)transactions
//{}
//
// Sent when an error is encountered while adding transactions from the user's purchase history back to the queue.
- (void)paymentQueue:(SKPaymentQueue *)queue restoreCompletedTransactionsFailedWithError:(NSError *)error
{
    NSLog(@"error restoring transactions - %@", error);
}


// Sent when all transactions from the user's purchase history have successfully been added back to the queue.
- (void)paymentQueueRestoreCompletedTransactionsFinished:(SKPaymentQueue *)queue
{
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"restored transactions");
#endif
    [self paymentQueue:queue updatedTransactions:queue.transactions];
}

- (void) purchasedTransaction:(SKPaymentTransaction *)transaction
{
    NSLog(@"purchased transaction for %@", [transaction ftDescription]);
    [self recordTransaction:transaction];
}

- (void) restoreTransaction: (SKPaymentTransaction *)transaction
{
    NSLog(@"restored transaction for %@", [transaction ftDescription]);
    [self recordTransaction: transaction];
}

- (void) failedTransaction:(SKPaymentTransaction *)transaction
{
    if (transaction.error.code != SKErrorPaymentCancelled) {
        NSString *s = NSLocalizedString(@"Purchase failed for %@.\n%@.\n%@", @"error message for failed transactions");
        NSString *transactionName = [self localizedNameForTransaction:transaction];
        NSString *m = [NSString stringWithFormat:s,
                       transactionName,
                       transaction.error.localizedDescription,
                       transaction.error.localizedFailureReason ?
                                transaction.error.localizedFailureReason : @""];
        NSLog(s,[self localizedNameForTransaction:transaction],
              transaction.error.localizedDescription,
              transaction.error.localizedFailureReason ?
              transaction.error.localizedFailureReason : @"");
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
        if (transactionName) {
            dispatch_block_t block = ^{
                [[[UIAlertView alloc] initWithTitle:@"FileThis Error" message:m delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            };
            runOnMainQueueWithoutDeadlocking(block);
        }
    } else {
        NSLog(@"User cancelled transaction for %@", [transaction ftDescription]);
        [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
    }
}

- (NSString *)localizedNameForTransaction:(SKPaymentTransaction *)transaction
{
    __block SKProduct *match = nil;
    [self.products enumerateObjectsUsingBlock:^(SKProduct *prod, NSUInteger idx, BOOL *stop) {
        if ([prod.productIdentifier isEqualToString:transaction.payment.productIdentifier]) {
            *stop = YES;
            match = prod;
        }
    }];
    return match.localizedTitle;
}

- (void)recordTransaction:(SKPaymentTransaction *)transaction
{
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"recording %@", [transaction ftDescription]);
#endif
    [[FTSession sharedSession] purchase:transaction
        withSuccess:^(NSString *status) {
            NSString *m = nil;
            NSLog(@"purchase request completed with %@", status);
            if ([status isEqualToString:@"subscription_expired"]) {
                // nothing to do - don't alert user, just finish transaction
            } else if ([status isEqualToString:@"success"]) {
                NSLog(@"recorded %@", [transaction ftDescription]);
                // only alert user on original purchase
                if (transaction.originalTransaction == nil) {
                    NSString *s = NSLocalizedString(@"Thank you for buying the %@.", @"confirmation message for subscription purchase");
                    m = [NSString stringWithFormat:s,
                         [self localizedNameForTransaction:transaction],
                         transaction.transactionIdentifier];
                }
                [[FTSession sharedSession].settings applyPayment:transaction];
            } else {
                NSLog(@"%@ failed recording of %@", status, [transaction ftDescription]);
                NSString *s = NSLocalizedString(@"Your %@ purchase on %@ did not succeed because of %@. Please try again.", @"message for failed purchase");
                m = [NSString stringWithFormat:s,
                     [self localizedNameForTransaction:transaction],
                     transaction.transactionDate, status];
            }

            // Remove the transaction from the payment queue.
            [[SKPaymentQueue defaultQueue] finishTransaction:transaction];
            // update session's settings
            [[FTSession sharedSession] getAccountPreferences:nil];
            
            if (m != nil) {
                dispatch_block_t block = ^{
                    [[[UIAlertView alloc] initWithTitle:@"FileThis Purchase" message:m delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
                };
                runOnMainQueueWithoutDeadlocking(block);
            }
        }
        withFailure:^(NSError *error) {
            NSLog(@"purchase failed %@ because of %@", [transaction ftDescription], error.localizedDescription);
            NSString *m = [NSString stringWithFormat:@"Uh-oh. The purchase did not succeed because of %@. We will try again.", error.localizedDescription];
            dispatch_block_t block = ^{
                [[[UIAlertView alloc] initWithTitle:@"FileThis Purchase" message:m delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            };
            runOnMainQueueWithoutDeadlocking(block);
        }];
}

static int orderingForProductIdentifier(NSString *productIdentifier)
{
    // display premium before ultimate
    if ([productIdentifier rangeOfString:@"ultimate"].length != 0)
        return 10;
    else if ([productIdentifier rangeOfString:@"premium"].length != 0)
        return 5;
    else
        return 0;
}

// Sent immediately before -requestDidFinish:
- (void)productsRequest:(SKProductsRequest *)request didReceiveResponse:(SKProductsResponse *)response
{
    self.products = [response.products sortedArrayUsingComparator:^NSComparisonResult(SKProduct *p1, SKProduct *p2) {
        int t1 = orderingForProductIdentifier(p1.productIdentifier);
        int t2 = orderingForProductIdentifier(p2.productIdentifier);
        if (t1 < t2)
            return NSOrderedAscending;
        else if (t1 > t2)
            return NSOrderedDescending;
        
        return [p1.price compare:p2.price];
    }];

    self.request = nil;

    if (response.invalidProductIdentifiers.count > 0)
        NSLog(@"Invalid product ids: %@", response.invalidProductIdentifiers);
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, kNilOptions);
    dispatch_async(queue, ^{
        [self checkDefaultTransactionQueue:nil];
    });
}

- (void)request:(SKProductsRequest *)request didFailWithError:(NSError *)error {
    // resubmit if we've never loaded product listings before
    self.request = nil;
    if (self.products == nil) {
#ifdef  DEBUG
        NSLog(@"resubmitting AppleStore products request (error=%@)", error);
#endif
        NSTimeInterval oneMinute = 60.0;
        [self performSelector:@selector(requestProducts) withObject:nil afterDelay:oneMinute];
    }
}

@end
