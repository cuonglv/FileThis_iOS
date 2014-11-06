//
//  CommonDataManager.m
//  FileThis
//
//  Created by Manh nguyen on 12/23/13.
//
//

#import "CommonDataManager.h"
#import "ThreadManager.h"
#import "TagDataManager.h"
#import "CabinetDataManager.h"
#import "EventManager.h"
#import "DocumentDataManager.h"
#import "CacheManager.h"
#import "ProfileDataManager.h"
#import "DocumentCabinetObject.h"
#import "DocumentProfileObject.h"
#import "CommonFunc.h"
#import "LoadingView.h"

@interface CommonDataManager ()
@property (nonatomic, strong) NSMutableDictionary *dictCommonDataThreads;
@property (nonatomic, strong) NSMutableDictionary *dictThumbThreads;
@property (nonatomic, strong) NSMutableDictionary *dictDocumentFileThreads;

@property (nonatomic, strong) NSMutableArray *allDocumentCabinets;
@property (nonatomic, strong) NSMutableArray *allDocumentProfiles;
@property dispatch_semaphore_t semaphore;
@end

@implementation CommonDataManager

static CommonDataManager *instance = nil;

+ (CommonDataManager *)getInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[CommonDataManager alloc] init];
        }
    }
    
    return instance;
}

- (id)init {
    self = [super init];
    if (self) {
        self.dictCommonDataThreads = [[NSMutableDictionary alloc] init];
        self.dictDocumentFileThreads = [[NSMutableDictionary alloc] init];
        self.dictThumbThreads = [[NSMutableDictionary alloc] init];
    }
    
    return self;
}

#pragma mark - Common Data
- (id<ThreadProtocol>)loadCommonData {
    // Load all cabinets
    return [self loadCommonDataWithKey:DATA_COMMON_KEY];
}

- (id<ThreadProtocol>)loadCommonDataWithKey:(NSString *)dataKey {
    id<ThreadProtocol> thread = [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(loadCommonDataThread:threadObj:) argument:dataKey];
    
    @synchronized(self) {
        [self.dictCommonDataThreads setObject:thread forKey:dataKey];
    }
    return thread;
}

- (id<ThreadProtocol>)reloadCommonDataWithKey:(NSString *)dataKey {
    id<ThreadProtocol> threadRunning = [self getCommonThreadRunning:dataKey];
    if (threadRunning)
        if ([threadRunning isExecuting])
            return threadRunning;
    
    if ([self isCommonDataAvailableWithKey:dataKey]) {
        [self postEventLoadCommonDataWithKey:dataKey];
        return nil;
    }
    
    return [self loadCommonDataWithKey:dataKey];
}

- (void)postEventLoadCommonDataWithKey:(NSString *)dataKey {
    Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_LOAD_COMMON_DATA];
    [event setContent:dataKey];
    [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
}

- (void)loadCommonDataThread:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if (![threadObj isCancelled]) {
        NSString *dataType = dummy;
        if ([dataType isEqualToString:DATA_COMMON_KEY]) {
//            [[TagDataManager getInstance] reloadAll];
//            [[CabinetDataManager getInstance] reloadAll];
//            [[ProfileDataManager getInstance] reloadAll];
//            [[DocumentDataManager getInstance] reloadAll];
            
            //Create semaphore
            self.semaphore = dispatch_semaphore_create(0);
            
            //Create 4 child threads
            [NSThread detachNewThreadSelector:@selector(reloadAllTags) toTarget:self withObject:nil];
            [NSThread detachNewThreadSelector:@selector(reloadAllCabinets) toTarget:self withObject:nil];
            [NSThread detachNewThreadSelector:@selector(reloadAllProfiles) toTarget:self withObject:nil];
            [NSThread detachNewThreadSelector:@selector(reloadAllDocuments) toTarget:self withObject:nil];
            
            //Wait for signal semaphore 4 times
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
            
            //Continue this thead
            [self updateAllDocumentCabinets];
            [self updateAllDocumentProfiles];
            [CommonVar setNeedToReloadAllDocuments:NO];
            if (![threadObj isCancelled])
                [self postEventLoadCommonDataWithKey:dataType];
        }
    }
    [threadObj releaseOperation];
}

- (id<ThreadProtocol>)getCommonThreadRunning:(NSString *)threadKey {
    return [self.dictCommonDataThreads objectForKey:threadKey];
}

- (BOOL)isCommonDataAvailableWithKey:(NSString *)dataKey {
    if ([dataKey isEqualToString:DATA_COMMON_KEY]) {
        return ([[CabinetDataManager getInstance] hasData] &&
                [[TagDataManager getInstance] hasData] &&
                [[ProfileDataManager getInstance] hasData]);
    }
    return NO;
}

