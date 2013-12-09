//
//  UIKitExtensions.m
//  FileThis
//
//  Created by Drew Wilson on 1/6/13.
//
//

#import "UIKitExtensions.h"
#import "UIImageView+AFNetworking.h"

@implementation UITableView (FileThisExtensions)

// custom view for footer. will be adjusted to default or specified footer height
- (UIView *)makeFooterViewForButton:(UIButton *)button
{
    UITableView *tableView = self;    
    CGFloat horizontalMargin = [self cellsMargin];
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, horizontalMargin, 0, horizontalMargin);
    
    CGRect frame = CGRectMake(0, 0, tableView.frame.size.width,
                              tableView.rowHeight + edgeInsets.top + edgeInsets.bottom );
    NSLog(@"tableView's cell frame=%@", NSStringFromCGRect(frame));
    
    UIView *view = [[UIView alloc] initWithFrame:frame];
    view.autoresizingMask |= UIViewAutoresizingFlexibleWidth;
    view.autoresizesSubviews = YES;
    //        view.backgroundColor = [UIColor redColor];
    
    BOOL iPad = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad;
    
    button.autoresizingMask = iPad ?
            UIViewAutoresizingFlexibleLeftMargin + UIViewAutoresizingFlexibleRightMargin :
                UIViewAutoresizingFlexibleWidth;
    
    frame.origin.y += edgeInsets.top;
    frame.size.height = tableView.rowHeight;
    if (iPad) {
        // hard-code button width on iPad
        frame.size.width = 300;
//        CGFloat margin = tableView.frame.size.width - frame.size.width;
        frame.origin.x = (tableView.frame.size.width - frame.size.width) / 2;
    } else {
        frame.origin.x += edgeInsets.left;
        frame.size.width -= (edgeInsets.left + edgeInsets.right);
    }
    
    button.frame = frame;
    // do button set up here, including sizing and centering, and add to footer view
    [view addSubview:button];
    return view;
}

#define BUTTON_VERTICAL_INSET 2.0
- (CGFloat)heightForButton
{
    return self.rowHeight + BUTTON_VERTICAL_INSET * 2;
}

// This is black magic from
// http://stackoverflow.com/questions/4708085/how-to-determine-margin-of-a-grouped-uitableview-or-better-how-to-set-it
- (CGFloat)cellsMargin {
    
    // No margins for plain table views
    if (self.style == UITableViewStylePlain) {
        return 0;
    }
    
    // iPhone always have 10 pixels margin
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return 10;
    }
    
    CGFloat tableWidth = self.frame.size.width;
    
    // Really small table
    if (tableWidth <= 20) {
        return tableWidth - 10;
    }
    
    // Average table size
    if (tableWidth < 400) {
        return 10;
    }
    
    // Big tables have complex margin's logic
    // Around 6% of table width,
    // 31 <= tableWidth * 0.06 <= 45
    
    CGFloat marginWidth  = tableWidth * 0.06;
    marginWidth = MAX(31, MIN(45, marginWidth));
    return marginWidth;
}

@end


@implementation UIButton (FileThisExtensions)

+ (UIButton *)makeButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [button setTitle:title forState:UIControlStateNormal];
    [button addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    return button;
}

@end


@implementation NSString (FileThisExtensions)

- (BOOL)isValidEmail
{
    return YES; // TODO:
}

- (BOOL)isValidPassword
{
    return YES; // TODO!
}

- (NSString *)stringByAddingPercentEscapes {
    CFStringEncoding encoding = kCFStringEncodingUTF8;
    return (__bridge_transfer NSString *) CFURLCreateStringByAddingPercentEscapes(NULL, (CFStringRef)self, NULL,
 (CFStringRef)@"!*'\"();:@&=+$,/?%#[]% ", encoding);
}

@end



@implementation NSDictionary (FileThisExtensionss)

- (NSMutableDictionary *)deepCopyMutableDictionary {
    NSMutableDictionary *mutableCopy =
    (__bridge_transfer NSMutableDictionary *)
    CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                 (CFPropertyListRef) self, kCFPropertyListMutableContainersAndLeaves);
    NSAssert1(mutableCopy != NULL, @"cannot deep copy dictionary: %@", self);
    return mutableCopy;
}

- (NSDictionary *)deepCopyDictionary {
    NSDictionary *copy =
    (__bridge_transfer NSDictionary *)
    CFPropertyListCreateDeepCopy(kCFAllocatorDefault,
                                 (CFPropertyListRef) self, kCFPropertyListImmutable);
    NSAssert1(copy != NULL, @"cannot deep copy dictionary: %@", self);
    return copy;
}

@end


@implementation SKProduct (LocalizedPrice)

- (NSString *)localizedPrice
{
    NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
    [numberFormatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
    [numberFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [numberFormatter setLocale:self.priceLocale];
    NSString *formattedString = [numberFormatter stringFromNumber:self.price];
    return formattedString;
}

@end

@implementation NSURLCache (FileThisExtensions)

- (UIImage *)cachedImageForURL:(NSURL *)url {
    NSURLRequest *request = [[NSURLRequest alloc] initWithURL:url];
    NSCachedURLResponse *response = [self cachedResponseForRequest:request];
    if (response && response.data)
        return [UIImage imageWithData:response.data];
    return nil;
}

@end

@implementation UIImageView (FileThisExtensions)

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                 cached:(BOOL)useCached
{
    UIImage *imageToUse = placeholderImage;
    UIImage *cachedImage = [[NSURLCache sharedURLCache] cachedImageForURL:url];
    if (cachedImage) {
        imageToUse = cachedImage;
    } else {
        NSLog(@"image not in cache for %@", [url resourceSpecifier]);
    }
    [self setImageWithURL:url placeholderImage:imageToUse];
}

@end


@implementation NSError (FileThisExtensions)

- (BOOL)isHTMLMessage:(NSString *)message
{
    NSRange r = [message rangeOfString:@"<html><body>"];
    return (r.length != 0);
}

- (NSString *)stripHTMLFromMessage:(NSString *)message
{
    NSRange r = [message rangeOfString:@"<html><body><h1>503 Service Unavailable</h1>"];
    if (r.length != NSNotFound)
        return NSLocalizedString(@"No server is available to handle this request.", @"No server is available to handle this request.");
    
    // TODO: implement strip html from message
    return message;
}

- (NSString *)fileThisUserMessage {
    static const int NS_ERROR_USER_CANCELLED = -999;
    if (self.code == NS_ERROR_USER_CANCELLED)
        return nil;
    
    NSString *message = self.localizedRecoverySuggestion;
    if ([self isHTMLMessage:message])
        message = [self stripHTMLFromMessage:message];
    if (!message)
        message = self.localizedDescription;
    if (self.userInfo[@"NSDebugDescription"])
        message = [message stringByAppendingFormat:@"\n%@", self.userInfo[@"NSDebugDescription"]];
    NSLog(@"FileThis error message '%@' for error (%@)", message, self);
    
    return message;
}

@end

@implementation UIAlertView (FileThisExtensions)

-(void)okAlertThreadAwareWithTitle:(NSString *)title withMessage:(NSString *)message {
    NSAssert(NO, @"to do");
}

@end

void runOnMainQueueWithoutDeadlocking(dispatch_block_t block) {
    if ([NSThread isMainThread])
    {
        block();
    }
    else
    {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

