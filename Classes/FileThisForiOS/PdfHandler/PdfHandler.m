//
//  PdfHandler.m
//  OnMat
//
//  Created by Cuong Le Viet on 8/14/13.
//
//

#import "PdfHandler.h"

@implementation PdfHandler

+ (void)editPDF:(NSString*)filePath templateFilePath:(NSString*)templatePath drawImage:(UIImage*)image atPage:(int)pageNumber inFrame:(CGRect)frame {
    // Create the PDF context using the default page size of 612 x 792.
    UIGraphicsBeginPDFContextToFile(filePath, CGRectZero, nil);
    // Mark the beginning of a new page.
    //UIGraphicsBeginPDFPageWithInfo(CGRectMake(0, 0, 612, 792), nil);
    
    //open template file
    CFURLRef url = CFURLCreateWithFileSystemPath (NULL, (CFStringRef)templatePath, kCFURLPOSIXPathStyle, 0);
    CGPDFDocumentRef templateDocument = CGPDFDocumentCreateWithURL(url);
    CFRelease(url);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    //get bounds of template page
    int numberOfPages = CGPDFDocumentGetNumberOfPages(templateDocument);
    //int y = 0;
    for (int i = 1; i <= numberOfPages; i++) {
        //CGRect rect = CGRectMake(0, y, 612, 792);
        //CGContextBeginPage(context,&rect);
        //UIGraphicsBeginPDFPageWithInfo(rect, nil);
        UIGraphicsBeginPDFPage();
        
        CGPDFPageRef templatePage = CGPDFDocumentGetPage(templateDocument, i);
        CGRect templatePageBounds = CGPDFPageGetBoxRect(templatePage, kCGPDFCropBox);
        
        //flip context due to different origins
        CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        //copy content of template page on the corresponding page in new file
        CGContextDrawPDFPage(context, templatePage);
        
        //flip context back
        CGContextTranslateCTM(context, 0.0, templatePageBounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        
        if (i == pageNumber) {  //Edit body
            //adjust the frame to aspect-fit the image
            if (frame.size.width / frame.size.height > image.size.width / image.size.height) {
                float newFrameWidth = image.size.width / image.size.height * frame.size.height;
                frame = CGRectMake(frame.origin.x + frame.size.width/2 - newFrameWidth/2, frame.origin.y, newFrameWidth, frame.size.height);
            } else {
                float newFrameHeight = image.size.height / image.size.width * frame.size.width;
                frame = CGRectMake(frame.origin.x, frame.origin.y + frame.size.height/2 - newFrameHeight/2, frame.size.width, newFrameHeight);
            }
            [image drawInRect:frame];
        }
        
        //CGContextEndPage(context);
        //y += 800;
        //CGContextdrawp(context);
    }

    CGPDFDocumentRelease(templateDocument);
    
    //Close the PDF context and write the contents out.
    UIGraphicsEndPDFContext();
}
@end
