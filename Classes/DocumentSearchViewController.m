//
//  DocumentSearchViewController.m
//  FileThis
//
//  Created by Cuong Le on 12/18/13.
//
//

#import "DocumentSearchViewController.h"


@interface DocumentSearchViewController ()

@end

@implementation DocumentSearchViewController

- (void)initializeScreen {
    [super initializeScreen];
    self.loadingView = [[LoadingView alloc] init];
    if (![[CommonDataManager getInstance] isCommonDataAvailableWithKey:DATA_COMMON_KEY]) {
        [[CommonDataManager getInstance] reloadCommonDataWithKey:DATA_COMMON_KEY];
    } else {
        [self initScreenWithData];
    }
}

- (void)initScreenWithData {
    self.contentView.backgroundColor = [UIColor whiteColor];
    
    //Search text
    self.searchTextField = [CommonLayout createTextField:CGRectInset(self.titleLabel.frame, 200, 10) fontSize:FontSizeSmall isBold:NO textColor:[UIColor blackColor] backgroundColor:nil text:@"" superView:self.topBarView];
    self.searchTextField.placeholder = @"Type to search for documents";
    self.searchTextField.leftView = [CommonLayout createImageView:CGRectMake(0, 5, 40, 20) image:[UIImage imageNamed:@"search_icon_small.png"] contentMode:UIViewContentModeCenter superView:nil];
    self.searchTextField.leftViewMode = UITextFieldViewModeAlways;
    self.searchTextField.returnKeyType = UIReturnKeyDone;
    self.searchTextField.delegate = self;
    
    self.leftPanelView = [[BorderView alloc] initWithFrame:CGRectMake(0, 0, kDocumentSearchView_SearchByDateViewWidth, self.contentView.frame.size.height) borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0,1,0,0) superView:self.contentView];
    
    self.searchByDateView = [[SearchByDateView alloc] initWithFrame:[self frameForDateView] borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0,0,0,1) superView:self.leftPanelView];
    self.searchByDateView.delegate = self;
    
    self.searchCabinetAccountView = [[SearchCabinetAccountView alloc] initWithFrame:[self frameForCabinetView] borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0,0,0,1) superView:self.leftPanelView delegate:self];
    
    self.searchTagsView = [[SearchTagsView alloc] initWithFrame:[self frameForTagsView] superView:self.leftPanelView delegate:self];
    
    self.searchCriteriaView = [[DocumentSearchCriteriaView alloc] initWithFrame:CGRectMake([self.leftPanelView right], 0, self.contentView.frame.size.width - [self.leftPanelView right], self.contentView.frame.size.height) superView:self.contentView delegate:self];
    self.searchCriteriaView.hidden = YES;
    
    self.documentRecentSearchView = [[DocumentRecentSearchView alloc] initWithFrame:CGRectMake([self.leftPanelView right], 0, self.contentView.frame.size.width - [self.leftPanelView right], self.contentView.frame.size.height) superView:self.contentView delegate:self];
    
    self.darkenOverlayView = [[UIView alloc] initWithFrame:self.contentView.frame];
    self.darkenOverlayView.backgroundColor = [UIColor blackColor];
    self.darkenOverlayView.alpha = 0.5f;
    [self.view addSubview:self.darkenOverlayView];
    self.darkenOverlayView.hidden = YES;
    
    self.documentSearchTextPopup = [[DocumentSearchTextPopup alloc] initWithFrame:[self.topBarView rectAtBottom:0 height:kDocumentSearchTextPopup_HearderHeight+3*kDocumentSearchTextPopup_RowHeight+1] superView:self.view delegate:self];
    self.documentSearchTextPopup.hidden = YES;
    
    [[EventManager getInstance] addListener:self channel:CHANNEL_DATA];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.searchCriteriaView.documentSearchCriteria removeInvalidData];
    [self.searchCriteriaView.documentSearchCriteria updateRelatedDocumentsAndTags];
    [self.searchCriteriaView updateUI];
    
    [self.searchCabinetAccountView updateUI];
    
    [self.searchTagsView removeInvalidData];
    [self.searchTagsView updateUI];
    
    [self.documentRecentSearchView removeInvalidData];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.searchByDateView dismissPopopover];
    [super viewWillDisappear:animated];
}

