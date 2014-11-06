//
//  DocumentSearchTextPopup.m
//  FileThis
//
//  Created by Cuong Le on 1/13/14.
//
//

#import "DocumentSearchTextPopup.h"
#import "BorderView.h"
#import "CommonLayout.h"
#import "DocumentSearchTextPopupCell.h"
#import "DocumentSearchCriteriaManager.h"
#import "NSString+Custom.h"

@interface DocumentSearchTextPopup() <UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) BorderView *headerView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UICollectionView *textCollectionView, *cabinetCollectionView, *tagCollectionView;
@property (nonatomic, strong) UITableView *myTable;
@property (nonatomic, assign) id<DocumentSearchTextPopupDelegate> delegate;

@property (nonatomic, strong) NSMutableArray *filteredTexts, *filteredCabinets, *filteredTags;

@end

@implementation DocumentSearchTextPopup

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<DocumentSearchTextPopupDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        
        self.headerView = [[BorderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.height, 45) borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0, 0, 0, 1) superView:self];
        self.headerView.backgroundColor = kBackgroundLightGrayColor;
        self.headerLabel = [CommonLayout createLabel:CGRectInset(self.headerView.bounds, kDocumentSearchTextPopupCell_ContentInset, 2) fontSize:FontSizeSmall isBold:NO isItalic:YES textColor:kTextGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_TAP_TO_SELECT", @"") superView:self.headerView];
        [self.headerLabel autoWidth];
        
        self.myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, [self.headerView bottom], self.frame.size.width, self.frame.size.height - [self.headerView bottom]-1)];
        self.myTable.rowHeight = kDocumentSearchTextPopup_RowHeight;
        self.myTable.separatorColor = kBorderLightGrayColor;
        self.myTable.backgroundColor = [UIColor whiteColor];
        self.myTable.delegate = self;
        self.myTable.dataSource = self;
        self.myTable.scrollEnabled = NO;
        self.myTable.allowsSelection = NO;
        [self addSubview:self.myTable];
        
        [superView addSubview:self];
    }
    return self;
}

- (void)relayout {
    [super relayout];
    [self.headerView setRightWithoutChangingLeft:self.frame.size.width];
    [self.myTable setRightWithoutChangingLeft:self.frame.size.width bottomWithoutChangingTop:self.frame.size.height-1];
}

#pragma mark - Table
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case 0:
            if ([self.filteredTexts count] == 0) {
                return 0;
            }
            break;
            
        case 1:
            if ([self.filteredCabinets count] == 0) {
                return 0;
            }
            break;
            
        default:
            if ([self.filteredTags count] == 0) {
                return 0;
            }
            break;
    }
    return kDocumentSearchTextPopup_RowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"menuCell";
    
    DocumentSearchTextPopupCell *cell = (DocumentSearchTextPopupCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DocumentSearchTextPopupCell alloc] initWithReuseIdentifier:cellIdentifier tableView:tableView cellIndex:indexPath.row collectionDelegate:self];
    }
    [cell.myCollectionView reloadData];
    return cell;
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    switch (collectionView.tag) {
        case 0:
            return [self.filteredTexts count];
            
        case 1:
            return [self.filteredCabinets count];
            
        default:
            return [self.filteredTags count];
    }
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[@"DocumentSearchTextPopupCell" stringByAppendingFormat:@"%i",collectionView.tag] forIndexPath:indexPath];
    
    NSArray *textAndBackgroundType = [self getTextAndBackgroundTypeForRowIndexPath:indexPath collectionViewIndex:collectionView.tag];
    if (textAndBackgroundType)
        [cell setText:[textAndBackgroundType objectAtIndex:0] backgroundType:[[textAndBackgroundType objectAtIndex:1] integerValue]];

    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *textAndBackgroundType = [self getTextAndBackgroundTypeForRowIndexPath:indexPath collectionViewIndex:collectionView.tag];
    if (textAndBackgroundType)
        return [TagCollectionCell fitSizeForText:[textAndBackgroundType objectAtIndex:0] backgroundType:[[textAndBackgroundType objectAtIndex:1] integerValue] maxWidth:220];
    
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    switch (collectionView.tag) {
        case 0:
            if (indexPath.row < [self.filteredTexts count]) {
                [self.delegate documentSearchTextPopup:self textSelected:[self.filteredTexts objectAtIndex:indexPath.row]];
            }
            break;
            
        case 1:
            if (indexPath.row < [self.filteredCabinets count]) {
                [self.delegate documentSearchTextPopup:self cabinetSelected:[self.filteredCabinets objectAtIndex:indexPath.row]];
            }
            break;
            
        default:
            if (indexPath.row < [self.filteredTags count]) {
                [self.delegate documentSearchTextPopup:self tagSelected:[self.filteredTags objectAtIndex:indexPath.row]];
            }
            break;
    }
}

