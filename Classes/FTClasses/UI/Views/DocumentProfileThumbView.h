//
//  DocumentProfileThumbView.h
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
#import "DocumentDataManager.h"
#import "EGORefreshTableHeaderView.h"

@interface DocumentProfileThumbView : BaseView<UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UICollectionViewDataSource, DocumentGroupHeaderViewDelegate, DocumentGroupCollectionHeaderViewDelegate, DownloadThumbnailProtocol>

@property (nonatomic, strong) UICollectionView *collectDocumentProfile;
@property (nonatomic, strong) NSMutableArray *arrDocumentProfiles;
@property (nonatomic, strong) NSMutableArray *selectedSections;
@property (nonatomic, strong) LoadingView *loadingView;
@property (nonatomic, strong) NSMutableDictionary *documentProfileHeaders;
@property (nonatomic, assign) BOOL showSectionHeaders, showAll;

@property (nonatomic, strong) EGORefreshTableHeaderView *headerViewRefresh;
@property (nonatomic, assign) BOOL loadingData;

- (id)initWithFrame:(CGRect)frame showSectionHeaders:(BOOL)showed showAllDocs:(BOOL)showAllDocs;
- (void)loadData;
- (void)loadDocumentsInProfile;

@end
