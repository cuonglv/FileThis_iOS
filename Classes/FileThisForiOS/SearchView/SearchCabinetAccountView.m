//
//  SearchCabinetAccountView.m
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//

#import "SearchCabinetAccountView.h"
#import "CheckmarkCell.h"

@interface SearchCabinetAccountView() <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UILabel *searchInLabel;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) UITableView *myTable;
@property (nonatomic, strong) NSMutableArray *items;
@property (assign) BOOL isShowingCabinets;
@property (nonatomic, strong) UIButton *doneButton; //iPhone only
@end

@implementation SearchCabinetAccountView

- (id)initWithFrame:(CGRect)frame borderColor:(UIColor *)bordercolor borderWidths:(Offset)borderwidths superView:(UIView *)superView delegate:(id<SearchCabinetAccountViewDelegate, SearchComponentViewDelegate>)delegate {
    if (self = [super initWithFrame:frame borderColor:bordercolor borderWidths:borderwidths superView:superView]) {
        self.delegate = delegate;
        
        self.headerView = [[BorderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kDocumentSearchView_SearchByHeaderViewHeight) borderColor:bordercolor borderWidths:OffsetMake(0, 0, 0, 1) superView:self];
        self.headerView.backgroundColor = kDocumentSearchView_SearchByDateViewBackColor;
        
        self.searchInLabel = [CommonLayout createLabel:CGRectMake(kDocumentSearchView_MarginLeft, 0, kDocumentSearchView_SearchByLabelWidth, self.headerView.frame.size.height) font:kDocumentSearchView_HeaderFont textColor:kDocumentSearchView_TextColor backgroundColor:nil text:NSLocalizedString(@"ID_SEARCH_IN_UPPERCASE", @"") superView:self.headerView];
        
        CGRect segmentControlFrame;
        FontSize segmentControlFontSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.searchInLabel autoWidth];
            segmentControlFrame = [self.searchInLabel rectAtRight:10 width:150 height:30];
            segmentControlFontSize = FontSizexSmall;
            self.doneButton = [CommonLayout createTextButton:CGRectMake(self.frame.size.width - 60, kDocumentSearchView_SearchByHeaderViewHeight / 2 - 15, 50, 30) font:[CommonLayout getFont:FontSizexSmall isBold:YES] text:NSLocalizedString(@"ID_DONE", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleDoneButton) superView:self];
        } else {
            segmentControlFrame = CGRectMake([self.searchInLabel right], self.headerView.frame.size.height / 2-15, roundf(self.headerView.frame.size.width - [self.searchInLabel right] - kDocumentSearchView_MarginRight), 30);
            segmentControlFontSize = FontSizeSmall;
        }
        self.segmentControl = [CommonLayout createSegmentControl:segmentControlFrame texts:[NSArray arrayWithObjects:NSLocalizedString(@"ID_CABINET", @""), NSLocalizedString(@"ID_ACCOUNT", @""), nil] font:[CommonLayout getFont:segmentControlFontSize isBold:NO] tintColor:kTextOrangeColor target:self selector:@selector(handleSegmentControl:) superView:self.headerView];
        self.segmentControl.selectedSegmentIndex = 0;
        self.isShowingCabinets = YES;
        
        self.myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, [self.headerView bottom], self.frame.size.width, self.frame.size.height - [self.headerView bottom]-1)];
        self.myTable.rowHeight = 50.0;
        self.myTable.separatorColor = kBorderLightGrayColor;
        self.myTable.backgroundColor = [UIColor whiteColor];
        self.myTable.delegate = self;
        self.myTable.dataSource = self;
        [self addSubview:self.myTable];
        
        [self updateUI];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.myTable.frame = CGRectMake(0, [self.headerView bottom], self.frame.size.width, self.frame.size.height - [self.headerView bottom]-1);
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"cabinetCell";
    
    CheckmarkCell *cell = (CheckmarkCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[CheckmarkCell alloc] initWithReuseIdentifier:cellIdentifier font:kDocumentSearchView_Font textColor:kTextGrayColor highlightColor:kTextOrangeColor leftMargin:kDocumentSearchView_MarginLeft rightMargin:20 tableView:tableView];
    }
    if (indexPath.row < [self.items count]) {
        CabinetProfileBaseObject *obj = (CabinetProfileBaseObject*)[self.items objectAtIndex:indexPath.row];
        NSString *rightText;
        if (self.selectedCabinet || self.selectedProfile)
            rightText = @"";
        else {
            if (self.isShowingCabinets && self.filteredCabIdsAndDocCountsByDate) {
                NSNumber *docCount = [self.filteredCabIdsAndDocCountsByDate objectForKey:obj.id];
                if (docCount)
                    rightText = [docCount stringValue];
                else
                    rightText = @"";
            } else if (!self.isShowingCabinets && self.filteredProfIdsAndDocCountsByDate) {
                NSNumber *docCount = [self.filteredProfIdsAndDocCountsByDate objectForKey:obj.id];
                if (docCount)
                    rightText = [docCount stringValue];
                else
                    rightText = @"";
            } else
                rightText = [obj.docCount stringValue];
        }
        [cell setText:obj.name rightText:rightText selected:(obj == self.selectedCabinet || obj == self.selectedProfile) textColor:([obj isSpecialType] ? kMaroonColor : kTextGrayColor)];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.items count]) {
        if (self.isShowingCabinets) {
            self.selectedProfile = nil;
            CabinetObject *cabObj = [self.items objectAtIndex:indexPath.row];
            if (self.selectedCabinet == cabObj) //currently selected, need to deselect
                self.selectedCabinet = nil;
            else    //not yet selected, need to select
                self.selectedCabinet = cabObj;
            
            [self.delegate searchCabinetAccountView_SelectedItemChanged:self];
        } else {
            self.selectedCabinet = nil;
            ProfileObject *obj = [self.items objectAtIndex:indexPath.row];
            if (self.selectedProfile == obj) //currently selected, need to deselect
                self.selectedProfile = nil;
            else    //not yet selected, need to select
                self.selectedProfile = obj;
            
            [self.delegate searchCabinetAccountView_SelectedItemChanged:self];
        }
    }
    [self.myTable reloadData];
}

