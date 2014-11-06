//
//  SearchResultDocumentListViewController.h
//  FileThis
//
//  Created by Cuong Le on 12/19/13.
//
//

#import "DocumentListViewController.h"
#import "LoadingView.h"
#import "DocumentSearchCriteria.h"

@interface SearchResultDocumentListViewController : DocumentListViewController

@property (nonatomic, strong) DocumentSearchCriteria *documentSearchCriteria;

@end
