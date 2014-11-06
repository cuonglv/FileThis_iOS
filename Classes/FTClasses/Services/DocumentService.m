//
//  GetDocumentListService.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import <Crashlytics/Crashlytics.h>
#import "DocumentService.h"
#import "CommonVar.h"
#import "DateHandler.h"


@implementation DocumentService

- (NSString *)serviceLink {
    if (self.action == kActionGetAllDocuments) {
        NSString *ret = [NSString stringWithFormat:kUrlGetAllDocuments, [CommonVar ticket]];
        if ( (self.incrementalTimestamp > 0) && (self.oldListIDs.length > 0) ) {
            //ret = [NSString stringWithFormat:@"%@&json=true"];
        }
        return ret;
    } else if (self.action == kActionGetAllDocumentsInCab) {
        return [NSString stringWithFormat:kUrlGetAllDocumentsInCab, self.cabId, [CommonVar ticket]];
    } else if (self.action == kActionGetDocumentThumbnail) {
        NSString *size = @"small";
        if (self.documentThumbSize == ThumbnailSizeMedium) {
            size = @"medium";
        }
        return [NSString stringWithFormat:kUrlGetDocumentThumbnail, self.docObj.id, size, [CommonVar ticket]];
    } else if (self.action == kActionGetDocumentFile) {
        return [NSString stringWithFormat:kUrlGetDocumentFile, self.docObj.id, [CommonVar ticket]];
    } else if (self.action == kActionSearchDocuments) {
        NSString *ret = [NSString stringWithFormat:kUrlGetDocuments,[CommonVar ticket]];
        
        if (self.documentSearchCriteria.date1) {
            if (self.documentSearchCriteria.date1.day == -1) {
                if (self.documentSearchCriteria.date1.month == -1) { //year only
                    ret = [ret stringByAppendingFormat:@"&relDateRange=%i-%i",self.documentSearchCriteria.date1.year,self.documentSearchCriteria.date2.year];
                } else { //month & year
                    NSString *monthString1, *monthString2;
                    if (self.documentSearchCriteria.date1.month < 10)
                        monthString1 = [NSString stringWithFormat:@"0%i",self.documentSearchCriteria.date1.month];
                    else
                        monthString1 = [NSString stringWithFormat:@"%i",self.documentSearchCriteria.date1.month];
                    
                    if (self.documentSearchCriteria.date2.month < 10)
                        monthString2 = [NSString stringWithFormat:@"0%i",self.documentSearchCriteria.date2.month];
                    else
                        monthString2 = [NSString stringWithFormat:@"%i",self.documentSearchCriteria.date2.month];
                    
                    ret = [ret stringByAppendingFormat:@"&relDateRange=%@/%i-%@/%i",monthString1,self.documentSearchCriteria.date1.year,monthString2,self.documentSearchCriteria.date2.year];
                }
            } /* else {
                NSString *dayString1, *monthString1, *dayString2, *monthString2;
                if (self.documentSearchCriteria.date.day < 10)
                    dayString1 = [NSString stringWithFormat:@"0%i",self.documentSearchCriteria.date1.day];
                else
                    dayString1 = [NSString stringWithFormat:@"%i",self.documentSearchCriteria.date1.day];
                
                if (self.documentSearchCriteria.date.month < 10)
                    monthString = [NSString stringWithFormat:@"0%i",self.documentSearchCriteria.date.month];
                else
                    monthString = [NSString stringWithFormat:@"%i",self.documentSearchCriteria.date.month];
                
                ret = [ret stringByAppendingFormat:@"&relDateRange=%@/%@/%i-%@/%@/%i",dayString,monthString,self.documentSearchCriteria.date.year,dayString,monthString,self.documentSearchCriteria.date.year];
            } */
        }
        
        if ([self.documentSearchCriteria.texts count] > 0) {
            NSString *textString = [NSString stringWithFormat:@"\"%@\"",[self.documentSearchCriteria.texts objectAtIndex:0]];
            
            for (int i = 1, count = [self.documentSearchCriteria.texts count]; i < count; i++) {
                textString = [textString stringByAppendingFormat:@"\"%@\"",[self.documentSearchCriteria.texts objectAtIndex:i]];
            }
            ret = [ret stringByAppendingFormat:@"&search=%@",[textString URLEncodedString]];
        }
                                     
        if (self.documentSearchCriteria.cabinetId)
            ret = [ret stringByAppendingFormat:@"&cabid=%@",self.documentSearchCriteria.cabinetId];
        else if (self.documentSearchCriteria.profileId)
            ret = [ret stringByAppendingFormat:@"&profileid=%@",self.documentSearchCriteria.profileId];
        
        NSString *tagIdsString = nil;
        if ([self.documentSearchCriteria.tagIds count] > 0) {
            tagIdsString = [[self.documentSearchCriteria.tagIds objectAtIndex:0] stringValue];
            for (int i = 1, count = [self.documentSearchCriteria.tagIds count]; i < count; i++) {
                tagIdsString = [tagIdsString stringByAppendingFormat:@",%@",[[self.documentSearchCriteria.tagIds objectAtIndex:i] stringValue]];
            }
            ret = [ret stringByAppendingFormat:@"&tagIds=%@",tagIdsString];
        }
        
        return ret;
    } else if (self.action == kActionUpdateDocumentInfo) {
        return [NSString stringWithFormat:kUrlUpdateDocumentInfo, [CommonVar ticket]];
    } else if (self.action == kActionAddTagsToDocuments) {
        return [NSString stringWithFormat:kUrlAddTagsToDocuments, [CommonVar ticket]];
    } else if (self.action == kActionRemoveTagsFromDocuments) {
        return [NSString stringWithFormat:kUrlRemoveTagsFromDocuments, [CommonVar ticket]];
    } else if (self.action == kActionAddCabsToDocuments) {
        return [NSString stringWithFormat:kUrlAddCabsToDocuments, [CommonVar ticket]];
    } else if (self.action == kActionRemoveCabsFromDocuments) {
        return [NSString stringWithFormat:kUrlRemoveCabsFromDocuments, [CommonVar ticket]];
    } else if (self.action == kActionDeleteDocuments) {
        return [NSString stringWithFormat:kUrlDeleteDocuments, [CommonVar ticket]];
    } else if (self.action == kActionGetAllDocumentsInProfile) {
        return [NSString stringWithFormat:kUrlGetAllDocumentsInProfile, self.profileId, [CommonVar ticket]];
    } else if ( (self.action == kActionGetDocMailLinks) || (self.action == kActionGetMultiDocMailLinks) ){
        return [NSString stringWithFormat:kUrlGetDocMailLinks, [CommonVar ticket]];
    }
    return nil;
}

