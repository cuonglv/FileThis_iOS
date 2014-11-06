//
//  DataManager.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "DocumentDataManager.h"
#import "DocumentService.h"
#import "CabinetObject.h"
#import "DocumentObject.h"
#import "CommonLayout.h"
#import "ThreadManager.h"
#import "CommonDataManager.h"
#import "CacheManager.h"
#import "UIImage+Resize.h"
#import "CommonFunc.h"
#import "DownloadPhotoThread.h"

#define DOWNLOAD_THUMB_QUEUE_SIZE       30
#define MAX_THREADS_DOWNLOAD_THUMB      5

@interface BaseDataManager ()
@property (nonatomic, strong) NSMutableArray *allObjects;
@property (nonatomic, strong) NSMutableDictionary *findObjectByIdDictionary;
@end

@interface DocumentDataManager()
@property (nonatomic, assign) ThreadObj *threadObjForDownloadingThumbnail;
//@property (nonatomic, retain) DownloadPhotoThread *downloadThumbThread;
@property (nonatomic, retain) NSMutableArray *arrDownloadThumbThreads;

@property long long incrementalTimestamp;

@end

@implementation DocumentDataManager
static DocumentDataManager *instance = nil;

- (id)init {
    if (self = [super init]) {
        self.docObjectsNeedToDownloadThumbnail = [[NSMutableArray alloc] init];
        self.arrDownloadThumbThreads = [[NSMutableArray alloc] initWithCapacity:MAX_THREADS_DOWNLOAD_THUMB];
    }
    return self;
}

+ (DocumentDataManager *)getInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[DocumentDataManager alloc] init];
        }
    }
    
    return instance;
}

- (NSArray *)getAllDocuments {
    if (self.allObjects != nil) {
        return [NSArray arrayWithArray:self.allObjects];
    }
    [self reloadAll];
    
    return [NSArray arrayWithArray:self.allObjects];
}

- (int)getNum {
    return 0;
}

- (void)reloadAll {
    @synchronized(self) {
        BOOL isIncrementalReturn = NO;
        DocumentService *service = [[DocumentService alloc] initWithAction:kActionGetAllDocuments];
        if (self.incrementalTimestamp > 0) {
            service.incrementalTimestamp = self.incrementalTimestamp;
            if (self.allObjects.count > 0) {
                isIncrementalReturn = YES;
                
                NSMutableString *ids = [[NSMutableString alloc] init];
                DocumentObject *documentObj = [self.allObjects objectAtIndex:0];
                [ids appendString:[documentObj.id description]];
                for (int i = 1; i < self.allObjects.count; i++) {
                    DocumentObject *obj = [self.allObjects objectAtIndex:i];
                    [ids appendFormat:@",%@", [obj.id description]];
                }
                service.oldListIDs = ids;
            } else {
                service.oldListIDs = nil;
            }
        }
        
        NSError *error;
        //NSLog(@"CHL - Start get documents");
        NSDictionary *dataResponse = [service sendRequestToServer:&error];
        //NSLog(@"CHL - End get documents");
        if (dataResponse) {
            //Parse list
            if (!isIncrementalReturn) { //Parse full list
                self.allObjects = [self parseDataToObjects:dataResponse];
            } else { //Parse incremental list
                [self parseUpdatedData:dataResponse];
            }
            
            //Store incremental timestamp
            if ([dataResponse isKindOfClass:[NSDictionary class]]) {
                self.incrementalTimestamp = [[[dataResponse valueForKey:@"timestamp"] description] longLongValue];
            }
            
            [self updateFindObjectByIdDictionary];
            
            //Save data to local
            [[DocumentDataManager getInstance] saveCachedData];
            
            [self.docObjectsNeedToDownloadThumbnail removeAllObjects];
        } else {
            /*dispatch_async(dispatch_get_main_queue(), ^{
             [CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_CANNOT_LOAD_DOCUMENT_LIST", @"") errorMessage:[error localizedDescription] delegate:nil];
             });*/
        }
    }
}

- (NSArray *)getDocumentsInCabinate:(NSNumber *)cabId {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionGetAllDocumentsInCab];
    service.cabId = cabId;
    
    id dataResponse = [service sendRequestToServer];
    if (dataResponse) {
        NSMutableArray *results = [self parseDataToObjects:dataResponse];
        return [NSArray arrayWithArray:results];
    }
    return nil;
}

- (NSArray *)getDocumentsInProfile:(NSNumber *)profileId {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionGetAllDocumentsInProfile];
    service.profileId = profileId;
    
    id dataResponse = [service sendRequestToServer];
    if (dataResponse) {
        NSMutableArray *results = [self parseDataToObjects:dataResponse];
        return [NSArray arrayWithArray:results];
    }
    
    return nil;
}

