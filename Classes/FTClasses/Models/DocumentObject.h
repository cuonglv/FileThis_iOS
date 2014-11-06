//
//  DocumentObject.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "BaseObject.h"

@interface DocumentObject : BaseObject<UIActivityItemSource>

// {"id":1229228,"added":1375066968,"created":1375066966,"mimeType":"application/pdf","kind":"PDF","size":"217713","path":"SSU\/com.pnc","filename":"PNC Free Checking XXXXXX0253 2011-07-12.pdf","pages":1,"relevantDate":1310454000,"origRelevantDate":1310454000,"deliveryState":"done","destinationId":3,"delivered":1375066977,"cabs":[],"tags":[],"profiles":[135900]}
@property (nonatomic, strong) NSNumber *relevantDate, *added, *created, *modified, *origRelevantDate;
@property (nonatomic, copy) NSString *mimeType, *kind, *size, *path, *filename, *docname, *pages, *deliveryState, *destinationId, *delivered;
@property (nonatomic, strong) NSMutableArray *cabs, *tags, *profiles;
@property (nonatomic, strong) UIImage *docThumbImage;
@property (nonatomic, strong) NSURL *docURL;
@property (nonatomic, strong) UIImageView *imageViewNeedToLoadThumbnail;
@property (nonatomic, copy) NSString *shareSubject, *shareContent;
- (BOOL)matchesTagIds:(NSArray*)tagIds;

- (NSDictionary*)toDictionary;
- (void)updateProperties:(NSArray*)properties fromObject:(DocumentObject*)obj;

@end
