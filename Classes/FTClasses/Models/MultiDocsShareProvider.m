//
//  MultiDocsShareProvider.m
//  FileThis
//
//  Created by Cao Huu Loc on 4/16/14.
//
//

#import "MultiDocsShareProvider.h"

@implementation MultiDocsShareProvider

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController
{
    return [[UIImage alloc] init];
}

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypeMail]) {
        return self.content;
    }
    
    return self.content;
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
    return nil;
}

@end