- (NSArray *)getDocumentSearchCriteria:(DocumentSearchCriteria*)criteria {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionSearchDocuments];
    service.documentSearchCriteria = criteria;
    
    id dataResponse = [service sendRequestToServer];
    if (dataResponse) {
        NSMutableArray *results = [self parseDataToObjects:dataResponse];
        return [NSArray arrayWithArray:results];
    }
    return nil;
}

- (BOOL)updateDocumentInfo:(DocumentObject *)docObj {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionUpdateDocumentInfo];
    service.docObj = docObj;
    [service sendRequestToServerShouldShowAlert:YES];
    
    return (service.responseStatusCode == 200);
}

- (BOOL)addTags:(NSMutableArray *)tagIds toDocuments:(NSMutableArray *)docIds {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionAddTagsToDocuments];
    service.docIds = docIds;
    service.tagIds = tagIds;
    [service sendRequestToServer];
    return (service.responseStatusCode == 200);
}

- (BOOL)removeTags:(NSMutableArray *)tagIds fromDocuments:(NSMutableArray *)docIds {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionRemoveTagsFromDocuments];
    service.docIds = docIds;
    service.tagIds = tagIds;
    [service sendRequestToServer];
    return (service.responseStatusCode == 200);
}

- (BOOL)addCabs:(NSMutableArray *)cabIds toDocuments:(NSMutableArray *)docIds {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionAddCabsToDocuments];
    service.docIds = docIds;
    service.cabIds = cabIds;
    [service sendRequestToServer];
    return (service.responseStatusCode == 200);
}

- (BOOL)removeCabs:(NSMutableArray *)cabIds fromDocuments:(NSMutableArray *)docIds {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionRemoveCabsFromDocuments];
    service.docIds = docIds;
    service.cabIds = cabIds;
    [service sendRequestToServer];
    return (service.responseStatusCode == 200);
}

- (BOOL)deleteDocuments:(NSMutableArray *)documents {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionDeleteDocuments];
    service.docIds = [documents valueForKeyPath:@"id"];
    [service sendRequestToServerShouldShowAlert:YES];
    return (service.responseStatusCode == 200);
}

- (NSMutableArray *)parseDataToObjects:(id)dict {
    NSMutableArray *results = [[NSMutableArray alloc] init];
    if ([dict isKindOfClass:[NSDictionary class]]) {
        id documents = [dict objectForKey:@"documents"];
        if (documents != nil && [documents isKindOfClass:[NSArray class]]) {
            for (id document in documents) {
                DocumentObject *documentObj = [[DocumentObject alloc] initWithDictionary:document];
                //[manhnn - 630]: Process non-PDF file types
                //if ([[documentObj.kind lowercaseString] isEqualToString:[kPDF lowercaseString]]) {
                    [results addObject:documentObj];
                //}
            }
        }
    }
    
    return results;
}

- (void)clearAll {
    [super clearAll];
    self.incrementalTimestamp = 0;
    
    [self saveCachedData];
}

#pragma mark - Serialize
- (void)saveCachedData {
    @autoreleasepool {
        NSMutableArray *arr = [[NSMutableArray alloc] init];
        for (DocumentObject *doc in [self getAllObjects]) {
            NSDictionary *dic = [doc toDictionary];
            if (dic.allKeys.count > 0) {
                [arr addObject:dic];
            }
        }
        
        if (arr.count > 0) {
            NSString *path = [CommonFunc getFilePathInDocumentDir:@"documents.plist"];
            NSDictionary *plist = [NSDictionary dictionaryWithObjectsAndKeys:arr, @"documents", [NSNumber numberWithLongLong:self.incrementalTimestamp], @"incrementalTimestamp", nil];
            [plist writeToFile:path atomically:YES];
        }
    }
}

- (void)restoreCachedData {
    @synchronized(self) {
        @autoreleasepool {
            self.allObjects = [[NSMutableArray alloc] init];
            NSString *path = [CommonFunc getFilePathInDocumentDir:@"documents.plist"];
            NSDictionary *plist = [NSDictionary dictionaryWithContentsOfFile:path];
            if (plist) {
                NSArray *arr = [plist valueForKey:@"documents"];
                if ([arr isKindOfClass:[NSArray class]]) {
                    for (NSDictionary *dic in arr) {
                        DocumentObject *obj = [[DocumentObject alloc] initWithDictionary:dic];
                        [self.allObjects addObject:obj];
                    }
                }
                NSString *timestamp = [[plist valueForKey:@"incrementalTimestamp"] description];
                self.incrementalTimestamp = [timestamp longLongValue];
            }
            [self updateFindObjectByIdDictionary];
        }
    }
}

