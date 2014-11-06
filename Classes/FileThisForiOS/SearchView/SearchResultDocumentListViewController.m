//
//  SearchResultDocumentListViewController.m
//  FileThis
//
//  Created by Cuong Le on 12/19/13.
//
//

#import "SearchResultDocumentListViewController.h"
#import "DocumentDataManager.h"
#import "LoadingView.h"
#import "CommonDataManager.h"
#import "CommonFunc.h"
#import "FTMobileAppDelegate.h"

#define HEIGHT_FOR_ROW  80

@interface SearchResultDocumentListViewController ()

@end

@implementation SearchResultDocumentListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.actionType == ACTIONTYPE_EDIT_TAGS) {
        self.actionType = ACTIONTYPE_UNKNOWN;
        [self editTagForViewedDocument];
    }
}

- (void)initializeScreen {
    [super initializeScreen];
    
    self.titleLabel.text = NSLocalizedString(@"ID_SEARCH_RESULT", @"");
    self.loadingView = [[LoadingView alloc] init];
    
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(loadDataForMe:threadObj:) argument:@""];
}

#pragma mark - My Funcs
- (void)editTagForViewedDocument {
    DocumentObject *doc = self.documentInfoViewed;
    NSMutableArray *arr = self.documentObjects;
    
    if (arr && doc) {
        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate goToDocumentDetail:doc documents:arr actionType:ACTIONTYPE_EDIT_TAGS parameter:self.documentSearchCriteria];
    }
}

- (void)loadDataForMe:(id)dummy threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.loadingView startLoadingInView:self.view frame:self.contentView.frame];
    });
    
    self.documentObjects = [[NSMutableArray alloc] init];
    DocumentCabinetObject *docCabTemp = [[DocumentCabinetObject alloc] init];
    NSArray *results = [[DocumentDataManager getInstance] getDocumentSearchCriteria:self.documentSearchCriteria];
    
    NSArray *documentIds = [results valueForKeyPath:@"id"];
    for (id documentId in documentIds) {
        DocumentObject *documentObj = [[DocumentDataManager getInstance] getObjectByKey:documentId];
        if (documentObj != nil) {
            [self.documentObjects addObject:documentObj];
            [docCabTemp.arrDocuments addObject:documentObj];
        }
    }

    self.documentGroup = docCabTemp;
    [self.documentsCabThumbView.selectedSections addObject:@"0"];
    [self.documentsCabThumbView.arrDocumentCabinets addObject:docCabTemp];
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //[manhnn - 655] Apply sort after get results, the table will be reloaded data in sort function.
        [self didSelectSortBy:[CommonVar getSortDocumentBy]];
        [self.loadingView stopLoading];
    });
    
    [threadObj releaseOperation];
}

#pragma mark - UITableViewDelegate
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    UILabel *lblDocumentCount = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, HEIGHT_FOR_ROW)];
//    [lblDocumentCount setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal] textColor:kGrayColor backgroundColor:kDocumentGroupHeaderColor text:[NSString stringWithFormat:NSLocalizedString(@"ID_I_DOCUMENTS_FOUND", @""), [self.documentObjects count]] numberOfLines:0 textAlignment:NSTextAlignmentCenter];
//    [lblDocumentCount.layer setBorderColor:kLightGrayColor.CGColor];
//    [lblDocumentCount.layer setBorderWidth:1.0];
//    self.lblHeaderInSection = lblDocumentCount;
//    return lblDocumentCount;
//}

#pragma mark - Override
- (void)didTouchCell:(id)sender documentObject:(DocumentObject *)docObj {
    if (self.tbDocumentList.isEditing) {
        [super didTouchCell:sender documentObject:docObj];
    } else {
        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate goToDocumentDetail:docObj documents:self.documentObjects actionType:ACTIONTYPE_UNKNOWN parameter:self.documentSearchCriteria];
    }
}

- (void)tagViewDidEditTouched:(id)sender forDocument:(DocumentObject *)docObj
{
    if (![self.tbDocumentList isEditing]) {
        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate goToDocumentDetail:docObj documents:self.documentObjects actionType:ACTIONTYPE_EDIT_TAGS parameter:self.documentSearchCriteria];
    }
}

@end
