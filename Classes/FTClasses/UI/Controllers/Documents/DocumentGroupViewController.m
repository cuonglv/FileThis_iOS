//
//  CabinetDocumentListViewController.m
//  FileThis
//
//  Created by Manh nguyen on 12/19/13.
//
//

#import "DocumentGroupViewController.h"
#import "CommonDataManager.h"
#import "DocumentDataManager.h"
#import "EventManager.h"
#import <QuartzCore/QuartzCore.h>
#import "DocumentProfileObject.h"
#import "FTMobileAppDelegate.h"

#define HEIGHT_FOR_ROW  40

@interface DocumentGroupViewController ()

@end

@implementation DocumentGroupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (self.actionType == ACTIONTYPE_EDIT_TAGS) {
        self.actionType = ACTIONTYPE_UNKNOWN;
        [self editTagForViewedDocument];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)initializeScreen {
    [super initializeScreen];
    NSString *name = @"";
    if ([self.documentGroup isKindOfClass:[DocumentCabinetObject class]]) {
        name = ((DocumentCabinetObject *)self.documentGroup).cabinetObj.name;
    } else {
        name = ((DocumentProfileObject *)self.documentGroup).profileObj.name;
    }
    [self.titleLabel setText:name];
    
    [self.documentsCabThumbView.arrDocumentCabinets addObject:self.documentGroup];
    [self.documentsCabThumbView.selectedSections addObject:@"0"];
    [self.documentsCabThumbView.collectDocumentCabinet reloadData];
    
    [[EventManager getInstance] addListener:self channel:CHANNEL_DATA];
}

#pragma mark - Layout
- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    if (IS_IPHONE)
        return 30;
    return [super horizontalSpacingBetweenBottomCenterBarButtons];
}

- (void)relayout {
    [super relayout];
}

#pragma mark - My Funcs
- (void)editTagForViewedDocument {
    if (self.documentObjects && self.documentInfoViewed) {
        FTMobileAppDelegate *appDelegate = (FTMobileAppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate goToDocumentDetail:self.documentInfoViewed documents:self.documentObjects actionType:ACTIONTYPE_EDIT_TAGS];
    }
}

@end
