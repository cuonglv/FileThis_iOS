//
//  DocumentGroupListViewController_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/19/14.
//
//

#import "DocumentGroupListViewController_iphone.h"
#import "DocumentInfoViewController.h"
#import "FTMobileAppDelegate.h"

@interface DocumentGroupListViewController_iphone ()

@end

@implementation DocumentGroupListViewController_iphone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.documentCabListView.delegateCell = self;
    self.documentProfileListView.delegateCell = self;
    [self.documentCabThumbView setupViewForIdiom:UIUserInterfaceIdiomPhone];
    [self.documentProfileThumbView setupViewForIdiom:UIUserInterfaceIdiomPhone];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.actionType == ACTIONTYPE_EDIT_TAGS) {
        self.actionType = ACTIONTYPE_UNKNOWN;
        [self editTagForViewedDocument];
    }
}

#pragma mark - My Funcs
- (void)editTagForViewedDocument {
    NSMutableArray *arr = nil;
    DocumentObject *doc = nil;
    NSIndexPath *indexPath = self.documentCabListView.pathDocumentInfoViewed;
    if (!indexPath)
        return;
    if (self.type == TYPE_CABINET) {
        if (indexPath.section >= self.documentCabListView.arrDocumentCabinets.count)
            return;
        DocumentCabinetObject *documentCabinet = [self.documentCabListView.arrDocumentCabinets objectAtIndex:indexPath.section];
        if (indexPath.row >= documentCabinet.arrDocuments.count)
            return;
        
        arr = documentCabinet.arrDocuments;
        doc = [documentCabinet.arrDocuments objectAtIndex:indexPath.row];
    } else if (self.type == TYPE_PROFILE) {
        if (indexPath.section >= self.documentProfileListView.arrDocumentProfiles.count)
            return;
        DocumentProfileObject *documentProfile = [self.documentProfileListView.arrDocumentProfiles objectAtIndex:indexPath.section];
        if (indexPath.row >= documentProfile.arrDocuments.count)
            return;
        
        arr = documentProfile.arrDocuments;
        doc = [documentProfile.arrDocuments objectAtIndex:indexPath.row];
    }
    
    if (arr && doc) {
        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate goToDocumentDetail:doc documents:arr actionType:ACTIONTYPE_EDIT_TAGS];
    }
}

#pragma mark - DocumentCellDelegate
- (void)didButtonInfoTouched:(id)sender for:(DocumentObject *)docObj
{
    DocumentInfoViewController *target = [[DocumentInfoViewController alloc] initWithNibName:@"DocumentInfoViewController" bundle:[NSBundle mainBundle]];
    target.document = docObj;
    [self.navigationController pushViewController:target animated:YES];
}

@end
