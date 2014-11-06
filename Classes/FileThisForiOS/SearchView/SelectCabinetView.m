//
//  SelectCabinetView.m
//  FileThis
//
//  Created by Cuong Le on 12/31/13.
//
//

#import "SelectCabinetView.h"
#import "CabinetDataManager.h"
#import "NSString+Custom.h"

#define kDocumentSearchView_CabinetCollectionCellIdentifier             @"CabinetCellIdentifier"
#define kDocumentSearchView_CabinetCollectionSelectedCellIdentifier     @"selectedCellIdentifier"
#define kDocumentSearchView_CollectionCellMaxWidth      180.0
#define kDocumentSearchView_CollectionCellHeight        25.0
#define kDocumentSearchView_CollectionHeaderHeight      30.0
#define kDocumentSearchView_CollectionFooterHeight      10.0

#define kDocumentSearchView_Margin      10.0
#define MAX_SELECTED_CABINET    1000000

@interface SelectCabinetView()

@end

@implementation SelectCabinetView

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initializeViewWithMargin:20 showAll:YES];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame margin:(float)margin {
    if (self = [super initWithFrame:frame]) {
        [self initializeViewWithMargin:margin showAll:YES];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame margin:(float)margin showAll:(BOOL)showAll {
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeViewWithMargin:margin showAll:showAll];
    }
    
    return self;
}

- (void)initializeViewWithMargin:(float)margin showAll:(BOOL)showAll {
    self.margin = margin;
    self.showAllCabinets = showAll;
    
    self.filteredItems = [[NSMutableArray alloc] init];
    self.selectedItems = [[NSMutableArray alloc] init];
    self.allItems = [[NSMutableArray alloc] init];
    
    self.maxNumberOfSelectedItems = MAX_SELECTED_CABINET;
    self.maxHeight = 180;
    self.titleForSelectedItems = @"Selected cabinets:";  //nerver use
    self.titleForSelectedItem = @"Selected cabinet:";
    self.titleForUnselectedItems = @"Touch to select cabinet:";
    
    //Selected
    self.selectedCollectionView = [CommonLayout createCollectionViewWithFlowLayout:CGRectInset(self.bounds, self.margin, self.margin) backgroundColor:kBackgroundLightGrayColor cellClass:[CabinetCollectionCell class] cellIdentifier:kDocumentSearchView_CabinetCollectionSelectedCellIdentifier superView:self delegateDataSource:self];
    self.selectedCollectionView.allowsSelection = YES;
    self.selectedCollectionView.hidden = YES;
    
    //Unselected list 
    self.unselectedCollectionView = [CommonLayout createCollectionViewWithFlowLayout:CGRectInset(self.bounds, self.margin, self.margin) backgroundColor:kBackgroundLightGrayColor cellClass:[CabinetCollectionCell class] cellIdentifier:kDocumentSearchView_CabinetCollectionCellIdentifier superView:self delegateDataSource:self];
    self.unselectedCollectionView.allowsSelection = YES;
    
    self.bottomLine = [CommonLayout drawLine:CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1) color:kBorderLightGrayColor superView:self];
    
    [self filter];
}

- (void)reloadAllCabinets {
    [self.allItems removeAllObjects];
    NSArray *arr = [[CabinetDataManager getInstance] getAllObjects];
    if (!self.showAllCabinets) {
        for (CabinetObject *cabObj in arr) {
            if ([cabObj.id intValue] > 0) {
                [self.allItems addObject:cabObj];
            }
        }
    } else {
        for (CabinetObject *cabObj in arr) {
            [self.allItems addObject:cabObj];
        }
    }
}

