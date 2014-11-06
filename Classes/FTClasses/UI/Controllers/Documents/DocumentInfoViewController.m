//
//  DocumentInfoViewController.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/25/14.
//
//

#import "DocumentInfoViewController.h"
#import "DocumentDataManager.h"
#import "NetworkReachability.h"
#import "Utils.h"

@interface DocumentInfoViewController ()
@property (nonatomic, strong) UIButton *btnSave;
@property (nonatomic, assign) BOOL edittingFilename;
@end

@implementation DocumentInfoViewController

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
    // Do any additional setup after loading the view from its nib.
    DocumentInfoView_iphone *v = [[DocumentInfoView_iphone alloc] initWithFrame:self.contentView.bounds];
    v.tagListView.delegate = self;
    self.documentView = v;
    [self.contentView addSubview:v];
    [self.documentView loadViewWithDocument:self.document];
    self.documentView.delegate = self;
    
    self.titleLabel.text = @"Info";
    
    self.btnSave = [self addTopRightBarButton:@"Save" target:self selector:@selector(handleSaveButton:)];
    self.btnSave.hidden = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - My Func
- (void)setEditFilenameMode:(BOOL)edit {
    self.edittingFilename = edit;
    self.btnSave.hidden = !edit;
}

- (BaseViewController*)getPreviousViewController {
    NSArray *arr = self.navigationController.viewControllers;
    int count = arr.count;
    if (count < 2)
        return nil;
    
    BaseViewController *ret = (BaseViewController*)[arr objectAtIndex:count-2];
    return ret;
}

#pragma mark - Overriden
- (BOOL)shouldUseBackButton {
    return YES;
}

#pragma mark - DocumentInfoViewDelegate
- (void)didCloseButtonTouched:(id)sender {
    [self setEditFilenameMode:NO];
}

- (void)didEditFilenameButtonTouched:(id)sender {
    [self setEditFilenameMode:YES];
}

- (void)willUpdateDocumentValue:(DocumentObject *)newDoc withProperties:(NSArray *)properties {
    BOOL res = [[DocumentDataManager getInstance] updateDocumentInfo:newDoc];
    if (res) {
        [self.document updateProperties:properties fromObject:newDoc];
    } else {
        [self.documentView loadViewWithDocument:self.document];
    }
}

#pragma mark - TagListViewDelegate
- (void)tagViewDidEditTouched:(id)sender forDocument:(DocumentObject *)docObj {
    BaseViewController *controller = [self getPreviousViewController];
    if ([controller isKindOfClass:[BaseViewController class]]) {
        controller.actionType = ACTIONTYPE_EDIT_TAGS;
        [self.navigationController popViewControllerAnimated:NO];
    }
    //NSLog(@"%@", [[controller class] description]);
}

#pragma mark - Button events
- (void)handleSaveButton:(UIButton*)sender {
    [self setEditFilenameMode:NO];
    [self.documentView setEditStatus:NO];
    [self.documentView handleSaveButton:nil];
}

@end