#pragma mark - Document Thumb
- (BOOL)isDocumentThumbDataAvailable:(DocumentObject *)documentObj {
    if (documentObj.docThumbImage != nil) return YES;
    
    if ([[CacheManager getInstance] getDocumentThumbnailCache:documentObj size:ThumbnailSizeMedium] != nil) {
        documentObj.docThumbImage = [[CacheManager getInstance] getDocumentThumbnailCache:documentObj size:ThumbnailSizeMedium];
        return YES;
    }
    return NO;
}

- (BOOL)isDocumentThumbThreadRunning:(DocumentObject *)documentObj {
    id<ThreadProtocol> threadObj = [self.dictThumbThreads objectForKey:documentObj.id];
    if (threadObj == nil) return NO;
    return [threadObj isExecuting];
}

- (void)loadDocumentThumbFor:(DocumentObject *)documentObj {
    id<ThreadProtocol> thread = [[ThreadManager getInstance] dispatchToLowThreadWithTarget:self selector:@selector(executeDownloadDocumentThumb:threadObj:) argument:documentObj];
    @synchronized(self) {
        [self.dictThumbThreads setObject:thread forKey:documentObj.id];
    }
}

- (void)executeDownloadDocumentThumb:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    // Get last modified
    DocumentObject *documentObj = dummy;
    
    // Get cache image
    UIImage *img = [[CacheManager getInstance] getDocumentThumbnailCache:documentObj size:ThumbnailSizeMedium];
    if (img == nil) {
        id imageData = [[DocumentDataManager getInstance] downloadThumbnailImageForDocument:documentObj size:ThumbnailSizeMedium];
        if (imageData) {
            UIImage *image = [UIImage imageWithData:imageData];
            if (image) {
                documentObj.docThumbImage = image;
                [[CacheManager getInstance] setDocumentThumbnailCache:documentObj size:ThumbnailSizeMedium];
            }
        }
    } else {
        documentObj.docThumbImage = img;
    }
    
    //[self postEventLoadDocumentThumbDataFor:documentObj];
    [threadObj releaseOperation];
}

- (void)postEventLoadDocumentThumbDataFor:(DocumentObject *)documentObj {
    Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_LOAD_DOCUMENT_THUMBNAIL];
    [event setContent:documentObj];
    [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
}

#pragma mark - DocumentGroup Data
- (NSArray *)getAllDocumentCabinets {
    if (self.allDocumentCabinets != nil) {
        return [NSArray arrayWithArray:self.allDocumentCabinets];
    }
    
    [self updateAllDocumentCabinets];
    
    return [NSArray arrayWithArray:self.allDocumentCabinets];
}

