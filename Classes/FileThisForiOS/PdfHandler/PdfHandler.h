//
//  PdfHandler.h
//  OnMat
//
//  Created by Cuong Le Viet on 8/14/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreText/CoreText.h>

@interface PdfHandler : NSObject

+ (void)editPDF:(NSString*)filePath templateFilePath:(NSString*)templatePath drawImage:(UIImage*)image atPage:(int)pageNumber inFrame:(CGRect)frame;
@end
