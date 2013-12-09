//
//  FTDestination.h
//  FileThis
//
//  Created by Drew Wilson on 12/29/12.
//
//

#import <Foundation/Foundation.h>

@interface FTDestination : NSObject

- (id)initWithDictionary:(NSDictionary *)json;

@property (readonly) NSString *name;
@property (readonly) NSURL *url;
@property (readonly) NSString *logoName;
@property (readonly) NSURL *logoUrl;
@property (readonly) NSInteger destinationId;

+ (FTDestination *)destinationWithId:(NSInteger)destinationId;
- (void)configureForTextLabel:(UILabel *)textLabel withImageView:imageView;
- (void)configureForImageView:(UIImageView *)imageView;
+ (UIImage *)placeholderImage;

@end

//
//https://staging.filethis.com/ftapi/ftapi?op=destinationlist&json=true&compact=true&
//
//ticket=T5P3wklJy3X8feeq6Jn4JGnqSfv	200	GET	staging.filethis.com	/ftapi/ftapi?op=destinationlist&flex=true&json=true&compact=true&ticket=T5P3wklJy3X8feeq6Jn4JGnqSfv	 2046 ms	2.06 KB	Complete
//
