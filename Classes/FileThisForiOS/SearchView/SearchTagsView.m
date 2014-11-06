//
//  SearchTagsView.m
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//

#import "SearchTagsView.h"
#import "CommonLayout.h"
#import "TagCollectionCell.h"
#import "TagDataManager.h"
#import "MyCollectionFlowLayout.h"

#define kSearchTagsViewMargin   15.0

@interface SearchTagsView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) BorderView *headerView;
@property (nonatomic, strong) UILabel *withTagsLabel;
@property (nonatomic, strong) UICollectionView *myCollectionView;
@property (nonatomic, strong) NSMutableArray *items;
@property (nonatomic, strong) NSMutableDictionary *filteredTagIdsAndDocCountsByDateCabProf;
@property (nonatomic, strong) UIButton *doneButton; //iPhone only
@end

@implementation SearchTagsView

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<SearchTagsViewDelegate, SearchComponentViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        
        self.headerView = [[BorderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 45.0) borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0, 0, 0, 1) superView:self];
        self.headerView.backgroundColor = kDocumentSearchView_SearchByDateViewBackColor;
        
        self.withTagsLabel = [CommonLayout createLabel:CGRectMake(kDocumentSearchView_MarginLeft, 0, kDocumentSearchView_SearchByLabelWidth, self.headerView.frame.size.height) font:kDocumentSearchView_HeaderFont textColor:kDocumentSearchView_TextColor backgroundColor:nil text:NSLocalizedString(@"ID_TAGS_UPPERCASE", @"") superView:self.headerView];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.doneButton = [CommonLayout createTextButton:CGRectMake(self.frame.size.width - 60, kDocumentSearchView_SearchByHeaderViewHeight / 2 -  15, 50, 30) font:[CommonLayout getFont:FontSizexSmall isBold:YES] text:NSLocalizedString(@"ID_DONE", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleDoneButton) superView:self];
        }
        
        self.myCollectionView = [CommonLayout createCollectionView:CGRectMake(kSearchTagsViewMargin,[self.headerView bottom]+kSearchTagsViewMargin, self.frame.size.width-kSearchTagsViewMargin-4, self.frame.size.height-[self.headerView bottom]-kSearchTagsViewMargin) backgroundColor:kClearColor layout:[[LeftAlignedCollectionViewFlowLayout alloc] init] cellClass:[TagCollectionCell class] cellIdentifier:kDocumentSearchView_TagCollectionCellIdentifier superView:self delegateDataSource:self];
        self.myCollectionView.allowsSelection = YES;
        self.myCollectionView.scrollEnabled = YES;
        
        self.items = [NSMutableArray arrayWithArray:[[TagDataManager getInstance] getNonEmptyTags]];
        self.selectedItems = [[NSMutableArray alloc] init];
        
        [superView addSubview:self];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.myCollectionView setRightWithoutChangingLeft:self.frame.size.width-4 bottomWithoutChangingTop:self.frame.size.height-10];
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self.items count];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentSearchView_TagCollectionCellIdentifier forIndexPath:indexPath];
    if (indexPath.row < [self.items count]) {
        TagObject *tagObject = [self.items objectAtIndex:indexPath.row];
        TagCollectionCellBackgroundType backgroundType;
        NSString *rightText;
        if ([self.selectedItems count] > 0) {
            rightText = @"";
            if ([self.selectedItems containsObject:tagObject])
                backgroundType = TagCollectionCellBackgroundTypeTagOrange;
            else
                backgroundType = TagCollectionCellBackgroundTypeTagWhite;
        } else {
            if (self.filteredTagIdsAndDocCountsByDateCabProf) {
                NSNumber *docCount = [self.filteredTagIdsAndDocCountsByDateCabProf objectForKey:tagObject.id];
                if (docCount)
                    rightText = [docCount stringValue];
                else
                    rightText = @"";
            } else
                rightText = [tagObject.docCount stringValue];
            
            backgroundType = TagCollectionCellBackgroundTypeTagWhiteWithTail;
        }
        [cell setText:tagObject.name rightText:rightText backgroundType:backgroundType];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.items count]) {
        TagObject *tagObject = [self.items objectAtIndex:indexPath.row];
        TagCollectionCellBackgroundType backgroundType;
        if ([self.selectedItems count] > 0) {
            if ([self.selectedItems containsObject:tagObject])
                backgroundType = TagCollectionCellBackgroundTypeTagOrange;
            else
                backgroundType = TagCollectionCellBackgroundTypeTagWhite;
        } else {
            backgroundType = TagCollectionCellBackgroundTypeTagWhiteWithTail;
        }
        return [TagCollectionCell fitSizeForText:tagObject.name backgroundType:backgroundType maxWidth:280];
    }
    return CGSizeZero;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row < [self.items count]) {
        TagObject *tagObject = [self.items objectAtIndex:indexPath.row];
        if ([self.selectedItems containsObject:tagObject])
            [self.selectedItems removeObject:tagObject];
        else {
            [self.selectedItems addObject:tagObject];
            [self handleDoneButton]; //for iPhone only
        }
        if ([self.delegate respondsToSelector:@selector(searchTagsView:selectedItemsChanged:)]) {
            [self.delegate searchTagsView:self selectedItemsChanged:self.selectedItems];
        }
    }
    [self.myCollectionView reloadData];
}

#pragma mark - Button
- (void)handleDoneButton {
    if ([self.delegate respondsToSelector:@selector(searchComponentView_shouldClose:)])
        [self.delegate searchComponentView_shouldClose:self];
}

#pragma mark - MyFunc
- (void)updateUI {
    [self.myCollectionView reloadData];
}

- (void)removeInvalidData {
    self.items = [NSMutableArray arrayWithArray:[[TagDataManager getInstance] getNonEmptyTags]];
    if (self.filteredTagIdsAndDocCountsByDateCabProf) {
        NSArray *filterdTagIds = [self.filteredTagIdsAndDocCountsByDateCabProf allKeys];
        for (int i = [self.items count] - 1; i >= 0; i--) {
            TagObject *tagObj = [self.items objectAtIndex:i];
            if (![filterdTagIds containsObject:tagObj.id])
                [self.items removeObjectAtIndex:i];
        }
    }
    for (int i = [self.selectedItems count]-1; i >= 0; i--) {
        TagObject *tagObj = [self.selectedItems objectAtIndex:i];
        if (![self.items containsObject:tagObj]) {
            [self.selectedItems removeObject:tagObj];
        }
    }
    [self updateUI];
}

- (void)setFilteredTagIdsAndDocCountsByDateCabinetProfile:(NSMutableDictionary*)dictionary {
    self.filteredTagIdsAndDocCountsByDateCabProf = dictionary;
    [self removeInvalidData];
}
@end