- (void)relayout {
    [super relayout];
    self.hidden = NO;
    [self.selectedCollectionView setRightWithoutChangingLeft:self.frame.size.width-self.margin];
    [self.unselectedCollectionView setRightWithoutChangingLeft:self.frame.size.width-self.margin];
    
    if (self.selectedCollectionView.hidden)
        [self.unselectedCollectionView setTop:[self.selectedCollectionView top]];
    else
        [self.unselectedCollectionView setTop:[self.selectedCollectionView bottom]+20];
    
    if (self.unselectedCollectionView.hidden) {
        if (self.selectedCollectionView.hidden) {
            [self setHeight:0];
            self.hidden = YES;
        } else
            [self setHeight:[self.selectedCollectionView bottom] + self.margin];
    } else {
        [self.unselectedCollectionView setHeight:[self.unselectedCollectionView.collectionViewLayout collectionViewContentSize].height];
        if ([self.unselectedCollectionView bottom] > self.maxHeight - self.margin) {
            [self.unselectedCollectionView setBottomWithoutChangingTop:self.maxHeight - self.margin];
        }
        [self setHeight:[self.unselectedCollectionView bottom] + self.margin];
    }
    self.bottomLine.frame = CGRectMake(0, self.frame.size.height-1, self.frame.size.width, 1);
    if ([self.selectCabinetViewDelegate respondsToSelector:@selector(selectCabinetView_heightChanged:)])
        [self.selectCabinetViewDelegate selectCabinetView_heightChanged:self];
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if (collectionView == self.selectedCollectionView) {
        return [self.selectedItems count] + 1;
    }
    return [self.filteredItems count] + 1;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.selectedCollectionView) {
        if (indexPath.row < [self.selectedItems count] + 1) {
            CabinetCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentSearchView_CabinetCollectionSelectedCellIdentifier forIndexPath:indexPath];
            if (indexPath.row == 0) {
                if ([self.selectedItems count] > 1)
                    [cell setText:self.titleForSelectedItems clearBackground:YES useDarkBackColor:NO];
                else
                    [cell setText:self.titleForSelectedItem clearBackground:YES useDarkBackColor:NO];
            } else {
                CabinetObject *CabinetObject = [self.selectedItems objectAtIndex:indexPath.row-1];
                [cell setText:CabinetObject.name clearBackground:NO useDarkBackColor:YES];
            }
            return cell;
        }
    } else {
        if (indexPath.row < [self.filteredItems count] + 1) {
            CabinetCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentSearchView_CabinetCollectionCellIdentifier forIndexPath:indexPath];
            if (indexPath.row == 0) {
                [cell setText:self.titleForUnselectedItems clearBackground:YES useDarkBackColor:NO];
            } else {
                CabinetObject *CabinetObject = [self.filteredItems objectAtIndex:indexPath.row-1];
                [cell setText:CabinetObject.name clearBackground:NO useDarkBackColor:NO];
            }
            return cell;
        }
    }
    return nil;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSString *string = nil;
    BOOL useForCabinetName = YES;
    if (collectionView == self.selectedCollectionView) {
        if (indexPath.row == 0) {
            string = ([self.selectedItems count] > 1 ? self.titleForSelectedItems : self.titleForSelectedItem);
            useForCabinetName = NO;
        } else if (indexPath.row < [self.selectedItems count] + 1)
            string = ((CabinetObject*)[self.selectedItems objectAtIndex:indexPath.row-1]).name;
    } else {
        if (indexPath.row == 0) {
            string = self.titleForUnselectedItems;
            useForCabinetName = NO;
        } else if (indexPath.row < [self.filteredItems count] + 1)
            string = ((CabinetObject*)[self.filteredItems objectAtIndex:indexPath.row-1]).name;
    }
    
    if (string) {
        if (useForCabinetName) {
            CGSize fitSize = [string sizeWithFont:kCabinetCollectionCell_Font constrainedToSize:CGSizeMake(kDocumentSearchView_CollectionCellMaxWidth, 1000)];
            return CGSizeMake(fitSize.width + 20.0, kDocumentSearchView_CollectionCellHeight);
        }
        CGSize fitSize = [string sizeWithFont:kCabinetCollectionCell_TextOnlyFont constrainedToSize:CGSizeMake(400.0, 1000)];
        return CGSizeMake(fitSize.width + 8.0, kDocumentSearchView_CollectionCellHeight);
    }
    
    return CGSizeMake(kDocumentSearchView_CollectionCellMaxWidth, kDocumentSearchView_CollectionCellHeight);
}
#pragma GCC diagnostic pop

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (collectionView == self.selectedCollectionView) {
        if (indexPath.row > 0) {
            CabinetObject *cabObject = [self.selectedItems objectAtIndex:indexPath.row - 1];
            [self.selectedItems removeObject:cabObject];
            
            if ([self.selectCabinetViewDelegate respondsToSelector:@selector(didDeselectCabinet:)]) {
                [self.selectCabinetViewDelegate didDeselectCabinet:cabObject];
            }
        }
    } else {
        if (indexPath.row > 0) {
            CabinetObject *cabinetObject = [self.filteredItems objectAtIndex:indexPath.row-1];
            if ([self.selectedItems count] == self.maxNumberOfSelectedItems) {
                [self.selectedItems removeObjectAtIndex:0];
            }
            
            [self.selectedItems addObject:cabinetObject];
            
            if ([self.selectCabinetViewDelegate respondsToSelector:@selector(didSelectCabinet:)]) {
                [self.selectCabinetViewDelegate didSelectCabinet:cabinetObject];
            }
        }
    }
    [self filter];
}

#pragma mark - MyFunc
- (void)filter {
    [self reloadAllCabinets];
    
    [self.filteredItems removeAllObjects];
    
    if ([self.filteredString length] == 0) {
        for (CabinetObject *item in self.allItems) {
            if (![self.selectedItems containsObject:item]) {
                [self.filteredItems addObject:item];
            }
        }
    } else  {
        for (CabinetObject *item in self.allItems) {
            if (![self.selectedItems containsObject:item]) {
                if ([item.name rangeOfStringSearchByWord:self.filteredString].location != NSNotFound)
                    [self.filteredItems addObject:item];;
            }
        }
    }
    [self.selectedCollectionView reloadData];
    [self.selectedCollectionView setNeedsDisplay];
    [self.unselectedCollectionView reloadData];
    
    if ([self.selectedItems count] > 0) {
        self.selectedCollectionView.hidden = NO;
        float selectedDataHeight = [self.selectedCollectionView.collectionViewLayout collectionViewContentSize].height;
        if (selectedDataHeight > self.maxHeight * 0.4) selectedDataHeight = self.maxHeight * 0.4;
        
        [self.selectedCollectionView setHeight:selectedDataHeight];
    } else {
        self.selectedCollectionView.hidden = YES;
    }
    
    self.unselectedCollectionView.hidden = ([self.filteredItems count] == 0);
    [self relayout];
}

- (void)setFilteredString:(NSString*)aString {
    _filteredString = aString;
    [self filter];
}

@end
