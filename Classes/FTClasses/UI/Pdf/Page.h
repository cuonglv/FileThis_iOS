#import <UIKit/UIKit.h>

@protocol PageDelegate <NSObject>

- (void)didPageDoubleTap:(id)sender;

@end

@interface PageContentView : UIView {
}

@end

@interface Page : UIScrollView <UIScrollViewDelegate> {
	NSInteger pageNumber;
	UIView *contentView;
}

- (UIView *)contentView;

@property (nonatomic, retain) UIView *contentView;
@property (nonatomic, assign) NSInteger pageNumber;
@property (nonatomic, assign) id<PageDelegate> pageDelegate;

- (void)refactorZoomScale;
- (BOOL)isValidPage;
@end