- (void)updateAllDocumentCabinets {
    @synchronized(self) {
        NSArray *allDocuments = [[NSArray alloc] initWithArray:[[DocumentDataManager getInstance] getAllDocuments]];
        NSArray *allCabinets = [[NSArray alloc] initWithArray:[[CabinetDataManager getInstance] getAllCabinets]];
        
        self.allDocumentCabinets = nil;
        self.allDocumentCabinets = [[NSMutableArray alloc] init];
        NSLog(@"FileThis - allCabinets count = %d", [allCabinets count]);
        for (CabinetObject *cab in allCabinets) {
            DocumentCabinetObject *documentCab = [[DocumentCabinetObject alloc] init];
            documentCab.cabinetObj = cab;
            
            if (![self.allDocumentCabinets containsObject:documentCab]) {
                [self.allDocumentCabinets addObject:documentCab];
            }
            
            for (DocumentObject *documentObj in allDocuments) {
                if ([documentObj.cabs containsObject:cab.id]) {
                    [documentCab.arrDocuments addObject:documentObj];
                }
            }
        }
        
        // Uncategorized, Untagged cabinet
        DocumentCabinetObject *allCab = [self getDocumentCabinetObjectByCabType:kCabinetAllType];
        DocumentCabinetObject *untaggedCab = [self getDocumentCabinetObjectByCabType:kCabinetUntaggedType];
        DocumentCabinetObject *uncategorizedCab = [self getDocumentCabinetObjectByCabType:kCabinetUncategorizedType];
        
        for (DocumentObject *documentObj in allDocuments) {
            [allCab.arrDocuments addObject:documentObj];
            
            if ([documentObj.cabs count] == 0) {
                [uncategorizedCab.arrDocuments addObject:documentObj];
            }
            
            if ([documentObj.tags count] == 0) {
                [untaggedCab.arrDocuments addObject:documentObj];
            }
        }
        
        // Recently added cabinet
        DocumentCabinetObject *recentlyAddedCab = [self getDocumentCabinetObjectByCabType:kCabinetRecentlyAddedType];
        NSArray *documentsInRecentlyAdded = [[DocumentDataManager getInstance] getDocumentsInCabinate:recentlyAddedCab.cabinetObj.id];
        NSArray *documentsInRecentlyAddedIds = [documentsInRecentlyAdded valueForKeyPath:@"id"];
        
        for (id documentId in documentsInRecentlyAddedIds) {
            DocumentObject *documentObj = [[DocumentDataManager getInstance] getObjectByKey:documentId];
            if (documentObj != nil) {
                [recentlyAddedCab.arrDocuments addObject:documentObj];
            }
        }
        
        // Sort all document cabinets by alpha
        [CommonFunc sortDocumentCabinets:self.allDocumentCabinets];
        
        for (DocumentCabinetObject *documentCab in self.allDocumentCabinets) {
            [CommonFunc sortDocuments:documentCab.arrDocuments sortBy:[CommonVar getSortDocumentBy]];
        }
        
        //update the docCount for special Cabinets
        allCab.cabinetObj.docCount = [NSNumber numberWithInt:[allCab.arrDocuments count]];
        untaggedCab.cabinetObj.docCount = [NSNumber numberWithInt:[untaggedCab.arrDocuments count]];
        uncategorizedCab.cabinetObj.docCount = [NSNumber numberWithInt:[uncategorizedCab.arrDocuments count]];
        recentlyAddedCab.cabinetObj.docCount = [NSNumber numberWithInt:[recentlyAddedCab.arrDocuments count]];
        
        NSLog(@"FileThis - allDocumentCabinets count = %d", [self.allDocumentCabinets count]);
    }
}

- (NSArray *)getAllDocumentProfiles {
    if (self.allDocumentProfiles != nil) {
        return [NSArray arrayWithArray:self.allDocumentProfiles];
    }
    
    [self updateAllDocumentProfiles];
    
    return [NSArray arrayWithArray:self.allDocumentProfiles];
}

- (void)updateAllDocumentProfiles {
    @synchronized(self) {
        NSArray *allDocuments = [[NSArray alloc] initWithArray:[[DocumentDataManager getInstance] getAllDocuments]];
        NSArray *allProfiles = [[NSArray alloc] initWithArray:[[ProfileDataManager getInstance] getAllProfiles]];
        self.allDocumentProfiles = [[NSMutableArray alloc] init];
        
        for (ProfileObject *profile in allProfiles) {
            DocumentProfileObject *documentProfile = [[DocumentProfileObject alloc] init];
            documentProfile.profileObj = profile;
            [self.allDocumentProfiles addObject:documentProfile];
            
            for (DocumentObject *documentObj in allDocuments) {
                if ([documentObj.profiles containsObject:profile.id]) {
                    [documentProfile.arrDocuments addObject:documentObj];
                }
            }
            
            //update the docCount for Profile
            documentProfile.profileObj.docCount = [NSNumber numberWithInt:[documentProfile.arrDocuments count]];
            [CommonFunc sortDocuments:documentProfile.arrDocuments sortBy:[CommonVar getSortDocumentBy]];
        }
        
        // Sort all document profiles by alpha
        [CommonFunc sortDocumentProfiles:self.allDocumentProfiles];
    }
}

- (BOOL)isDocumentCabinetsDataAvailable {
    return self.allDocumentCabinets != nil;
}

- (BOOL)isDocumentProfilesDataAvailable {
    return self.allDocumentProfiles != nil;
}

- (id)getDocumentCabinetObjectByCabId:(id)cabId {
    for (DocumentCabinetObject *documentCabObj in [self getAllDocumentCabinets]) {
        if ([documentCabObj.cabinetObj.id isEqual:cabId]) return documentCabObj;
    }
    
    return nil;
}

- (id)getDocumentCabinetObjectByCabType:(NSString *)cabType {
    for (DocumentCabinetObject *documentCabObj in [self getAllDocumentCabinets]) {
        if ([documentCabObj.cabinetObj.type isEqualToString:cabType]) return documentCabObj;
    }
    
    return nil;
}

- (id)getDocumentProfileObjectByProfileId:(id)profileId {
    for (DocumentProfileObject *documentProfileObj in [self getAllDocumentProfiles]) {
        if ([documentProfileObj.profileObj.id isEqual:profileId]) return documentProfileObj;
    }
    
    return nil;
}

