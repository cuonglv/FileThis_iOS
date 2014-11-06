//
//  DocumentPreviewLayoutViewOption.h
//  FileThis
//
//  Created by Manh nguyen on 1/16/14.
//
//

#import "BaseView.h"
#import "PageView.h"

@protocol DocumentPreviewLayoutViewOptionDelegate <NSObject>

- (void)didSelectPageLayout:(id)sender pageViewLayout:(PageViewLayout)pageViewLayout;

@end

@interface DocumentPreviewLayoutViewOption : BaseView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tbView;
@property (nonatomic, strong) NSMutableArray *layouts;
@property (nonatomic, assign) id<DocumentPreviewLayoutViewOptionDelegate> delegate;
@property (nonatomic, assign) PageViewLayout selectedLayout;

@end