- (void)relayout {
    [super relayout];
    self.searchTextField.frame = CGRectInset(self.titleLabel.frame, 130, 6);
    
    [self.leftPanelView setHeight:self.contentView.frame.size.height];
    float height = roundf((self.contentView.frame.size.height - self.searchByDateView.frame.size.height) * 0.5);
    [self.searchCabinetAccountView setHeight:height];
    [self.searchTagsView setTop:[self.searchCabinetAccountView bottom] bottom:self.leftPanelView.frame.size.height];
    
    [self.documentRecentSearchView setRightWithoutChangingLeft:self.contentView.frame.size.width bottomWithoutChangingTop:self.contentView.frame.size.height];
    [self.searchCriteriaView setRightWithoutChangingLeft:self.contentView.frame.size.width bottomWithoutChangingTop:self.contentView.frame.size.height];
    self.darkenOverlayView.frame = self.contentView.frame;
    [self.documentSearchTextPopup setRightWithoutChangingLeft:self.view.frame.size.width];
}

- (BOOL)shouldUseBackButton {
    return YES;
}

- (CGRect)frameForDateView {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return CGRectMake(0, self.contentView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    return CGRectMake(0, 0, self.leftPanelView.frame.size.width-1, kDocumentSearchView_SearchByDateViewHeight);
}

- (CGRect)frameForCabinetView {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return CGRectMake(0, self.contentView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    return [self.searchByDateView rectAtBottom:0 height:kDocumentSearchView_SearchCabinetViewHeight];
}

- (CGRect)frameForTagsView {
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        return CGRectMake(0, self.contentView.frame.size.height, self.contentView.frame.size.width, self.contentView.frame.size.height);
    
    return CGRectMake(0, [self.searchCabinetAccountView bottom], self.leftPanelView.frame.size.width-1, self.leftPanelView.frame.size.height - [self.searchCabinetAccountView bottom]);
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if ([newText length] > 0) {
        [self.documentSearchTextPopup setSearchedString:newText];
        [self setTextPopupVisible:![self.documentSearchTextPopup isEmptyData]];
    } else {
        [self setTextPopupVisible:NO];
    }
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self setTextPopupVisible:NO];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    NSString *text = [textField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([text length] > 0) {
        [text insertIntoOrderedArray:self.searchCriteriaView.documentSearchCriteria.texts];
        [self.searchCriteriaView updateUI];
        self.searchCriteriaView.hidden = NO;
        self.documentRecentSearchView.hidden = YES;
    }
    [textField resignFirstResponder];
    [self setTextPopupVisible:NO];
    textField.text = @"";
    return YES;
}

#pragma mark - Button
- (void)handleNextButton {
    if ([self.searchCriteriaView.documentSearchCriteria isEmpty]) {
        [CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_ENTER_SEARCH_CRITERIA", @"") errorMessage:nil delegate:nil];
        return;
    }
    
    DocumentSearchCriteria *criteria = [[DocumentSearchCriteria alloc] init];
    criteria.date1 = [self.searchCriteriaView.documentSearchCriteria.date1 copy];
    criteria.date2 = [self.searchCriteriaView.documentSearchCriteria.date2 copy];
    criteria.texts = [[NSMutableArray alloc] initWithArray:self.searchCriteriaView.documentSearchCriteria.texts copyItems:YES];
    if ((criteria.cabinet = self.searchCriteriaView.documentSearchCriteria.cabinet))
        criteria.cabinetId = self.searchCriteriaView.documentSearchCriteria.cabinet.id;
    if ((criteria.profile = self.searchCriteriaView.documentSearchCriteria.profile))
        criteria.profileId = self.searchCriteriaView.documentSearchCriteria.profile.id;
    
    NSMutableArray *tagIds = [[NSMutableArray alloc] init];
    for (TagObject *tagObj in self.searchCriteriaView.documentSearchCriteria.tags) {
        [tagIds addObject:tagObj.id];
    }
    criteria.tagIds = tagIds;
    criteria.tags = self.searchCriteriaView.documentSearchCriteria.tags;
    
    SearchResultDocumentListViewController *target;
    target = [[SearchResultDocumentListViewController alloc] initWithNibName:@"DocumentListViewController" bundle:[NSBundle mainBundle]];
    target.documentSearchCriteria = criteria;
    [self performSelector:@selector(goToNextScreen:) withObject:target afterDelay:0.2]; //to see search criteria list refreshed (updated)
    
    //save search criteria for recent list
    [[DocumentSearchCriteriaManager getInstance] saveCriteria:criteria];
    [self.documentRecentSearchView reloadData];
}

- (void)goToNextScreen:(id)target {
    [self.navigationController pushViewController:target animated:YES];
}


#pragma mark - SearchComponentViewDelegate
- (void)searchComponentView_shouldClose:(id)sender {
    // TODO in children
}

#pragma mark - SearchByDateViewDelegate
- (void)searchByDateView_ValueChanged:(id)sender date1:(NSDateComponents *)dateComps1 date2:(NSDateComponents *)dateComps2 {
    self.searchCriteriaView.documentSearchCriteria.date1 = dateComps1;
    self.searchCriteriaView.documentSearchCriteria.date2 = dateComps2;
    self.searchCriteriaView.hidden = NO;
    self.documentRecentSearchView.hidden = YES;
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeUpdateFilteredDocObjsByDateCabProf:threadObj:) argument: ^ {
        [self.searchCriteriaView.documentSearchCriteria updateFilteredCabProfIdsAndDocCountsByDate];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.searchCabinetAccountView setFilteredCabIdsAndDocCountsByDate:self.searchCriteriaView.documentSearchCriteria.filteredCabIdsAndDocCountsByDate filteredProfIdsAndDocCountsByDate:self.searchCriteriaView.documentSearchCriteria.filteredProfIdsAndDocCountsByDate];
        });
    }];
}