- (void)clearAll {
    @synchronized(self) {
        [self.allDocumentCabinets removeAllObjects];
        self.allDocumentCabinets = nil;
        
        [self.allDocumentProfiles removeAllObjects];
        self.allDocumentProfiles = nil;
        
        for (NSString *key in self.dictCommonDataThreads) {
            id<ThreadProtocol> thread = [self.dictCommonDataThreads objectForKey:key];
            if (thread != nil) {
                [thread cancel];
                [thread releaseOperation];
            }
        }
        [self.dictCommonDataThreads removeAllObjects];
        
        for (NSString *key in self.dictDocumentFileThreads) {
            id<ThreadProtocol> thread = [self.dictDocumentFileThreads objectForKey:key];
            if (thread != nil) {
                [thread cancel];
                [thread releaseOperation];
            }
        }
        [self.dictDocumentFileThreads removeAllObjects];
        
        for (NSString *key in self.dictThumbThreads) {
            id<ThreadProtocol> thread = [self.dictThumbThreads objectForKey:key];
            if (thread != nil) {
                [thread cancel];
                [thread releaseOperation];
            }
        }
        [self.dictThumbThreads removeAllObjects];
    }
}

- (BOOL)existAnyThreadRunning {
    @synchronized(self) {
        for (NSString *key in self.dictCommonDataThreads) {
            id<ThreadProtocol> thread = [self.dictCommonDataThreads objectForKey:key];
            if (thread != nil && [thread isExecuting]) {
                return YES;
            }
        }
        
        for (NSString *key in self.dictDocumentFileThreads) {
            id<ThreadProtocol> thread = [self.dictDocumentFileThreads objectForKey:key];
            if (thread != nil && [thread isExecuting]) {
                return YES;
            }
        }
        
        for (NSString *key in self.dictThumbThreads) {
            id<ThreadProtocol> thread = [self.dictThumbThreads objectForKey:key];
            if (thread != nil && [thread isExecuting]) {
                return YES;
            }
        }
        
        return NO;
    }
}

#pragma mark - Document Common Funcs
- (void)addCabinet:(CabinetObject *)cabObj toDocuments:(NSMutableArray *)documents {
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeAddCabinetToDocuments:threadObj:) argument:[NSArray arrayWithObjects:cabObj, documents, nil]];
}

- (void)executeAddCabinetToDocuments:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    NSArray *arrArguments = dummy;
    CabinetObject *cabObj = [arrArguments objectAtIndex:0];
    NSMutableArray *documents = [arrArguments objectAtIndex:1];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [LoadingView startCurrentLoadingView:[NSString stringWithFormat:@"Adding selected document(s) to cabinet '%@'...",cabObj.name]];
    });
    
    NSMutableArray *cabIds = [NSMutableArray arrayWithObject:cabObj.id];
    NSMutableArray *docIds = [[NSMutableArray alloc] init];
    
    for (DocumentObject *docObj in documents) {
        if (![docObj.cabs containsObject:cabObj.id]) {
            [docIds addObject:docObj.id];
        }
    }
    
    if ([[DocumentDataManager getInstance] addCabs:cabIds toDocuments:docIds]) {
        for (DocumentObject *docObj in documents) {
            if (![docObj.cabs containsObject:cabObj.id]) {
                [docObj.cabs addObject:cabObj.id];
            }
        }
        [cabObj updateDocCount];
        
        // Post event to UI
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_ADD_CABS_TO_DOCUMENTS];
        [event setContent:documents];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
    }
    
    // Release thread
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [LoadingView stopCurrentLoadingView];
    });
    
    [threadObj releaseOperation];
}

- (void)removeCabinet:(CabinetObject *)cabObj fromDocuments:(NSMutableArray *)documents {
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeRemoveCabsFromDocuments:threadObj:) argument:[NSArray arrayWithObjects:cabObj, documents, nil]];
}

- (void)executeRemoveCabsFromDocuments:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    NSArray *arguments = dummy;
    CabinetObject *cabObj = [arguments objectAtIndex:0];
    NSMutableArray *documents = [arguments objectAtIndex:1];
    NSMutableArray *cabIds = [NSMutableArray arrayWithObject:cabObj.id];
    NSMutableArray *docIds = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [LoadingView startCurrentLoadingView:[NSString stringWithFormat:@"Removing selected document(s) from cabinet '%@'...",cabObj.name]];
    });
    
    for (DocumentObject *docObj in documents) {
        if ([docObj.cabs containsObject:cabObj.id]) {
            [docIds addObject:docObj.id];
        }
    }
    
    if ([[DocumentDataManager getInstance] removeCabs:cabIds fromDocuments:docIds]) {
        for (DocumentObject *docObj in documents) {
            if ([docObj.cabs containsObject:cabObj.id]) {
                [docObj.cabs removeObject:cabObj.id];
            }
        }
        [cabObj updateDocCount];
        
        // Post event to UI
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_REMOVE_CABS_FROM_DOCUMENTS];
        [event setContent:documents];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
    }
    
    // Release thread
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [LoadingView stopCurrentLoadingView];
    });
    
    [threadObj releaseOperation];
}

