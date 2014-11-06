#import "PageView.h"
#import "PDFPage.h"
#import "PDFDoublePage.h"
#import "PDFThumbPage.h"

@implementation PageView

#pragma mark - View layout

- (id)initWithCoder:(NSCoder *)aDecoder
{
	if ((self = [super initWithCoder:aDecoder]))
	{
        pageViewLayout = PageViewLayoutSinglePage;
		self.delegate = self;
		self.pagingEnabled = YES;
        
        recycledPages = [[NSMutableSet alloc] init];
		visiblePages = [[NSMutableSet alloc] init];
        
        self.backgroundColor = [UIColor whiteColor];
		self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	}
	return self;
}

- (NSInteger)getNumberOfPages {
    return numberOfPages;
}

- (void)clearData {
    pageNumber = 0;
    self.contentOffset = CGPointMake(0, 0);
    
    [arrPages removeAllObjects];
    [visiblePages removeAllObjects];
    [recycledPages removeAllObjects];
}

- (void)reloadData
{
    [arrPages removeAllObjects];
    for (Page *p in visiblePages)
	{
		[p removeFromSuperview];
	}
	[recycledPages unionSet:visiblePages];
	[visiblePages removeAllObjects];
    [self removeAllSubViews];
	[self setNeedsLayout];
}

- (void)reloadDataWithLayout:(PageViewLayout)layout {
    if (self.pageViewLayout != layout) {
        self.pageViewLayout = layout;
        
        [self reloadData];
    }
}

