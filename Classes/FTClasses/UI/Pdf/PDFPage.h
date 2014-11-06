#import "Page.h"
#import "Scanner.h"


@interface PDFContentView : PageContentView {
	CGPDFPageRef pdfPage;
    NSString *keyword;
	NSArray *selections;
	Scanner *scanner;
}

#pragma mark

- (void)setPage:(CGPDFPageRef)page;

@property (nonatomic, retain) Scanner *scanner;
@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, copy) NSArray *selections;

- (CGPDFPageRef)getPage;

@end

#pragma mark

@interface PDFPage : Page {
}

#pragma mark

- (void)setPage:(CGPDFPageRef)page layout:(int)layout;

@property (nonatomic, copy) NSString *keyword;
@property (nonatomic, assign) int layout;

@end