#pragma mark - Tag Common Funcs
- (void)addTag:(TagObject *)tagObj toDocuments:(NSMutableArray *)documents {
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeAddTagToDocuments:threadObj:) argument:[NSArray arrayWithObjects:tagObj, documents, nil]];
}

- (void)executeAddTagToDocuments:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    NSArray *arguments = dummy;
    TagObject *tagObj = [arguments objectAtIndex:0];
    NSMutableArray *documents = [arguments objectAtIndex:1];
    NSMutableArray *tagIds = [NSMutableArray arrayWithObject:tagObj.id];
    NSMutableArray *docIds = [[NSMutableArray alloc] init];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [LoadingView startCurrentLoadingView:[NSString stringWithFormat:@"Assigning tag '%@' to selected document(s)...",tagObj.name]];
    });
    
    for (DocumentObject *docObj in documents) {
        if (![docObj.tags containsObject:tagObj.id]) {
            [docIds addObject:docObj.id];
        }
    }
    
    if ([[DocumentDataManager getInstance] addTags:tagIds toDocuments:docIds]) { //save data successfully
        for (DocumentObject *docObj in documents) {
            if (![docObj.tags containsObject:tagObj.id]) {
                [docObj.tags addObject:tagObj.id];
            }
        }
        [tagObj updateDocCount];
        
        // Post event to UI
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_ADD_TAGS_TO_DOCUMENTS];
        [event setContent:documents];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
    }
    
    // Release thread
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [LoadingView stopCurrentLoadingView];
    });
    
    [threadObj releaseOperation];
}

- (void)removeTag:(TagObject *)tagObj fromDocuments:(NSMutableArray *)documents {
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeRemoveTagFromDocuments:threadObj:) argument:[NSArray arrayWithObjects:tagObj, documents, nil]];
}

- (void)executeRemoveTagFromDocuments:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    NSArray *arguments = dummy;
    TagObject *tagObj = [arguments objectAtIndex:0];
    NSMutableArray *documents = [arguments objectAtIndex:1];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [LoadingView startCurrentLoadingView:[NSString stringWithFormat:@"Removing tag '%@' from selected document(s)...",tagObj.name]];
    });
    
    NSMutableArray *tagIds = [NSMutableArray arrayWithObject:tagObj.id];
    NSMutableArray *docIds = [[NSMutableArray alloc] init];
    
    for (DocumentObject *docObj in documents) {
        if ([docObj.tags containsObject:tagObj.id]) {
            [docIds addObject:docObj.id];
        }
    }
    
    if ([[DocumentDataManager getInstance] removeTags:tagIds fromDocuments:docIds]) {
        for (DocumentObject *docObj in documents) {
            if ([docObj.tags containsObject:tagObj.id]) {
                [docObj.tags removeObject:tagObj.id];
            }
            [tagObj updateDocCount];
        }
        
        // Post event to UI
        Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_REMOVE_TAGS_FROM_DOCUMENTS];
        [event setContent:documents];
        [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
    }
    
    // Release thread
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [LoadingView stopCurrentLoadingView];
    });
    
    [threadObj releaseOperation];
}

#pragma mark - Thread run parallel
- (void)reloadAllTags {
    [[TagDataManager getInstance] reloadAll];
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
}

- (void)reloadAllCabinets {
    [[CabinetDataManager getInstance] reloadAll];
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
}

- (void)reloadAllProfiles {
    [[ProfileDataManager getInstance] reloadAll];
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
}

- (void)reloadAllDocuments {
    [[DocumentDataManager getInstance] reloadAll];
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
}

- (void)addDocumentCabinet:(DocumentCabinetObject*)object {
    @synchronized(self) {
        [self.allDocumentCabinets addObject:object];
    }
}

- (void)removeDocumentCabinet:(DocumentCabinetObject*)object {
    @synchronized(self) {
        [self.allDocumentCabinets removeObject:object];
    }
}

- (void)sortDocumentCabinets {
    @synchronized(self) {
        [CommonFunc sortDocumentCabinets:self.allDocumentCabinets];
    }
}

@end
