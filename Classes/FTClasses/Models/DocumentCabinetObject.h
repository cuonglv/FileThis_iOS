//
//  DocumentGroupObject.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "BaseObject.h"
#import "CabinetObject.h"
#import "DocumentObject.h"

@interface DocumentCabinetObject : BaseObject

@property (nonatomic, strong) CabinetObject *cabinetObj;
@property (nonatomic, strong) NSMutableArray *arrDocuments;

- (DocumentObject *)getDocumentById:(id)key;
- (int)getIndexDocumentById:(id)key;

@end
