//
//  FTRequest.m
//  FileThis
//
//  Created by Drew Wilson on 9/24/12.
//
//

#import "FTRequest.h"
#import "FTSession.h"
#import "UIKitExtensions.h"

@interface FTRequest() {
    id _receiver;
	SEL _action;
}
@property (strong) NSArray *acceptableContentTypes;
@property BOOL retry;

@end

@implementation FTRequest

// ref: http://madebymany.com/blog/url-encoding-an-nsstring-on-ios
-(NSString *)newUrlString:(NSString *)string {
    NSStringEncoding encoding = NSUTF8StringEncoding;
	return (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                        NULL, (CFStringRef)string, NULL,
                        (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ",
                        CFStringConvertNSStringEncodingToEncoding(encoding)));
}

- (id)initWithTicket:(NSString *)ticket withVerb:(NSString *)verb withKeyValues:(NSDictionary *)keyValues {
    NSMutableArray *paramsArray = [[NSMutableArray alloc] initWithCapacity:[keyValues count]];
    
    [keyValues enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop)
    {
        NSString *urlEncodedString = [self newUrlString:obj];
        NSString *entry = [[NSString alloc] initWithFormat:@"%@=%@",key, urlEncodedString];
        [paramsArray addObject:entry];
    }];
    
    NSString *params = [paramsArray componentsJoinedByString:@"&"];
    return [self initWithTicket:ticket withVerb:verb withParameters:params];
}

- (id)initWithTicket:(NSString *)ticket withVerb:(NSString *)verb withParameters:(NSString *)parameters withPostData:(NSData *)optionalPostData {
    if (self = [super init]) {
        self.operand = verb;
        if (!(self = [self initRequest:verb withTicket:ticket withParameters:parameters withPostData:optionalPostData])) return nil;
    }
    return self;
}

- (id)initWithTicket:(NSString *)ticket withVerb:(NSString *)verb withParameters:(NSString *)parameters withPostKeyValues:(NSDictionary *)optionalDictionary {
    if (self = [super init]) {
        self.operand = verb;
        NSData *postData = nil;
        if (optionalDictionary) {
            NSAssert1([NSJSONSerialization isValidJSONObject:optionalDictionary], @"optional dictionary is valid JSON: %@", optionalDictionary);
            NSError *error;
            postData = [NSJSONSerialization dataWithJSONObject:optionalDictionary options:kNilOptions error:&error];
            NSLog(@"Answered question with %@", [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);
        }
        if (!(self = [self initRequest:verb withTicket:ticket withParameters:parameters withPostData:postData])) return nil;
    }
    return self;
}


- (id)initWithTicket:(NSString *)ticket withVerb:(NSString *)verb withParameters:(NSString *)parameters {
    if (self = [super init]) {
        if (!(self = [self initWithTicket:ticket withVerb:verb withParameters:parameters withPostData:nil])) return nil;
    }
    return self;
    
}

- (id)initWithURL:(NSURL *)url {
    NSURLRequest *r = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10 /* seconds */];
    if ((self = [self initWithRequest:r])) {
    }
    return self;
}

// designated initializer
- (id)initWithRequest:(NSURLRequest *)request {
    if ((self = [super init])) {
        _request = [request mutableCopy];
    }
    return self;
}

/*
    GET request for a static image file
 e.g. http://integration.filethis.com/static/logos/Logo_AmericanExpress.png
*/
- (id)initForImageNamed:(NSString *)imageFileName {
    NSURL *url = [[NSURL alloc] initWithString:imageFileName relativeToURL:[FTSession imagesURL]];
    NSURLRequest *r = [[NSURLRequest alloc] initWithURL:url cachePolicy:NSURLRequestReturnCacheDataElseLoad timeoutInterval:10 /* seconds */];
    if ((self = [self initWithRequest:r])) {
        _acceptableContentTypes = @[ @"image/png" ];
        self.operand = imageFileName;
    }

    return self;
}