#pragma mark - SearchCabinetAccountViewDelegate
- (void)searchCabinetAccountView_SelectedItemChanged:(id)sender {
    self.documentRecentSearchView.hidden = YES;
    self.searchCriteriaView.documentSearchCriteria.cabinet = self.searchCabinetAccountView.selectedCabinet;
    self.searchCriteriaView.documentSearchCriteria.profile = self.searchCabinetAccountView.selectedProfile;
    self.searchCriteriaView.hidden = NO;
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeUpdateFilteredDocObjsByDateCabProf:threadObj:) argument: ^ {
        if (self.searchCabinetAccountView.selectedCabinet || self.searchCabinetAccountView.selectedProfile) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                [self searchComponentView_shouldClose:self.searchCabinetAccountView];
            });
        }
    }];
}

#pragma mark - SearchTagsViewDelegate
- (void)searchTagsView:(id)sender selectedItemsChanged:(NSMutableArray *)selectedItems {
    self.searchCriteriaView.documentSearchCriteria.tags = selectedItems;
    self.searchCriteriaView.hidden = NO;
    self.documentRecentSearchView.hidden = YES;
    [self.searchCriteriaView updateUI];
}

#pragma mark - DocumentSearchCriteriaViewDelegate
- (void)documentSearchCriteriaView_removedSearchText:(id)sender {
    self.searchTextField.text = @"";
}

- (void)documentSearchCriteriaView_removedDate:(id)sender {
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeUpdateFilteredDocObjsByDateCabProf:threadObj:) argument: ^ {
        self.searchCriteriaView.documentSearchCriteria.filteredCabIdsAndDocCountsByDate = nil;
        self.searchCriteriaView.documentSearchCriteria.filteredProfIdsAndDocCountsByDate = nil;
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.searchCabinetAccountView setFilteredCabIdsAndDocCountsByDate:nil filteredProfIdsAndDocCountsByDate:nil];
            [self.searchByDateView setDate1:nil date2:nil];
        });
    }];
}

- (void)documentSearchCriteriaView_removedCabinetOrProfile:(id)sender {
    self.searchCabinetAccountView.selectedCabinet = nil;
    self.searchCabinetAccountView.selectedProfile = nil;
    [self.searchCabinetAccountView updateUI];
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeUpdateFilteredDocObjsByDateCabProf:threadObj:) argument: ^ {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.searchCabinetAccountView updateUI];
        });
    }];
}

- (void)documentSearchCriteriaView_removedTag:(id)sender newTags:(NSMutableArray *)newTags {
    self.searchTagsView.selectedItems = self.searchCriteriaView.documentSearchCriteria.tags;
    [self.searchTagsView updateUI];
}

- (void)documentSearchCriteriaView_addedTag:(id)sender newTags:(NSMutableArray *)newTags {
    self.searchTagsView.selectedItems = self.searchCriteriaView.documentSearchCriteria.tags;
    [self.searchTagsView updateUI];
}

- (void)documentSearchCriteriaView_didBecomeEmpty:(id)sender {
    self.documentRecentSearchView.hidden = NO;
    [self.documentRecentSearchView reloadData];
    self.searchCriteriaView.hidden = YES;
}

- (void)documentSearchCriteriaView_searchNow:(id)sender {
    [self handleNextButton];
}

