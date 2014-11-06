#import <UIKit/UIKit.h>
#import "Page.h"

@class PageView;

typedef enum PageViewLayout {
    PageViewLayoutSinglePage,
    PageViewlayoutDoublePage,
    PageViewLayoutThumbPage
} PageViewLayout;

@protocol PageViewDelegate <NSObject>

#pragma mark - Required

/* Asks the delegate how many pages are in the document */
- (NSInteger)numberOfPagesInPageView:(PageView *)pageView;

/* Asks the delegate for a page view object */
- (Page *)pageView:(PageView *)pageView viewForPage:(NSInteger)page;

#pragma mark Optional

@optional

/* Tells the delegate when the document stopped scrolling at a page */
- (void)pageView:(PageView *)pageView didScrollToPage:(NSInteger)pageNumber;

/* Asks the delegate for a keyword */
- (NSString *)keywordForPageView:(PageView *)pageView;

@end

#pragma mark

@interface PageView : UIScrollView <UIScrollViewDelegate> {
	NSInteger numberOfPages;
	NSInteger pageNumber;
	NSMutableArray *arrPages;
    NSMutableSet *visiblePages;
	NSMutableSet *recycledPages;
	NSString *keyword;
	IBOutlet id<PageViewDelegate> dataSource;
    PageViewLayout pageViewLayout;
}

#pragma mark -

- (NSInteger)getNumberOfPages;

/* Causes the page view to reload pages */
- (void)clearData;
- (void)reloadData;
- (void)reloadDataWithLayout:(PageViewLayout)layout;
- (void)layoutSinglePage;
- (void)layoutDoublePage;
- (void)layoutThumbPage;

/* Scroll to a specific page */
- (void)setPage:(NSInteger)aPage animated:(BOOL)animated;

/* Page at the given index */
- (Page *)pageAtIndex:(NSInteger)index;

@property (nonatomic, assign) PageViewLayout pageViewLayout;

/* The page currently visible */
@property (nonatomic, assign) NSInteger page;

/* Data source for pages */
@property (nonatomic, assign) id<PageViewDelegate> dataSource;

@property (nonatomic, retain) NSString *keyword;

@end