-(id)initRequest:(NSString *)verb withTicket:(NSString *)ticket withParameters:(NSString *)parameters withPostData:(NSData *)optionalPostData {
    NSString *uriFormat = @"?op=%@&ticket=%@&json=true&compact=true&flex=true";
    NSString *uri = [NSString stringWithFormat:uriFormat, verb, ticket];
    if (parameters) {
        uri = [uri stringByAppendingString:@"&"];
        uri = [uri stringByAppendingString:parameters];
    }
    NSURL *url = [[NSURL alloc] initWithString:uri relativeToURL:[FTSession restURL]];
    if ((self = [self initWithURL:url])) {
        // add headers application/json
        [_request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        if (optionalPostData != nil) {
            NSLog(@"Posting JSON: %@", [[NSString alloc] initWithData:optionalPostData encoding:NSUTF8StringEncoding]);
            [self.request setHTTPMethod:@"POST"];
            [self.request setHTTPBody:optionalPostData];
            [self.request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
            [self.request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
//            NSString *contentLengthString = [NSString stringWithFormat:@"%d", [optionalPostData length]];
//            [self.request setValue:contentLengthString forHTTPHeaderField:@"Content-Length"];
        }
    }
    
    return self;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@: %@; %@", [super description], self.operand, self.request];
}

- (void)setReceiver:(id) receiver withAction:(SEL)action {
    _receiver = receiver;
    _action = action;
}

- (void) start {
    NSLog(@"sending request for %@", self.operand);
    _connection = [[NSURLConnection alloc] initWithRequest:self.request delegate:self startImmediately:NO];
	[self.connection start];
}

//
// close
//
// Cancel the connection and release all connection data. Does not release
// the result if already generated (this is only released when the class is
// released).
//
// Will send the response if the receiver is non-nil. But always releases the
// receiver when done.
//
- (void)close
{
    NSLog(@"closing request for %@", self.operand);

	[self.connection cancel];
	self.connection = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    dispatch_queue_priority_t priority = 0;
    dispatch_async(dispatch_get_global_queue(priority, 0),
                   ^(void) {
                       [_receiver performSelector:_action withObject:self];
                       _receiver = nil;
                       self.data = nil;
                   });
//	[_receiver performSelector:_action withObject:self];
#pragma clang diagnostic pop
}

//
// cancel
//
// Sets the receiver to nil (so it won't receive a response and then closes the
// connection and frees all data.
//
- (void)cancel
{
	_receiver = nil;
	[self close];
}

- (BOOL)success {
    return self.statusCode == 200;
}

#pragma mark NSURLConnectionDataDelegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)moData {
    [self.data appendData:moData];
}

// display error message received from server
- (void)displayAlertIfError
{
    NSString *errorMessage;
    if (self.statusCode != 200) {
        if (self.statusCode == 404) {
            errorMessage = [NSString stringWithFormat:@"Not found: %@", self.operand];
        } else {
            errorMessage = self.text;
        }
        NSLog(@"Status=%d and response is %@", self.statusCode, errorMessage);
        // TODO: parse error message from html tags
        /*
         2012-12-14 14:04:02.537 FileThis[20017:907] Status=503 and response is Server returned an HTTP error 503 because <html><body><h1>503 Service Unavailable</h1>
         No server is available to handle this request.
         </body></html>
*/
        
    } else {
        errorMessage = [self.json objectForKey:@"errorMessage"];
    }

    if (errorMessage != nil) {
        dispatch_block_t block = ^{
            [[[UIAlertView alloc] initWithTitle:@"FileThis" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        };
        runOnMainQueueWithoutDeadlocking(block);
    }
}

//
// connection:didReceiveResponse:
//
// When a start-of-message is received from the server, set the data to zero.
//
- (void)connection:(NSURLConnection *)aConnection didReceiveResponse:(NSHTTPURLResponse *)aResponse
{
	self.responseHeaderFields = [aResponse allHeaderFields];
    _statusCode = [aResponse statusCode];
    
	if (self.statusCode >= 400)
	{
		_failureCode = [aResponse statusCode];
		
		NSString *errorMessage;
		if (_failureCode == 404)
		{
			errorMessage =
            NSLocalizedStringFromTable(@"Requested file not found or couldn't be opened.", @"HTTPFetcher", @"Error given when a file cannot be opened or played.");
		}
		else if (_failureCode == 403)
		{
			errorMessage =
            NSLocalizedStringFromTable(@"The server did not have permission to open the file..", @"HTTPFetcher", @"Error given when a file permissions problem prevents you opening or playing a file.");
		}
		else if (_failureCode == 415)
		{
			errorMessage =
            NSLocalizedStringFromTable(@"The requested file couldn't be converted for streaming.", @"HTTPFetcher", @"Error given when a file can't be streamed.");
		}
		else if (_failureCode == 500)
		{
			errorMessage =
            NSLocalizedStringFromTable(@"An internal server error occurred when requesting the file.", @"HTTPFetcher", @"Error given when an unknown problem occurs on the server.");
		}
		else
		{
			errorMessage = [NSString stringWithFormat:
                            NSLocalizedStringFromTable(@"Server returned an HTTP error %ld.", @"HTTPFetcher", @"Error given when an unknown communication problem occurs. Placeholder is replaced with the error number."),
                            _failureCode];
		}
        NSLog(@"%@", errorMessage);
	}
	
	//
	// Handle the content-length if present by preallocating.
	//
    self.data = nil;
	NSInteger contentLength = [_responseHeaderFields[@"Content-Length"] integerValue];
	if (contentLength > 0)
	{
		_data = [[NSMutableData alloc] initWithCapacity:contentLength];
	}
	else
	{
		_data = [[NSMutableData alloc] init];
	}
}

/*
 
 Sample error message: com.filethis.common.exception.ConnectionExistsException:A connection to this institution with the given user name already exists. */
- (NSString *)parseErrorText:(NSString *)errorString {
    static NSRegularExpression *regex = nil;
    if (regex == nil) {
        NSError *error = NULL;
        NSString *pattern = @".*Exception:(.*)";
        regex = [[NSRegularExpression alloc] initWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
        NSAssert2(regex != nil, @"regex generation failed for %@ with error %@", pattern, error);
    }

    NSString *match = nil;
    NSRange range = NSMakeRange(0, [errorString length]);
    if ([regex numberOfMatchesInString:errorString options:kNilOptions range:range] == 0) {
        NSLog(@"no match...");
        match = errorString;
    } else {
        NSTextCheckingResult *result = [regex firstMatchInString:errorString options:kNilOptions range:range];
        match = [errorString substringWithRange:[result rangeAtIndex:1]];
    }
    
    return match;
}

- (NSString *)stringFromHtml:(NSString *)htmlString {
    UIWebView *webview = [[UIWebView alloc] init];
    [webview loadHTMLString:htmlString baseURL:nil];
    return [webview stringByEvaluatingJavaScriptFromString:@"document.documentElement.innerText;"];
}

- (BOOL)string:(NSString*)string matchesRegEx:(NSString *)regex {
    NSError *error = NULL;
    NSRegularExpression *re =
        [NSRegularExpression regularExpressionWithPattern:regex
            options:NSRegularExpressionCaseInsensitive error:&error];

    NSUInteger numberOfMatches = [re numberOfMatchesInString:string
                                                        options:0
                                                          range:NSMakeRange(0, [string length])];
    return numberOfMatches != 0;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    NSLog(@"%d status - request finished loading %@", self.statusCode, self);
    
    // parse NSData response to objects or text
    NSError *error = nil;
    @autoreleasepool {
        NSString *responseContentType = (self.responseHeaderFields)[@"Content-Type"];
        if ([responseContentType isEqualToString:@"text/plain"]) {
            _text = [[NSString alloc] initWithData:self.data encoding:NSASCIIStringEncoding];
            NSLog(@"text response=%@", self.text);
            self.errorText = [self parseErrorText:self.text];
        } else if ([responseContentType isEqualToString:@"application/json"]) {
            _json = [NSJSONSerialization JSONObjectWithData:self.data options:NSJSONReadingAllowFragments error:&error];
//            NSLog(@"json response=%@", self.json);
            if (self.json == nil) {
                NSString *dataString = [[NSString alloc] initWithData:self.data encoding:NSASCIIStringEncoding];
                NSLog(@"%@ parsing JSON string:%@", error, dataString);
            }
            NSAssert1(self.json != nil, @"no json response for request %@", self);
            self.errorMessage = self.json[@"errorMessage"];
            self.errorType = self.json[@"errorType"];
            if (self.errorType) {
                NSString *msg = [NSString stringWithFormat:@"ERROR(%@) %@ - %@", self.operand,
                                 self.errorMessage, self.errorType];
                NSLog(@"%@", msg);
                self.errorText = msg;
                NSAssert1(msg, @"%@", msg);
            }
        } else if ([responseContentType rangeOfString:@"text/html"].location != NSNotFound) {
            _text = [[NSString alloc] initWithData:self.data encoding:NSASCIIStringEncoding];
            NSLog(@"html response=%@", _text);
//        _text = [self stringFromHtml:self.text];
//        NSLog(@"text response=%@", self.text);
        } else if (![self.acceptableContentTypes containsObject:responseContentType] && responseContentType != nil) {
            NSAssert1(NO, @"unknown content type: %@", responseContentType);
        }
    }

    if (self.statusCode != 200) {
        NSString *errorMessage = [NSString stringWithFormat: @"Server returned an HTTP error %d because %@", self.statusCode, self.text];

        NSLog(@"Status=%d and response is %@", self.statusCode, errorMessage);
        [self displayAlertIfError];
    }

    [self close];
}


/*

 Apple guide is very specific about releasing connection object: it's done in didFailWithError and connectionDidFinishLoading.

 http://developer.apple.com/library/mac/#documentation/Cocoa/Conceptual/URLLoadingSystem/Tasks/UsingNSURLConnection.html#//apple_ref/doc/uid/20001836-BAJEAIEE

*/
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	if ([[error domain] isEqual:NSURLErrorDomain])
	{
		_failureCode = [error code];
	}
    
    // TODO: create retry object to retry this request...
    NSString *message =
        [NSString stringWithFormat: @"%@ failed because %@ (status code=%d).",
         self.operand, error.localizedDescription, self.statusCode];
    NSLog(@"ERROR: %@", message);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"FileThis"
        message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    
    [self close];
}

// ref: <http://stackoverflow.com/questions/933331/how-to-use-nsurlconnection-to-connect-with-ssl-for-an-untrusted-cert>
- (BOOL)connection:(NSURLConnection *)connection canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace {
    return [protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust])
        //        if ([trustedHosts containsObject:challenge.protectionSpace.host])
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

- (NSCachedURLResponse *)connection:(NSURLConnection *)connection willCacheResponse:(NSCachedURLResponse *)cachedResponse {
    NSLog(@"willCacheResponse: %@ from connection %@", cachedResponse, connection);
    return cachedResponse;
}

@end