#pragma mark - ButtonGroupDelegate
- (void)handleSegmentControl:(id)sender {
    self.selectedCabinet = nil;
    self.selectedProfile = nil;
    self.isShowingCabinets = ([self.segmentControl selectedSegmentIndex] == 0);
    [self updateUI];
    [self.delegate searchCabinetAccountView_SelectedItemChanged:self];
}

#pragma mark - MyFunc
- (void)updateUI {
    if (self.isShowingCabinets) {
        self.items = [NSMutableArray arrayWithArray:[[CabinetDataManager getInstance] getCabinetsForSearching]];
        if (self.filteredCabIdsAndDocCountsByDate) {
            NSArray *filterdCabIds = [self.filteredCabIdsAndDocCountsByDate allKeys];
            for (int i = [self.items count] - 1; i >= 0; i--) {
                CabinetObject *cabObj = [self.items objectAtIndex:i];
                if (![filterdCabIds containsObject:cabObj.id])
                    [self.items removeObjectAtIndex:i];
            }
        }
        if (self.selectedCabinet)
            if (![self.items containsObject:self.selectedCabinet])
                self.selectedCabinet = nil;
    } else {
        self.items = [[NSMutableArray alloc] initWithArray:[[ProfileDataManager getInstance] getAllProfiles]];
        if (self.selectedProfile)
            if (![self.items containsObject:self.selectedProfile])
                self.selectedProfile = nil;
    }
    [self.myTable reloadData];
}

- (void)selectCabinet:(CabinetObject*)aCabinet profile:(ProfileObject*)aProfile {
    self.selectedCabinet = aCabinet;
    self.selectedProfile = aProfile;
    self.segmentControl.selectedSegmentIndex = (self.selectedProfile ? 1 : 0);
    [self updateUI];
}

- (void)setFilteredCabIdsAndDocCountsByDate:(NSMutableDictionary*)dict1 filteredProfIdsAndDocCountsByDate:(NSMutableDictionary*)dict2 {
    self.filteredCabIdsAndDocCountsByDate = dict1;
    self.filteredProfIdsAndDocCountsByDate = dict2;
    [self updateUI];
}

#pragma mark - Button
- (void)handleDoneButton {
    if ([self.delegate respondsToSelector:@selector(searchComponentView_shouldClose:)])
        [self.delegate searchComponentView_shouldClose:self];
}
@end
