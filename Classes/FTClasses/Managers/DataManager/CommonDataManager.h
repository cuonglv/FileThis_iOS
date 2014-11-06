//
//  CommonDataManager.h
//  FileThis
//
//  Created by Manh nguyen on 12/23/13.
//
//

#import "BaseObject.h"
#import "DocumentCabinetObject.h"
#import "DocumentObject.h"
#import "DocumentProfileObject.h"
#import "TagObject.h"
#import "ThreadObj.h"

#define DATA_COMMON_KEY       @"DATACOMMONKEY"

@interface CommonDataManager : BaseObject

+ (CommonDataManager *)getInstance;

#pragma mark - Common data
- (id<ThreadProtocol>)loadCommonData;
- (id<ThreadProtocol>)loadCommonDataWithKey:(id)dataKey;
- (BOOL)isCommonDataAvailableWithKey:(id)dataKey;
- (id<ThreadProtocol>)reloadCommonDataWithKey:(id)dataKey;
- (void)postEventLoadCommonDataWithKey:(id)dataKey;

#pragma mark - Document thumbnail
- (BOOL)isDocumentThumbDataAvailable:(DocumentObject *)documentObj;
- (BOOL)isDocumentThumbThreadRunning:(DocumentObject *)documentObj;
- (void)loadDocumentThumbFor:(DocumentObject *)documentObj;
- (void)postEventLoadDocumentThumbDataFor:(DocumentObject *)documentObj;

#pragma mark - Document group
- (NSArray *)getAllDocumentCabinets;
- (NSArray *)getAllDocumentProfiles;

- (id)getDocumentCabinetObjectByCabId:(id)cabId;
- (id)getDocumentCabinetObjectByCabType:(NSString *)cabType;
- (id)getDocumentProfileObjectByProfileId:(id)profileId;
- (BOOL)isDocumentCabinetsDataAvailable;
- (BOOL)isDocumentProfilesDataAvailable;

- (void)clearAll;
- (BOOL)existAnyThreadRunning;

#pragma mark - Document Common Funcs
- (void)addCabinet:(CabinetObject *)cabObj toDocuments:(NSMutableArray *)documents;
- (void)removeCabinet:(CabinetObject *)cabObj fromDocuments:(NSMutableArray *)documents;

#pragma mark - Tag Common Funcs
- (void)addTag:(TagObject *)tagObj toDocuments:(NSMutableArray *)documents;
- (void)removeTag:(TagObject *)tagObj fromDocuments:(NSMutableArray *)documents;

#pragma mark - 
- (void)addDocumentCabinet:(DocumentCabinetObject*)object;
- (void)removeDocumentCabinet:(DocumentCabinetObject*)object;
- (void)sortDocumentCabinets;

@end
