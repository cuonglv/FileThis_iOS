//
//  SelectedTagsDocumentViewController.m
//  FileThis
//
//  Created by Cuong Le on 1/20/14.
//
//

#import "SelectedTagsDocumentViewController.h"
#import "DocumentDataManager.h"
#import "NumberHandler.h"

@interface SelectedTagsDocumentViewController ()

@end

@implementation SelectedTagsDocumentViewController

- (void)initializeScreen {
    [super initializeScreen];
    
    self.documentObjects = [[NSMutableArray alloc] init];
    DocumentCabinetObject *docCabTemp = [[DocumentCabinetObject alloc] init];
//    NSArray *allDocuments = [[NSArray alloc] initWithArray:[[DocumentDataManager getInstance] getAllDocuments]];
//    for (DocumentObject *docObj in allDocuments) {
//        if (self.cabinetId)
//            if (![docObj.cabs containsObject:self.cabinetId])
//                continue;
//        
//        if (self.profileId)
//            if (![docObj.profiles containsObject:self.profileId])
//                continue;
//        
//        if ([docObj matchesTagIds:self.selectedTagIds]) {
//            [self.documentObjects addObject:docObj];
//            [docCabTemp.arrDocuments addObject:docObj];
//        }
//    }
    
    docCabTemp.arrDocuments = self.filteredDocumentObjects;
    self.documentGroup = docCabTemp;
    self.documentObjects = docCabTemp.arrDocuments;
    [self.tbDocumentList reloadData];
    
    [self.documentsCabThumbView.arrDocumentCabinets addObject:docCabTemp];
    [self.documentsCabThumbView.selectedSections addObject:@"0"];
    [self.documentsCabThumbView.collectDocumentCabinet reloadData];
    
    [self didSelectSortBy:[CommonVar getSortDocumentBy]];
}

@end
