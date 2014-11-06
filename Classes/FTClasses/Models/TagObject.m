//
//  TagObject.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "TagObject.h"
#import "DocumentDataManager.h"

@implementation TagObject

- (void)updateDocCount {
    @synchronized(self) {
        NSArray *allDocuments = [[DocumentDataManager getInstance] getAllObjects];
        int count = 0;
        for (DocumentObject *docObj in allDocuments) {
            if ([docObj.tags containsObject:self.id])
                count++;
        }
        self.docCount = [NSNumber numberWithInt:count];
    }
}

@end
