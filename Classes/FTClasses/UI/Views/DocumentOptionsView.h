//
//  DocumentOptionsView.h
//  FileThis
//
//  Created by Manh nguyen on 1/10/14.
//
//

#import "BaseView.h"
#import "SortCriteriaObject.h"

@protocol DocumentOptionsViewDelegate <NSObject>

- (void)didSelectThumbsLayout:(id)sender;
- (void)didSelectSnippetsLayout:(id)sender;
- (void)didSelectSortBy:(SORTBY)sortBy;

@end

@interface DocumentOptionsView : BaseView<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tbView;
@property (nonatomic, strong) NSMutableArray *sortCriterias;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, assign) BOOL isShowThumbs;
@property (nonatomic, assign) SORTBY selectedSortBy;
@property (nonatomic, assign) id<DocumentOptionsViewDelegate> delegate;

@end