/* True if the page with given index is showing */
- (BOOL)isShowingPageForIndex:(NSInteger)index
{
    for (Page *p in visiblePages)
    {
        if (p.pageNumber == index)
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isShowingDoublePageForIndex:(NSInteger)index
{
    for (PDFDoublePage *p in visiblePages)
    {
        if (p.doublePageIndex == index)
        {
            return YES;
        }
    }
    return NO;
}

- (BOOL)isShowingThumbPageForIndex:(NSInteger)index
{
    for (PDFThumbPage *p in visiblePages)
    {
        if (p.thumbPageIndex == index)
        {
            return YES;
        }
    }
    return NO;
}

- (void)layoutSubviews
{
	numberOfPages = [dataSource numberOfPagesInPageView:self];
    if (self.pageViewLayout == PageViewLayoutSinglePage) {
        [self layoutSinglePage];
    } else if (self.pageViewLayout == PageViewlayoutDoublePage) {
        [self layoutDoublePage];
    } else {
        [self layoutThumbPage];
    }
}

- (void)layoutSinglePage {
    self.contentSize = CGSizeMake(self.frame.size.width * numberOfPages, self.frame.size.height);
    CGRect visibleBounds = self.bounds;
	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
	int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
	firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
	lastNeededPageIndex = MIN(numberOfPages-1, lastNeededPageIndex);
    
    for (Page *aPage in visiblePages)
	{
		if (aPage.pageNumber < firstNeededPageIndex || aPage.pageNumber > lastNeededPageIndex)
		{
			[recycledPages addObject:aPage];
			[aPage removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
    
    for (int i = firstNeededPageIndex; i <= lastNeededPageIndex; i++)
    {
        if ([self isShowingPageForIndex:i]) {
            continue;
        }
        
        Page *aPage = [dataSource pageView:self viewForPage:i];
        CGRect rect = self.frame;
        rect.origin.y = 0;
        rect.origin.x = self.frame.size.width * i;
        rect.size.width = self.frame.size.width;
        rect.size.height = self.frame.size.height;
        aPage.frame = rect;
        
        if (![visiblePages containsObject:aPage]) {
            [visiblePages addObject:aPage];
            [aPage setNeedsDisplay];
        }
        
        if (![arrPages containsObject:aPage]) {
            [arrPages addObject:aPage];
        }
        
        [self addSubview:aPage];
    }
}

- (void)layoutDoublePage {
    int segmentCount = (numberOfPages-1) / 2 + 1;
    if (segmentCount <= 0)
        segmentCount = 1;
    self.contentSize = CGSizeMake(self.frame.size.width * segmentCount, self.frame.size.height);
    
    CGRect visibleBounds = self.bounds;
	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
	int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
	firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
	lastNeededPageIndex = MIN((numberOfPages/2), lastNeededPageIndex);
    
    for (PDFDoublePage *aPage in visiblePages)
	{
		if (aPage.doublePageIndex < firstNeededPageIndex || aPage.doublePageIndex > lastNeededPageIndex)
		{
			[recycledPages addObject:aPage];
			[aPage removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
    
    NSLog(@"visiblePages count = %d", [visiblePages count]);
    NSLog(@"subviews count = %d", [self.subviews count]);

    for (int i = firstNeededPageIndex; i <= lastNeededPageIndex; i++)
    {
        if (![self isShowingDoublePageForIndex:i]) {
            PDFDoublePage *doublePage = nil;
            int count = 0;
            for (int index = i*2;index < i*2 + 2;index++) {
                if (doublePage == nil) {
                    doublePage = [[PDFDoublePage alloc] initWithFrame:CGRectMake(self.frame.size.width * i, 0 , self.frame.size.width, self.frame.size.height)];
                    doublePage.doublePageIndex = i;
                    if (![visiblePages containsObject:doublePage]) {
                        [visiblePages addObject:doublePage];
                        [self addSubview:doublePage];
                    }
                }
                
                Page *aPage = [dataSource pageView:self viewForPage:index];
                if (![aPage isValidPage]) continue;
                
                CGRect rect = self.frame;
                if (count == 0) {
                    rect.origin.x = 0;
                } else {
                    rect.origin.x = (self.frame.size.width)/2;
                }
                
                rect.origin.y = 0;
                rect.size.width = self.frame.size.width/2;
                rect.size.height = self.frame.size.height/2;
                aPage.frame = rect;
                
                [doublePage addSubview:aPage];
                [aPage setNeedsDisplay];
                
                if (![arrPages containsObject:aPage]) {
                    [arrPages addObject:aPage];
                }
                
                count++;
            }
            
            if (doublePage != nil) {
                [doublePage release];
            }
        }
    }
}

- (void)layoutThumbPage {
    int segmentCount = (numberOfPages-1) / 4 + 1;
    if (segmentCount <= 0)
        segmentCount = 1;
    self.contentSize = CGSizeMake(self.frame.size.width * segmentCount, self.frame.size.height);
    
    CGRect visibleBounds = self.bounds;
	int firstNeededPageIndex = floorf(CGRectGetMinX(visibleBounds) / CGRectGetWidth(visibleBounds));
	int lastNeededPageIndex  = floorf((CGRectGetMaxX(visibleBounds)-1) / CGRectGetWidth(visibleBounds));
	firstNeededPageIndex = MAX(firstNeededPageIndex, 0);
	lastNeededPageIndex = MIN(segmentCount, lastNeededPageIndex);
    
    for (PDFThumbPage *aPage in visiblePages)
	{
		if (aPage.thumbPageIndex < firstNeededPageIndex || aPage.thumbPageIndex > lastNeededPageIndex)
		{
			[recycledPages addObject:aPage];
			[aPage removeFromSuperview];
		}
	}
	[visiblePages minusSet:recycledPages];
    
    for (int i = firstNeededPageIndex; i <= lastNeededPageIndex; i++)
    {
        if (![self isShowingThumbPageForIndex:i]) {
            PDFThumbPage *thumbPage = nil;
            int row = 0;
            int col = 0;
            int count = 0;
            for (int index = i*4;index < i*4 + 4;index++) {
                if (thumbPage == nil) {
                    thumbPage = [[PDFThumbPage alloc] initWithFrame:CGRectMake(self.frame.size.width * i, 0 , self.frame.size.width, self.frame.size.height)];
                    thumbPage.thumbPageIndex = i;
                    if (![visiblePages containsObject:thumbPage]) {
                        [visiblePages addObject:thumbPage];
                        [self addSubview:thumbPage];
                    }
                }
                
                Page *aPage = [dataSource pageView:self viewForPage:index];
                if (![aPage isValidPage]) {
                    [aPage setNeedsDisplay];
                    continue;
                }
                
                CGRect rect = self.frame;
                rect.origin.x = (self.frame.size.width)/2 * row;
                rect.origin.y = (self.frame.size.height)/2 * col;
                rect.size.width = self.frame.size.width/2;
                rect.size.height = self.frame.size.height/2;
                aPage.frame = rect;
                
                [thumbPage addSubview:aPage];
                [aPage setNeedsDisplay];
                
                if (![arrPages containsObject:aPage]) {
                    [arrPages addObject:aPage];
                }

                if (count == 0) {
                    col = 1;
                    row = 0;
                } else if (count == 1) {
                    col = 0;
                    row = 1;
                } else if (count == 2) {
                    col = 1;
                    row = 1;
                } else if (count == 3) {
                    col = 0;
                    row = 0;
                }
                
                count++;
            }
            
            [thumbPage release];
        }
    }
}

- (Page *)pageAtIndex:(NSInteger)index
{
	for (Page *p in arrPages)
	{
		if (p.pageNumber == index)
		{
			return p;
		}
	}
	return nil;
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[self setNeedsLayout];
}

/* Animated scrolling did stop */
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView
{
	if ([dataSource respondsToSelector:@selector(pageView:didScrollToPage:)])
	{
		[dataSource pageView:self didScrollToPage:self.page];
	}
}

/* User touch scrolling did stop */
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
	if ([dataSource respondsToSelector:@selector(pageView:didScrollToPage:)])
	{
		[dataSource pageView:self didScrollToPage:self.page];
	}
}


#pragma mark - Page numbers

/* Scrolls to the given page */
- (void)setPage:(NSInteger)aPage animated:(BOOL)animated
{
	CGRect rect = self.frame;
	rect.origin.x = CGRectGetWidth(self.frame) * aPage;
	[self scrollRectToVisible:rect animated:YES];
	if (!animated)
	{
		if ([dataSource respondsToSelector:@selector(pageView:didScrollToPage:)])
		{
			[dataSource pageView:self didScrollToPage:self.page];
		}
	}
}

/* Scrolls to the given page */
- (void)setPage:(NSInteger)aPage
{
	[self setPage:aPage animated:YES];
}

/* Returns the current page number */
- (NSInteger)page
{
	CGFloat minimumVisibleX = CGRectGetMinX(self.bounds);
	return floorf(minimumVisibleX / CGRectGetWidth(self.frame));
}

- (void)setKeyword:(NSString *)str
{
	[keyword release];
	keyword = [str retain];
	for (PDFPage *p in arrPages)
	{
        p.keyword = str;
		[p setNeedsDisplay];
	}
    [self reloadData];
}

#pragma mark - Memory Management

- (void)dealloc
{
	[keyword release];
    [arrPages release];
	[super dealloc];
}

@synthesize page, dataSource, keyword, pageViewLayout;
@end
