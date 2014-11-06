//
//  DocumentGroupObject.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "DocumentCabinetObject.h"

@implementation DocumentCabinetObject

- (id)init {
    self = [super init];
    if (self) {
        self.arrDocuments = [[NSMutableArray alloc] init];
        self.cabinetObj = nil;
    }
    
    return self;
}

- (DocumentObject *)getDocumentById:(id)key {
    for (DocumentObject *docObj in self.arrDocuments) {
        if ([docObj.id isEqual:key]) return docObj;
    }
    
    return nil;
}

- (int)getIndexDocumentById:(id)key {
    for (int i = 0; i < self.arrDocuments.count; i++) {
        DocumentObject *docObj = [self.arrDocuments objectAtIndex:i];
        if ([docObj.id isEqual:key]) return i;
    }
    return -1;
}

@end
