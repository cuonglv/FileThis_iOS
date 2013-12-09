//
//  FTRequest.h
//  FileThis
//
//  Created by Drew Wilson on 9/24/12.
//
//

#import <Foundation/Foundation.h>

@interface FTRequest : NSObject<NSURLConnectionDataDelegate> {
}

@property (strong) NSMutableData   *data;
@property (strong) NSURLConnection *connection;
@property (strong) NSString *operand;
@property (strong) NSMutableURLRequest *request;
@property (strong) NSDictionary *responseHeaderFields;
@property (nonatomic, readonly) NSInteger failureCode;
@property (strong, readonly) id json;
@property (strong, readonly) NSString *text;
@property (strong) NSString *errorText;
@property (strong) NSString *errorMessage;
@property (strong) NSString *errorType;
@property NSInteger statusCode;
@property (readonly) BOOL success;

- (id)initWithTicket:(NSString *)ticket withVerb:(NSString *)verb withKeyValues:(NSDictionary *)params;

- (id)initWithTicket:(NSString *)ticket withVerb:(NSString *)verb withParameters:(NSString *)parameters withPostData:(NSData *)optionalPostData;
//- (id)initWithVerb:(NSString *)verb withParameters:(NSString *)parameters withPostData:(NSData *)postData;
- (id)initWithTicket:(NSString *)ticket withVerb:(NSString *)verb withParameters:(NSString *)parameters;
- (id)initForImageNamed:(NSString *)imageFileName;
- (id)initWithURL:(NSURL *)url;  // designated initializer
- (id)initWithRequest:(NSURLRequest *)request;

- (void)setReceiver:(id) receiver withAction:(SEL)action;

- (void)start;
- (void)close;
- (void)cancel;

- (void)displayAlertIfError;

@end