- (NSArray*)getTextAndBackgroundTypeForRowIndexPath:(NSIndexPath*)indexPath collectionViewIndex:(int)collectionViewIndex {
    NSString *text = nil;
    TagCollectionCellBackgroundType backgroundType = TagCollectionCellBackgroundTypeClear;
    switch (collectionViewIndex) {
        case 0:
            if (indexPath.row < [self.filteredTexts count]) {
                text = [self.filteredTexts objectAtIndex:indexPath.row];
                backgroundType = TagCollectionCellBackgroundTypeText;
            }
            break;
        case 1:
            if (indexPath.row < [self.filteredCabinets count]) {
                text = ((CabinetObject*)[self.filteredCabinets objectAtIndex:indexPath.row]).name;
                backgroundType = TagCollectionCellBackgroundTypeCabinet;
            }
            break;
        default:
            if (indexPath.row < [self.filteredTags count]) {
                text = ((TagObject*)[self.filteredTags objectAtIndex:indexPath.row]).name;
                backgroundType = TagCollectionCellBackgroundTypeTagWhite;
            }
            break;
    }
    
    if (text)
        return [NSArray arrayWithObjects:text,[NSNumber numberWithInt:backgroundType],nil];
    
    return nil;
}

- (void)setSearchedString:(NSString*)aString {
    self.filteredTexts = [[NSMutableArray alloc] init];
    NSArray *allRecentTexts = [DocumentSearchCriteriaManager getInstance].recentDocumentSearchStringList;
    for (NSString *text in allRecentTexts) {
        if ([text rangeOfStringSearchByWord:aString].location != NSNotFound) {
            [self.filteredTexts addObject:text];
        }
    }
    [self.filteredTexts sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2 options:NSCaseInsensitiveSearch];
    }];
    
    self.filteredCabinets = [[NSMutableArray alloc] init];
    NSArray *allCabinets = [[CabinetDataManager getInstance] getCabinetsForSearching];
    for (CabinetObject *cabinet in allCabinets) {
        if ([cabinet.name rangeOfStringSearchByWord:aString].location != NSNotFound) {
            [self.filteredCabinets addObject:cabinet];
        }
    }
    
    self.filteredTags = [[NSMutableArray alloc] init];
    NSArray *allTags = [[TagDataManager getInstance] getNonEmptyTags];
    for (TagObject *tag in allTags) {
        if ([tag.name rangeOfStringSearchByWord:aString].location != NSNotFound) {
            [self.filteredTags addObject:tag];
        }
    }
    
    [self.myTable reloadData];
    
    float height = [self.headerView bottom];
    if ([self.filteredTexts count] > 0)
        height += kDocumentSearchTextPopup_RowHeight;
    
    if ([self.filteredCabinets count] > 0)
        height += kDocumentSearchTextPopup_RowHeight;
    
    if ([self.filteredTags count] > 0)
        height += kDocumentSearchTextPopup_RowHeight;
    
    [self setHeight:height + 1];
    [self relayout];
}

- (BOOL)isEmptyData {
    if ([self.filteredTexts count] > 0)
        return NO;
    
    if ([self.filteredCabinets count] > 0)
        return NO;
    
    if ([self.filteredTags count] > 0)
        return NO;
    
    return YES;
}
@end
