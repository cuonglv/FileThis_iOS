//
//  UIImage+Ext.m
//  FileThis
//
//  Created by Cuong Le on 1/24/14.
//
//

#import "UIImage+Ext.h"

@implementation UIImage(Ext)

- (UIImage*)resizedImageAroundFileLength:(long)aroundFileLength {
    NSData *data = UIImageJPEGRepresentation(self, 1.0);
    long dataLength = [data length];
    NSLog(@"--Image file length: %ld",dataLength);
    float ratio = 2 * aroundFileLength / (float)dataLength;
    if (ratio < 1) {
        data = UIImageJPEGRepresentation(self, ratio);
        
//        dataLength = [data length];
//        if (dataLength < aroundFileLength) {
//            if (ratio < 0.5)
//                data = UIImageJPEGRepresentation(self, ratio * 2);    //double ratio
//        }
    }
    NSLog(@"      Image file length after resize: %ld",dataLength);
    return [UIImage imageWithData:data];
}

@end
