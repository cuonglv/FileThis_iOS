//
//  DocumentCabinetListView.h
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "BaseView.h"
#import "DocumentCell.h"
#import "DocumentGroupHeaderView.h"
#import "DocumentCabinetObject.h"
#import "LoadingView.h"
#import "DocumentDataManager.h"
#import "EGORefreshTableHeaderView.h"

@interface DocumentCabinetListView : BaseView<UITableViewDataSource, UITableViewDelegate, DocumentGroupHeaderViewDelegate, DocumentCellDelegate, TagListViewDelegate, DownloadThumbnailProtocol>

@property (nonatomic, strong) UITableView *tbDocumentCabinet;
@property (nonatomic, strong) NSMutableArray *arrDocumentCabinets;
@property (nonatomic, strong) NSMutableArray *selectedSections;
@property (nonatomic, strong) NSMutableDictionary *selectedIndexes;
@property (nonatomic, strong) NSMutableDictionary *selectedCells;
@property (nonatomic, strong) NSMutableDictionary *documentCabinetHeaders;
@property (nonatomic, strong) LoadingView *loadingView;

@property (nonatomic, strong) EGORefreshTableHeaderView *headerViewRefresh;
@property (nonatomic, assign) BOOL loadingData;

@property (nonatomic, strong) NSIndexPath *pathDocumentInfoViewed;

@property (nonatomic, assign) id<DocumentCellDelegate> delegateCell;

- (NSIndexPath *)indexPathOfDocument:(DocumentObject *)document;
- (void)loadData;
- (void)loadDocumentsInCab;
- (void)addDocumentCabinetAndSort:(DocumentCabinetObject *)documentCab;
- (void)sortDocumentCabinetList;
@end