#pragma mark - Incremental update methods
- (void)parseUpdatedData:(id)dict {
    if ([dict isKindOfClass:[NSDictionary class]]) {
        //Updated or added documents
        id documents = [dict objectForKey:@"documents"];
        if (documents != nil && [documents isKindOfClass:[NSArray class]]) {
            for (id document in documents) {
                DocumentObject *documentObj = [[DocumentObject alloc] initWithDictionary:document];
                [self replaceOrAddDocument:documentObj];
            }
        }
        
        //Removed documents
        id removedDocs = [dict objectForKey:@"removed"];
        if (removedDocs != nil && [removedDocs isKindOfClass:[NSArray class]]) {
            for (id numID in removedDocs) {
                long long num = [[numID description] longLongValue];
                DocumentObject *documentObj = [[DocumentObject alloc] init];
                documentObj.id = [NSNumber numberWithLongLong:num];
                [self removeDocumentFromList:documentObj];
            }
        }
    }
}

//Replace if docID already exists in list
//Add new if there is not docID in list
- (void)replaceOrAddDocument:(DocumentObject*)doc {
    @synchronized(self) {
        //Find document by ID in current list
        int index = -1;
        DocumentObject *objFound = [self getObjectByKey:doc.id];
        if (objFound) {
            for (int i = 0; i < self.allObjects.count; i++) {
                DocumentObject *obj = [self.allObjects objectAtIndex:i];
                if ([obj.id isEqualToNumber:doc.id]) {
                    index = i;
                    break;
                }
            }
        }
        
        //Replace of add document to list
        if (index >= 0) { //Replace
            [self.allObjects replaceObjectAtIndex:index withObject:doc];
        } else { //Add
            [self.allObjects addObject:doc];
        }
    }
}

//Remove object from current list
- (void)removeDocumentFromList:(DocumentObject*)doc {
    @synchronized(self) {
        for (int i = 0; i < self.allObjects.count; i++) {
            DocumentObject *obj = [self.allObjects objectAtIndex:i];
            if ([obj.id isEqualToNumber:doc.id]) {
                [self.allObjects removeObjectAtIndex:i];
                break;
            }
        }
    }
}

#pragma mark - Thumbnail download (Loc Cao)
//+++Loc Cao
- (int)indexOfThumbInWaitingList:(DocumentObject*)docObj {
    int ret = -1;
    long num = [docObj.id longValue];
    //NSArray *arr = [[NSArray alloc] initWithArray:self.docObjectsNeedToDownloadThumbnail];
    NSArray *arr = self.docObjectsNeedToDownloadThumbnail;
    for (int i = 0; i < arr.count; i++) {
        DocumentObject *obj = [arr objectAtIndex:i];
        long numCompare = [obj.id longValue];
        if (numCompare == num) {
            ret = i;
            break;
        }
    }
    return ret;
}

- (void)cancelDownloadingThumbnail {
    [self.docObjectsNeedToDownloadThumbnail removeAllObjects];
    
    for (DownloadPhotoThread *thread in self.arrDownloadThumbThreads) {
        [thread cancelDownload];
    }
    [self.arrDownloadThumbThreads removeAllObjects];
}

- (void)downloadThumbnailForDocument:(DocumentObject*)docObj {
    //Check condition to ignore this thumbnail
    if ([[CommonDataManager getInstance] isDocumentThumbDataAvailable:docObj])
        return;
    
    //Remove last item in queue if it is too long
    if (self.docObjectsNeedToDownloadThumbnail.count > DOWNLOAD_THUMB_QUEUE_SIZE) {
        [self.docObjectsNeedToDownloadThumbnail removeLastObject];
    }
    
    //Add to waiting list at first position
    int index = -1;
    @synchronized (self) {
        index = [self indexOfThumbInWaitingList:docObj];
        if (index != -1) {
            [self.docObjectsNeedToDownloadThumbnail removeObjectAtIndex:index];
        }
    }
    [self.docObjectsNeedToDownloadThumbnail insertObject:docObj atIndex:0];
    
    //Create thread to download
    if (self.arrDownloadThumbThreads.count < MAX_THREADS_DOWNLOAD_THUMB) {
        DownloadPhotoThread *thread = [[DownloadPhotoThread alloc] init];
        [thread start];
        [self.arrDownloadThumbThreads addObject:thread];
    } else {
        //Find index of finished thread
        index = -1;
        for (int i = 0; i < self.arrDownloadThumbThreads.count; i++) {
            DownloadPhotoThread *thread = [self.arrDownloadThumbThreads objectAtIndex:i];
            if ([thread isFinished]) {
                index = i;
                break;
            }
        }
        
        //Replace old finished thread with new thread
        if (index != -1) {
            DownloadPhotoThread *thread = [[DownloadPhotoThread alloc] init];
            [thread start];
            [self.arrDownloadThumbThreads replaceObjectAtIndex:index withObject:thread];
        }
    }
}

