//
//  DocumentProfileListView.h
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "BaseView.h"
#import "DocumentCell.h"
#import "DocumentGroupHeaderView.h"
#import "DocumentProfileObject.h"
#import "LoadingView.h"
#import "DocumentDataManager.h"
#import "EGORefreshTableHeaderView.h"

@interface DocumentProfileListView : BaseView<UITableViewDataSource, UITableViewDelegate, DocumentGroupHeaderViewDelegate, DocumentCellDelegate, TagListViewDelegate, DownloadThumbnailProtocol>

@property (nonatomic, strong) UITableView *tbDocumentProfile;
@property (nonatomic, strong) NSMutableArray *arrDocumentProfiles;
@property (nonatomic, strong) NSMutableArray *selectedSections;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexes;
@property (nonatomic, strong) NSMutableDictionary *selectedCells;
@property (nonatomic, strong) LoadingView *loadingView;

@property (nonatomic, strong) EGORefreshTableHeaderView *headerViewRefresh;
@property (nonatomic, assign) BOOL loadingData;

@property (nonatomic, strong) NSIndexPath *pathDocumentInfoViewed;

@property (nonatomic, assign) id<DocumentCellDelegate> delegateCell;

- (NSIndexPath *)indexPathOfDocument:(DocumentObject *)document;
- (void)loadData;
- (void)loadDocumentsInProfile;

@end
