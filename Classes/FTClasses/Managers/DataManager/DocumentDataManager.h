//
//  DataManager.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "BaseDataManager.h"
#import "CabinetObject.h"
#import "DocumentObject.h"
#import "CommonVar.h"
#import "DocumentSearchCriteria.h"

#define NotificationDownloadThumb   @"NotificationDownloadThumb"

@protocol DownloadThumbnailProtocol <NSObject>
@optional
- (void)didDownloadImage:(UIImage*)image forDocument:(DocumentObject*)doc;
@end

@interface DocumentDataManager : BaseDataManager

@property (nonatomic, assign) id<DownloadThumbnailProtocol> delegateDownloadImage;
@property (nonatomic, strong) NSMutableArray *docObjectsNeedToDownloadThumbnail;

+ (DocumentDataManager *)getInstance;
- (NSArray *)getAllDocuments;
- (NSArray *)getDocumentsInCabinate:(NSNumber *)cabId;
- (NSArray *)getDocumentsInProfile:(NSNumber *)profileId;
- (NSArray *)getDocumentSearchCriteria:(DocumentSearchCriteria*)criteria;

- (void)saveCachedData;
- (void)restoreCachedData;

- (NSData *)downloadThumbnailImageForDocument:(DocumentObject *)docObj size:(ThumbnailSize)size;
- (NSData *)downloadDocumentFile:(DocumentObject *)docObj error:(NSError**)error;

- (BOOL)updateDocumentInfo:(DocumentObject *)docObj;

- (BOOL)addTags:(NSMutableArray *)tagIds toDocuments:(NSMutableArray *)docIds;
- (BOOL)removeTags:(NSMutableArray *)tagIds fromDocuments:(NSMutableArray *)docIds;

- (BOOL)deleteDocuments:(NSMutableArray *)documents;

- (BOOL)addCabs:(NSMutableArray *)cabIds toDocuments:(NSMutableArray *)docIds;
- (BOOL)removeCabs:(NSMutableArray *)cabIds fromDocuments:(NSMutableArray *)docIds;

- (void)loadThumbnailForImageView:(UIImageView*)imageView docObj:(DocumentObject*)docObj;
- (id)getDocMailLinks:(DocumentObject *)docObj error:(NSError **)error;
- (id)getMultiDocMailLinks:(NSArray *)arr error:(NSError **)error;

- (void)cancelDownloadingThumbnail;
- (void)downloadThumbnailForDocument:(DocumentObject*)docObj;
- (DocumentObject*)popDocumentToDownloadThumbnail;

@end