- (DocumentObject*)popDocumentToDownloadThumbnail {
    DocumentObject *ret = nil;
    @synchronized(self) {
        if (self.docObjectsNeedToDownloadThumbnail.count > 0) {
            ret = [self.docObjectsNeedToDownloadThumbnail firstObject];
            [self.docObjectsNeedToDownloadThumbnail removeObjectAtIndex:0];
        }
    }
    return ret;
}
//---

#pragma mark - Thumbnail image
- (NSData *)downloadThumbnailImageForDocument:(DocumentObject *)docObj size:(ThumbnailSize)size {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionGetDocumentThumbnail isDictionaryResponse:NO];
    service.docObj = docObj;
    service.documentThumbSize = size;
    id dataResponse = [service sendRequestToServer];
    return dataResponse;
}

- (NSData *)downloadDocumentFile:(DocumentObject *)docObj error:(NSError**)error {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionGetDocumentFile isDictionaryResponse:NO];
    service.docObj = docObj;
    service.timeoutInterval = 300.0;
    id dataResponse = [service sendRequestToServer:error];
    return dataResponse;
}

- (void)loadThumbnailForImageView:(UIImageView*)imageView docObj:(DocumentObject*)docObj {
    if ([[CommonDataManager getInstance] isDocumentThumbDataAvailable:docObj]) {
        [docObj.docThumbImage setToImageView:(UIImageView*)imageView];
    } else {
        @synchronized(self) {
            if ([self.docObjectsNeedToDownloadThumbnail count] > 30) {
                DocumentObject *lastDocObj = [self.docObjectsNeedToDownloadThumbnail lastObject];
                lastDocObj.imageViewNeedToLoadThumbnail = nil;
                [self.docObjectsNeedToDownloadThumbnail removeLastObject];
            }
            
            if ([self.docObjectsNeedToDownloadThumbnail containsObject:docObj]) {
                [self.docObjectsNeedToDownloadThumbnail removeObject:docObj];
            }
            [self.docObjectsNeedToDownloadThumbnail insertObject:docObj atIndex:0];
            docObj.imageViewNeedToLoadThumbnail = imageView;
            
            if ([self.docObjectsNeedToDownloadThumbnail count] == 1) {
                [[ThreadManager getInstance] dispatchToLowThreadWithTarget:self selector:@selector(executeDownloadThumbnail:threadObj:) argument:@""];
            }
        }
    }
}

- (void)executeDownloadThumbnail:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if (![threadObj isCancelled]) {
        if ([self.docObjectsNeedToDownloadThumbnail count] > 0) {
            DocumentObject *docObj = [self.docObjectsNeedToDownloadThumbnail objectAtIndex:0];
            if (![[CommonDataManager getInstance] isDocumentThumbDataAvailable:docObj]) {
                id imageData = [[DocumentDataManager getInstance] downloadThumbnailImageForDocument:docObj size:ThumbnailSizeMedium];
                if (![threadObj isCancelled]) {
                    UIImage *image = nil;
                    if (imageData)
                        image = [UIImage imageWithData:imageData];
                    
                    if (image) {
                        docObj.docThumbImage = image;
                        [[CacheManager getInstance] setDocumentThumbnailCache:docObj size:ThumbnailSizeMedium];
                        if (docObj.imageViewNeedToLoadThumbnail) {
                            dispatch_async(dispatch_get_main_queue(), ^(void) {
                                //[image setToImageView:docObj.imageViewNeedToLoadThumbnail];
                                if ([self.delegateDownloadImage respondsToSelector:@selector(didDownloadImage:forDocument:)]) {
                                    [self.delegateDownloadImage didDownloadImage:image forDocument:docObj];
                                }
                                //---
                            });
                        }
                    }
                }
            }
            [self.docObjectsNeedToDownloadThumbnail removeObject:docObj];
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [[ThreadManager getInstance] dispatchToLowThreadWithTarget:self selector:@selector(executeDownloadThumbnail:threadObj:) argument:@""];
            });
        }
    }
    [threadObj releaseOperation];
}

#pragma mark - Share links
- (id)getDocMailLinks:(DocumentObject *)docObj error:(NSError **)error {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionGetDocMailLinks];
    service.documentId = docObj.id;
    id response = [service sendRequestToServer];
    NSLog(@"%@", response);
    return response;
}

- (id)getMultiDocMailLinks:(NSArray *)arr error:(NSError **)error {
    DocumentService *service = [[DocumentService alloc] initWithAction:kActionGetMultiDocMailLinks];
    service.docIds = arr;
    id response = [service sendRequestToServerShouldShowAlert:YES];
    NSLog(@"%@", response);
    return response;
}


@end