- (NSString *)getHttpMethod {
    if (self.action == kActionUpdateDocumentInfo ||
        self.action == kActionAddTagsToDocuments ||
        self.action == kActionRemoveTagsFromDocuments ||
        self.action == kActionAddCabsToDocuments ||
        self.action == kActionRemoveCabsFromDocuments ||
        self.action == kActionDeleteDocuments ||
        self.action == kActionGetDocMailLinks ||
        self.action == kActionGetMultiDocMailLinks ||
        self.action == kActionGetAllDocuments //Loc Cao
        )
        return @"POST";
    return @"GET";
}

- (NSMutableDictionary *)getHttpHeaders {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (self.action == kActionUpdateDocumentInfo ||
        self.action == kActionAddTagsToDocuments ||
        self.action == kActionRemoveTagsFromDocuments ||
        self.action == kActionAddCabsToDocuments ||
        self.action == kActionRemoveCabsFromDocuments ||
        self.action == kActionDeleteDocuments ||
        self.action == kActionGetAllDocuments
        )
    {
        NSData *postData = [[self getPostRequest] dataUsingEncoding:NSUTF8StringEncoding];
        [dict setValue:@"application/xml" forKey:@"Content-Type"];
        [dict setValue:[NSString stringWithFormat:@"%d", [postData length]] forKey:@"Content-Length"];
    } else if ( (self.action == kActionGetDocMailLinks) || (self.action == kActionGetMultiDocMailLinks) ) {
        [dict setValue:@"application/json" forKey:@"Content-Type"];
        NSData *postData = [[self getPostRequest] dataUsingEncoding:NSUTF8StringEncoding];
        [dict setValue:[NSString stringWithFormat:@"%d", [postData length]] forKey:@"Content-Length"];
    }
    return dict;
}

