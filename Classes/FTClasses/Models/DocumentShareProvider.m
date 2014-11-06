//
//  DocumentShareProvider.m
//  FileThis
//
//  Created by Manh nguyen on 1/6/14.
//
//

#import "DocumentShareProvider.h"
#import "CacheManager.h"

@implementation DocumentShareProvider

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return [[UIImage alloc] init];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return self.documentObj.shareContent;
    }
    
    NSString *filePath = [[CacheManager getInstance] getDocumentDataCacheFor:self.documentObj];
    return [NSData dataWithContentsOfFile:filePath];
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return NSLocalizedString(@"ID_DOCUMENT_SHARE_SUBJECT", @"");
    }
    return @"";
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size
{
    //The filtered image is the image to display on the other side.
    return self.documentObj.docThumbImage;
}

@end
