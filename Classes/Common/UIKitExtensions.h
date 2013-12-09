//
//  UIKitExtensions.h
//  FileThis
//
//  Created by Drew Wilson on 1/6/13.
//
//

#import <UIKit/UIKit.h>
#import <StoreKit/StoreKit.h>

@interface UITableView (FileThisExtensions)

- (UIView *)makeFooterViewForButton:(UIButton *)button;
- (CGFloat)heightForButton;
- (CGFloat)cellsMargin;
@end

@interface UIButton (FileThisExtensions)
+ (UIButton *)makeButtonWithTitle:(NSString *)title withTarget:(id)target action:(SEL)action;
@end


@interface NSString (FileThisExtensions)
- (BOOL)isValidEmail;
- (BOOL)isValidPassword;
- (NSString *)stringByAddingPercentEscapes;
@end

@interface NSDictionary (FileThisExtensions)
- (NSMutableDictionary *)deepCopyMutableDictionary;
- (NSDictionary *)deepCopyDictionary;
@end

@interface SKProduct (LocalizedPrice)

@property (nonatomic, readonly) NSString *localizedPrice;

@end

@interface UIImageView (FileThisExtensions)

- (void)setImageWithURL:(NSURL *)url
       placeholderImage:(UIImage *)placeholderImage
                 cached:(BOOL)useCached;

@end

@interface NSURLCache (FileThisExtensions)

- (UIImage *)cachedImageForURL:(NSURL *)url;

@end

@interface NSError (FileThisExtensions)

- (NSString *)fileThisUserMessage;

@end

@interface UIAlertView (FileThisExtensions)

- (void)okAlertThreadAwareWithTitle:(NSString *)title withMessage:(NSString *)message;

@end

// utility function to run block on main thread
void runOnMainQueueWithoutDeadlocking(dispatch_block_t block);
