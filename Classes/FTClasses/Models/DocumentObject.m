//
//  Document.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "DocumentObject.h"
#import "CommonDataManager.h"
#import "CacheManager.h"
#import "DocumentDataManager.h"
#import "ThreadManager.h"
#import "UIImage+Resize.h"

@implementation DocumentObject

- (id)initWithDictionary:(NSDictionary *)dict {
    self = [super initWithDictionary:dict];
    if (self) {
        self.cabs = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"cabs"]];
        self.tags = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"tags"]];
        self.profiles = [[NSMutableArray alloc] initWithArray:[dict objectForKey:@"profiles"]];
    }
    
    return self;
}

#pragma mark - UIActivityItemSource
- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    //Because the URL is already set it can be the placeholder. The API will use this to determine that an object of class type NSURL will be sent.
    return self.docURL;
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType
{
    //Return the URL being used. This URL has a custom scheme (see ReadMe.txt and Info.plist for more information about registering a custom URL scheme).
    return self.docURL;
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size
{
    return self.docThumbImage;
}

- (BOOL)matchesTagIds:(NSArray*)tagIds {
    for (NSNumber *tagId in tagIds) {
        if (![self.tags containsObject:tagId])
            return NO;
    }
    return YES;
}

#pragma mark - Serialize
- (NSDictionary*)toDictionary {
    NSArray *propNames = [[NSArray alloc] initWithObjects:@"added", @"cabs", @"created", @"delivered", @"deliveryState", @"destinationId", @"filename", @"docname", @"id", @"kind", @"mimeType", @"modified", @"origRelevantDate", @"pages", @"path", @"profiles", @"relevantDate", @"size", @"tags", nil];
    NSMutableDictionary *dic = [[NSMutableDictionary alloc] init];
    
    for (NSString *key in propNames) {
        id value = [self valueForKey:key];
        [dic setValue:value forKey:key];
    }
    
    return [NSDictionary dictionaryWithDictionary:dic];
}

#pragma mark - Public
- (void)updateProperties:(NSArray*)properties fromObject:(DocumentObject*)obj {
    for (NSString *key in properties) {
        NSObject *value = [obj valueForKey:key];
        if (value) {
            [self setValue:value forKey:key];
        }
    }
}

@end
