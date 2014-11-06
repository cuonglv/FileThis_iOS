//
//  DocumentRecentSearchView.m
//  FileThis
//
//  Created by Cuong Le on 1/11/14.
//
//

#import "DocumentRecentSearchView.h"
#import "DocumentRecentSearchCell.h"
#import "DocumentSearchCriteriaManager.h"

#define kDocumentRecentSearchView_AlertTag_ClearRecent  1

@interface DocumentRecentSearchView() <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) BorderView *headerView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UITableView *myTable;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) UIButton *clearRecentButton;
@end

@implementation DocumentRecentSearchView

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<DocumentRecentSearchViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        
        self.headerView = [[BorderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kDocumentSearchView_SearchByHeaderViewHeight) borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0, 0, 0, 1) superView:self];
        self.headerView.backgroundColor = kDocumentSearchView_SearchByDateViewBackColor;
        
        self.headerLabel = [CommonLayout createLabel:CGRectMake(kDocumentSearchView_MarginLeft, 0, 300, self.headerView.frame.size.height) fontSize:FontSizeSmall isBold:NO isItalic:YES textColor:kDocumentSearchView_TextColor backgroundColor:nil text:NSLocalizedString(@"ID_RECENT_SEARCH", @"") superView:self.headerView];
        [self.headerLabel autoWidth];
        
        self.clearRecentButton = [CommonLayout createTextButton:CGRectMake(self.headerView.frame.size.width - 110, 0, 100, self.headerView.frame.size.height) fontSize:FontSizeMedium isBold:NO text:NSLocalizedString(@"ID_CLEAR", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleClearRecentButton) superView:self.headerView];
        [self.clearRecentButton autoWidth];
        
        self.myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, [self.headerView bottom], self.frame.size.width, self.frame.size.height - [self.headerView bottom])];
        self.myTable.backgroundColor = [UIColor whiteColor];
        self.myTable.rowHeight = 45.0;
        self.myTable.separatorColor = kBorderLightGrayColor;
        self.myTable.delegate = self;
        self.myTable.dataSource = self;
        self.myTable.scrollEnabled = YES;
        [self addSubview:self.myTable];
        
        [superView addSubview:self];
        
        [self reloadData];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.headerView setRightWithoutChangingLeft:self.frame.size.width];
    [self.clearRecentButton setRight:self.headerView.frame.size.width-10];
    [self.myTable setRightWithoutChangingLeft:self.frame.size.width bottomWithoutChangingTop:self.frame.size.height];
    [self.myTable reloadData];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.items count];
}

static NSString *cellIdentifier = @"DocumentRecentSearchCell";

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.items count])
        return [DocumentRecentSearchCell heightForCellWithCriteria:[self.items objectAtIndex:indexPath.row] reuseId:cellIdentifier tableView:tableView];
    
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    DocumentRecentSearchCell *cell = (DocumentRecentSearchCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DocumentRecentSearchCell alloc] initWithReuseIdentifier:cellIdentifier tableView:tableView];
    }
    [cell setDocumentSearchCriteria:[self.items objectAtIndex:indexPath.row]];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.items count])
        [self.delegate documentRecentSearchView:self touchItem:[self.items objectAtIndex:indexPath.row]];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kDocumentRecentSearchView_AlertTag_ClearRecent) {
        if (buttonIndex == 0) {
            [[DocumentSearchCriteriaManager getInstance] clearRecentList];
            [self reloadData];
        }
    }
}

#pragma mark - Button
- (void)handleClearRecentButton {
    [CommonLayout showConfirmAlert:NSLocalizedString(@"ID_CONFIRM_CLEAR_RECENT_SEARCH_LIST", @"") tag:kDocumentRecentSearchView_AlertTag_ClearRecent delegate:self];
}

#pragma mark - MyFunc
- (void)goToNextScreen {
}

- (void)reloadData {
    self.items = [DocumentSearchCriteriaManager getInstance].recentDocumentSearchCriteriaList;
    [self.myTable reloadData];
}

- (void)removeInvalidData {
    for (int i = [self.items count]-1; i >= 0; i--) {
        DocumentSearchCriteria *criteria = [self.items objectAtIndex:i];
        [criteria removeInvalidData];
        if ([criteria isEmpty]) {
            [self.items removeObject:criteria];
        }
    }
    [self.myTable reloadData];
}
@end
