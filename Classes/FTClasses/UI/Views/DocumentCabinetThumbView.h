//
//  DocumentCabinetThumbView.h
//  FileThis
//
//  Created by Manh nguyen on 1/10/14.
//
//

#import "BaseView.h"
#import "LoadingView.h"
#import "DocumentCabinetObject.h"
#import "DocumentGroupHeaderView.h"
#import "DocumentThumbCell.h"
#import "DocumentGroupCollectionHeaderView.h"
#import "DocumentGroupCollectionEditView.h"
#import "DocumentDataManager.h"
#import "EGORefreshTableHeaderView.h"

@protocol DocumentCabinetThumbViewDelegate <NSObject>

- (void)didSelectButton:(id)sender;
- (void)didCancelButton:(id)sender;
- (void)didSelectAllButton:(id)sender;
- (void)didSelectDocument:(id)sender documentId:(id)documentId;
- (void)didDeSelectDocument:(id)sender documentId:(id)documentId;

@end

@interface DocumentCabinetThumbView : BaseView<UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, DocumentGroupHeaderViewDelegate, DocumentGroupCollectionHeaderViewDelegate, DocumentGroupCollectionEditViewDelegate, DownloadThumbnailProtocol>

@property (nonatomic, strong) UICollectionView *collectDocumentCabinet;
@property (nonatomic, strong) NSMutableArray *arrDocumentCabinets;
@property (nonatomic, strong) NSMutableArray *selectedSections;
@property (nonatomic, strong) NSMutableArray *selectedDocuments;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) NSMutableDictionary *documentCabinetHeaders;
@property (nonatomic, assign) BOOL showSectionHeaders, showAll, isEditingMode;
@property (nonatomic, assign) id<DocumentCabinetThumbViewDelegate> delegate;
@property (nonatomic, assign) DocumentGroupCollectionEditView *groupCollectionEditView;

@property (nonatomic, strong) EGORefreshTableHeaderView *headerViewRefresh;
@property (nonatomic, assign) BOOL loadingData;

- (id)initWithFrame:(CGRect)frame showSectionHeaders:(BOOL)showed showAllDocs:(BOOL)showAllDocs canReload:(BOOL)canReload;
- (void)addHeaderPullToRefresh;
- (void)loadData;
- (void)loadDocumentsInCab;
- (void)setSelectDocument:(id)documentId;
- (void)setDeSelectDocument:(id)documentId;
- (void)removeDocument:(NSMutableArray *)documents;

@end
