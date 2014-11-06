//
//  DocumentShareProvider.h
//  FileThis
//
//  Created by Manh nguyen on 1/6/14.
//
//

#import <UIKit/UIKit.h>
#import "DocumentObject.h"

@interface DocumentShareProvider : UIActivityItemProvider

@property (nonatomic, strong) DocumentObject *documentObj;
@property (nonatomic, strong) NSString *subject, *content;

@end