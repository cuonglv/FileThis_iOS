//
//  DocumentDetailViewController_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 3/3/14.
//
//

#import "DocumentDetailViewController_iphone.h"
#import "DocumentInfoViewController.h"

@interface DocumentDetailViewController_iphone ()

@end

@implementation DocumentDetailViewController_iphone

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
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updateDocumentTitle];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
- (void)initializeScreen {
    [super initializeScreen];
    
    [self.view bringSubviewToFront:self.overlayView];
    [self.view bringSubviewToFront:self.topButtonBar];
    [self.view bringSubviewToFront:self.documentTagsView];
    [self.view bringSubviewToFront:self.documentInfoView];
    [self.view bringSubviewToFront:self.documentCabinetsView];
    [self.view bringSubviewToFront:self.searchTextView];
    
    self.overlayView.hidden = YES;
}

- (void)initializeToolbarButtons {
    self.btnShare = [self addBottomCenterBarButton:NSLocalizedString(@"ID_SEND", @"") image:[UIImage imageNamed:@"send_white_icon.png"] target:self selector:@selector(handleShareButton:) width:50];
    self.btnExport = [self addBottomCenterBarButton:NSLocalizedString(@"ID_SHARE", @"") image:[UIImage imageNamed:@"share_white_icon.png"] target:self selector:@selector(handleExportButton:)];
    
    self.btnCabinet = [self addBottomCenterBarButton:NSLocalizedString(@"ID_CABINET", @"") image:[UIImage imageNamed:@"cab_white_icon.png"] target:self selector:@selector(handleCabinetButton:)];
    self.btnTags = [self addBottomCenterBarButton:NSLocalizedString(@"ID_TAGS_NO_DOT", @"") image:[UIImage imageNamed:@"tags_white_icon.png"] target:self selector:@selector(handleTagsButton:)];
    //self.btnView = [self addBottomCenterBarButton:NSLocalizedString(@"ID_VIEW", @"") image:[UIImage imageNamed:@"view_white_icon.png"] target:self selector:@selector(handleViewButton:)];
    
    ///////////////////
    self.additionalBarButtons = [[NSMutableArray alloc] init];
    
    int barWidth = 178;
    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(self.view.bounds.size.width - barWidth, [self heightForTopBar], barWidth, [self topLabelHeight])];
    self.topButtonBar = v;
    [self.view addSubview:v];
    
    CGSize size = CGSizeMake(28, 28);
    CGRect rect = CGRectMake(0, ([self topLabelHeight]-size.height)/2, size.width, size.height);
    
    self.btnView = [CommonLayout createImageButtonWithFrame:rect image:[UIImage imageNamed:@"view_icon.png"] touchTarget:self touchSelector:@selector(handleViewButton:) superView:self.topButtonBar];
    [self.additionalBarButtons addObject:self.btnView];
    
    rect.origin.x += size.width + 20;
    self.btnInfo = [CommonLayout createImageButtonWithFrame:rect image:[UIImage imageNamed:@"info_icon.png"] touchTarget:self touchSelector:@selector(handleInfoButton:) superView:self.topButtonBar];
    [self.additionalBarButtons addObject:self.btnInfo];
    
    rect.origin.x += size.width + 20;
    self.btnSearch = [CommonLayout createImageButtonWithFrame:rect image:[UIImage imageNamed:@"search_toolbar_icon.png"] touchTarget:self touchSelector:@selector(handleSearchButton:) superView:self.topButtonBar];
    [self.additionalBarButtons addObject:self.btnSearch];
    
    rect.origin.x += size.width + 20;
    self.btnDelete = [CommonLayout createImageButtonWithFrame:rect image:[UIImage imageNamed:@"delete_icon.png"] touchTarget:self touchSelector:@selector(handleDeleteButton:) superView:self.topButtonBar];
    [self.additionalBarButtons addObject:self.btnDelete];
}

- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    return 40;
}

- (void)enableToolbarButtons:(BOOL)enabled {
    [super enableToolbarButtons:enabled];
    self.topButtonBar.userInteractionEnabled = enabled;
}

#pragma mark - SetHighlightBottomCenterBarButton
- (void)setSelectedBottomCenterBarButton:(UIButton*)aButton {
    [super setSelectedBottomCenterBarButton:aButton];
    for (UIButton *button in self.additionalBarButtons) {
        if (button != aButton) {
            button.alpha = 1.0;
            button.userInteractionEnabled = YES;
        }
    }
}

#pragma mark - Button events
- (void)handleSearchButton:(id)sender {
    [super handleSearchButton:sender];
    [self moveViewToAboveKeyboard:self.currentPopupView isAbove:YES];
}

- (void)handleInfoButton:(id)sender {
    DocumentInfoViewController *target = [[DocumentInfoViewController alloc] initWithNibName:@"DocumentInfoViewController" bundle:[NSBundle mainBundle]];
    target.document = self.documentObj;
    [self.navigationController pushViewController:target animated:YES];
}

#pragma mark - Layout
- (float)topLabelHeight {
    return 40;
}

- (void)relayout {
    [super relayout];
    CGRect rect = self.lblDocumentInfo.frame;
    rect.size.width = self.topButtonBar.frame.origin.x - rect.origin.x;
    self.lblDocumentInfo.frame = rect;
}

@end
