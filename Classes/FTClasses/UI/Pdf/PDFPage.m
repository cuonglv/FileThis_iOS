#import "PDFPage.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

#define PADDING 20

@implementation PDFContentView

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.backgroundColor = [UIColor whiteColor];
        CATiledLayer *tiledLayer = (CATiledLayer *) [self layer];
		tiledLayer.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
		[tiledLayer setTileSize:CGSizeMake(1024, 1024)];
		[tiledLayer setLevelsOfDetail:4];
		[tiledLayer setLevelsOfDetailBias:4];
    }
    return self;
}

+ (Class)layerClass
{
	return [CATiledLayer class];
}

- (void)setKeyword:(NSString *)str
{
	[keyword release];
	keyword = [str retain];
	self.selections = nil;
}

- (NSArray *)selections
{
	@synchronized (self)
	{
		if (!selections)
		{
			self.selections = [self.scanner select:self.keyword];
		}
		return selections;
	}
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
//    NSLog(@"layer.bounds size = %lf %lf", layer.bounds.size.width, layer.bounds.size.height);
	CGContextSetFillColorWithColor(ctx, [[UIColor whiteColor] CGColor]);
	CGContextFillRect(ctx, layer.bounds);
	
    // Flip the coordinate system
	CGContextTranslateCTM(ctx, 0.0, layer.bounds.size.height);
	CGContextScaleCTM(ctx, 1.0, -1.0);

	// Transform coordinate system to match PDF
	NSInteger rotationAngle = CGPDFPageGetRotationAngle(pdfPage);
	CGAffineTransform transform = CGPDFPageGetDrawingTransform(pdfPage, kCGPDFCropBox, layer.bounds, -rotationAngle, YES);
	CGContextConcatCTM(ctx, transform);

	CGContextDrawPDFPage(ctx, pdfPage);
	
	if (self.keyword && self.selections)
    {
        CGContextSetFillColorWithColor(ctx, [[UIColor yellowColor] CGColor]);
        CGContextSetBlendMode(ctx, kCGBlendModeMultiply);
        for (Selection *s in self.selections)
        {
            CGContextSaveGState(ctx);
            CGContextConcatCTM(ctx, s.transform);
            CGContextFillRect(ctx, s.frame);
            CGContextRestoreGState(ctx);
        }
    }
}

- (CGPDFPageRef)getPage {
    return pdfPage;
}

#pragma mark PDF drawing

/* Draw the PDFPage to the content view */
- (void)drawRect:(CGRect)rect
{
	CGContextRef ctx = UIGraphicsGetCurrentContext();
	
	CGContextSetFillColorWithColor(ctx, [[UIColor redColor] CGColor]);
	CGContextFillRect(ctx, rect);
}

/* Sets the current PDFPage object */
- (void)setPage:(CGPDFPageRef)page
{
    CGPDFPageRelease(pdfPage);
	pdfPage = CGPDFPageRetain(page);
	self.scanner = [Scanner scannerWithPage:pdfPage];
}

- (void)dealloc
{
	[scanner release];
    CGPDFPageRelease(pdfPage);
    [super dealloc];
}

@synthesize keyword, selections, scanner;
@end

#pragma mark -

@implementation PDFPage

#pragma mark -

- (void)setNeedsDisplay
{
	[super setNeedsDisplay];
	[contentView setNeedsDisplay];
}

/* Override implementation to return a PDFContentView */ 
- (UIView *)contentView
{
	if (!contentView)
	{
		contentView = [[PDFContentView alloc] initWithFrame:CGRectZero];
	}
	return contentView;
}

- (void)setPage:(CGPDFPageRef)page layout:(int)layout
{
    [(PDFContentView *)self.contentView setPage:page];
    
    // Also set the frame of the content view according to the page size
    CGRect rect;
    int padding = PADDING;
    self.layout = layout;
    if (self.layout == 0) padding = 0;
    
    rect.origin.x = padding;
    rect.origin.y = padding;
    rect.size.width = self.frame.size.width - padding*2;
    rect.size.height = self.frame.size.height - padding*3;
    
    self.contentView.frame = rect;
}

- (void)refactorZoomScale {
    if (self.layout == 0) {
        [self setZoomScale:1.0];
    }
}

- (BOOL)isValidPage {
    CGPDFPageRef pageRef = [(PDFContentView *)self.contentView getPage];
    if (pageRef != nil) return YES;
    return NO;
}

- (void)setKeyword:(NSString *)string
{
    ((PDFContentView *)contentView).keyword = string;
}

- (NSString *)keyword
{
    return ((PDFContentView *)contentView).keyword;
}

@end