#pragma mark - DocumentRecentSearchViewDelegate
- (void)documentRecentSearchView:(id)sender touchItem:(DocumentSearchCriteria *)documentSearchCriteria {
    [self performSelector:@selector(updateUIfromSearchCriteria:) withObject:documentSearchCriteria afterDelay:0.2]; //to see selection effect
}

#pragma mark - DocumentSearchTextPopupDelegate
- (void)documentSearchTextPopup:(id)sender textSelected:(NSString *)text {
    self.searchTextField.text = text;
    [self textFieldShouldReturn:self.searchTextField];
    [self setTextPopupVisible:NO];
    [self.searchTextField endEditing:YES];
}

- (void)documentSearchTextPopup:(id)sender cabinetSelected:(CabinetObject *)cabinet {
    self.searchTextField.text = @"";
    [self.searchCabinetAccountView selectCabinet:cabinet profile:nil];
    [self searchCabinetAccountView_SelectedItemChanged:self.searchCabinetAccountView];
    [self setTextPopupVisible:NO];
    [self.searchTextField endEditing:YES];
}

- (void)documentSearchTextPopup:(id)sender tagSelected:(TagObject *)tag {
    self.searchTextField.text = @"";
    if (![self.searchTagsView.selectedItems containsObject:tag]) {
        [self.searchTagsView.selectedItems addObject:tag];
    }
    [self searchTagsView:self.searchTagsView selectedItemsChanged:self.searchTagsView.selectedItems];
    [self setTextPopupVisible:NO];
    [self.searchTextField endEditing:YES];
}

#pragma mark - ExecuteData
- (void)executeUpdateFilteredDocObjsByDateCabProf:(id)arg threadObj:(id<ThreadProtocol>)threadObj {
    if ([threadObj isCancelled]) {
        [threadObj releaseOperation];
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.loadingView startLoadingInView:self.view frame:self.contentView.frame];
    });
    
    [self.searchCriteriaView.documentSearchCriteria updateFilteredDocObjsByDateCabProf];
    
    void (^ block) () = arg;
    block();
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [self.loadingView stopLoading];
        [self.searchCriteriaView updateUI];
        [self.searchTagsView setFilteredTagIdsAndDocCountsByDateCabinetProfile:self.searchCriteriaView.documentSearchCriteria.filteredTagIdsAndDocCountsByDateCabProf];
    });
    
    [threadObj releaseOperation];
}

#pragma mark - MyFunc
- (void)updateUIfromSearchCriteria:(DocumentSearchCriteria*)criteria {
    self.documentRecentSearchView.hidden = YES;
    
    [self.searchByDateView setDate1:criteria.date1 date2:criteria.date2];
    
    [self.searchCabinetAccountView selectCabinet:criteria.cabinet profile:criteria.profile];
    
    self.searchTagsView.selectedItems = criteria.tags;
    [self.searchTagsView updateUI];
    
    self.searchCriteriaView.documentSearchCriteria = [criteria copy];
    self.searchCriteriaView.hidden = NO;
    [self.searchCriteriaView updateUI];
    
    [[ThreadManager getInstance] dispatchToNormalThreadWithTarget:self selector:@selector(executeUpdateFilteredDocObjsByDateCabProf:threadObj:) argument: ^ {
        [self.searchCriteriaView.documentSearchCriteria updateFilteredCabProfIdsAndDocCountsByDate];
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [self.searchCabinetAccountView setFilteredCabIdsAndDocCountsByDate:self.searchCriteriaView.documentSearchCriteria.filteredCabIdsAndDocCountsByDate filteredProfIdsAndDocCountsByDate:self.searchCriteriaView.documentSearchCriteria.filteredProfIdsAndDocCountsByDate];
        });
    }];
}

- (void)setTextPopupVisible:(BOOL)visible {
    if (visible) {
        [self.view bringSubviewToFront:self.darkenOverlayView];
        [self.view bringSubviewToFront:self.documentSearchTextPopup];
    }
    self.contentView.userInteractionEnabled = !visible;
    self.bottomBarView.userInteractionEnabled = !visible;
    self.darkenOverlayView.hidden = self.documentSearchTextPopup.hidden = !visible;
}

#pragma mark - EventProtocol methods
- (void)didReceiveEvent:(Event *)event {
    EVENTTYPE eventType = [event getEventType];
    if (eventType == EVENT_TYPE_LOAD_COMMON_DATA) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self initScreenWithData];
        });
    }
}

@end
