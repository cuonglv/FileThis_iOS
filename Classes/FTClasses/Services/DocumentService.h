//
//  GetDocumentListService.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "BaseService.h"
#import "CabinetObject.h"
#import "DocumentObject.h"
#import "CommonVar.h"
#import "DocumentSearchCriteria.h"

#define kUrlGetAllDocuments       @"compact=true&json=true&op=doclist&ticket=%@"
#define kUrlGetAllDocumentsInCab  @"compact=true&json=true&op=doclist&cabid=%@&ticket=%@"
#define kUrlGetDocumentThumbnail  @"compact=true&json=true&op=thumb&id=%@&size=%@&ticket=%@"
#define kUrlGetDocumentFile  @"compact=true&json=true&op=download&id=%@&ticket=%@"


#define kUrlGetDocumentsByTagIds            @"compact=true&json=true&op=doclist&tagIds=%@&ticket=%@"
#define kUrlGetDocumentsByTagIdsAndText     @"compact=true&json=true&op=doclist&tagIds=%@&search=%@&ticket=%@"
#define kUrlGetDocumentsByText              @"compact=true&json=true&op=doclist&search=%@&ticket=%@"
#define kUrlUpdateDocumentInfo              @"op=updatedoc&ticket=%@"
#define kUrlGetDocuments                    @"compact=true&json=true&op=doclist&ticket=%@"
#define kUrlAddTagsToDocuments              @"op=addtagtodoc&ticket=%@"
#define kUrlRemoveTagsFromDocuments         @"op=removetagfromdoc&ticket=%@"
#define kUrlDeleteDocuments                 @"op=docdelete&ticket=%@"
#define kUrlGetAllDocumentsInProfile  @"compact=true&json=true&op=doclist&profileid=%@&ticket=%@"
#define kUrlAddCabsToDocuments              @"op=addcabtodoc&ticket=%@"
#define kUrlRemoveCabsFromDocuments         @"op=removecabfromdoc&ticket=%@"
#define kUrlGetDocMailLinks                 @"op=docemaillinks&ticket=%@&json=1"

// Document Actions
#define kActionGetAllDocumentsInCab         0
#define kActionGetDocumentThumbnail         1
#define kActionGetDocumentFile              2
#define kActionGetDocuments                 3
#define kActionUpdateDocumentInfo           4
#define kActionAddTagsToDocuments           5
#define kActionRemoveTagsFromDocuments      6
#define kActionDeleteDocuments              7
#define kActionGetAllDocumentsInProfile     8
#define kActionAddCabsToDocuments           9
#define kActionRemoveCabsFromDocuments      10
#define kActionGetAllDocuments              11
#define kActionSearchDocuments              12
#define kActionGetDocMailLinks              13
#define kActionGetMultiDocMailLinks         14

@interface DocumentService : BaseService

@property (nonatomic, strong) NSNumber *cabId, *profileId;
@property (nonatomic, strong) DocumentObject *docObj;
@property (nonatomic, strong) NSArray *tagIds, *cabIds;
@property (nonatomic, strong) NSArray *docIds;
@property (nonatomic, strong) NSNumber *documentId;

@property (nonatomic, strong) DocumentSearchCriteria *documentSearchCriteria;
@property (nonatomic, assign) ThumbnailSize documentThumbSize;

@property long long incrementalTimestamp;
@property (nonatomic, copy) NSString *oldListIDs;

@end