- (NSString *)getPostRequest {
    NSMutableString *s = [[NSMutableString alloc] init];
    if (self.action == kActionUpdateDocumentInfo) {
        [s appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
        
        [s appendString:@"<request>"];
        [s appendString:@"<documents>"];
        [s appendString:@"<document>"];
        [s appendFormat:@"<id>%@</id>", self.docObj.id];
        [s appendFormat:@"<docname>%@</docname>", self.docObj.docname];
        [s appendFormat:@"<reldate>%@</reldate>", [self.docObj.relevantDate stringValue]];
        [s appendString:@"</document>"];
        [s appendString:@"</documents>"];
        [s appendString:@"</request>"];
    } else if (self.action == kActionAddTagsToDocuments || self.action == kActionRemoveTagsFromDocuments) {
        [s appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
        [s appendString:@"<request>"];
        [s appendString:@"<tagids>"];
        for (id tagId in self.tagIds) {
            [s appendString:@"<tagid>"];
            [s appendString:[tagId stringValue]];
            [s appendString:@"</tagid>"];
        }
        [s appendString:@"</tagids>"];
        
        [s appendString:@"<ids>"];
        for (id docId in self.docIds) {
            [s appendFormat:@"<id>%@</id>", [docId stringValue]];
        }
        [s appendString:@"</ids>"];
        [s appendString:@"</request>"];
        
        return s;
    } else if (self.action == kActionAddCabsToDocuments || self.action == kActionRemoveCabsFromDocuments) {
        [s appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
        [s appendString:@"<request>"];
        
        [s appendString:@"<cabids>"];
        for (id cabId in self.cabIds) {
            [s appendString:@"<cabid>"];
            [s appendString:[cabId stringValue]];
            [s appendString:@"</cabid>"];
        }
        [s appendString:@"</cabids>"];
        
        [s appendString:@"<ids>"];
        for (id docId in self.docIds) {
            [s appendString:@"<id>"];
            [s appendString:[docId stringValue]];
            [s appendString:@"</id>"];
        }
        [s appendString:@"</ids>"];
        [s appendString:@"</request>"];
    } else if (self.action == kActionDeleteDocuments) {
        [s appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
        [s appendString:@"<request>"];
        
        [s appendString:@"<ids>"];
        for (id docId in self.docIds) {
            [s appendString:@"<id>"];
            [s appendString:[docId stringValue]];
            [s appendString:@"</id>"];
        }
        [s appendString:@"</ids>"];
        
        [s appendString:@"</request>"];
    } else if (self.action == kActionGetDocMailLinks) {
        [s appendFormat:@"{\"id\":\"%@\", \"action\":\"clienthtml\"}", [self.documentId stringValue]];
    } else if (self.action == kActionGetMultiDocMailLinks) {
        [s appendString:@"{\"ids\":\""];
        if (self.docIds.count > 0) {
            [s appendFormat:@"%@", [[self.docIds objectAtIndex:0] stringValue]];
        }
        for (int i = 1; i < self.docIds.count; i++) {
            NSString *docId = [[self.docIds objectAtIndex:i] stringValue];
            [s appendFormat:@",%@", docId];
        }
        [s appendString:@"\", \"action\":\"clienthtml\"}"];
    } else if (self.action == kActionGetAllDocuments) {
        if ( (self.incrementalTimestamp > 0) && ((self.oldListIDs.length > 0)) ) {
            [s appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\"?>"];
            
            [s appendString:@"<request>"];
            [s appendFormat:@"<haveTimestamp>%lld</haveTimestamp>", self.incrementalTimestamp];
            [s appendString:@"<haveDocIds>"];
            [s appendString:self.oldListIDs];
            [s appendString:@"</haveDocIds>"];
            [s appendString:@"</request>"];
        }
    }
    
    return s;
}

@end
