//
//  SelectItemsView.m
//  FileThis
//
//  Created by Cuong Le on 1/22/14.
//
//

#import "SelectItemsView.h"
#import "NSString+Custom.h"
#import "TagCollectionCell.h"
#import "NetworkReachability.h"
#import "Utils.h"

#define kDocumentSearchView_TagCollectionCellIdentifier                     @"ItemCellIdentifier"
#define kDocumentSearchView_CollectionCellMaxWidth      180.0
#define kDocumentSearchView_CollectionCellHeight        25.0
#define kDocumentSearchView_CollectionHeaderHeight      30.0
#define kDocumentSearchView_CollectionFooterHeight      10.0

#define kSelectItemsView_AlertMessageItem_ConfirmRemveItem 1

#define kDocumentSearchView_Margin      10.0

@interface SelectItemsView() <UIAlertViewDelegate>
@property (nonatomic, strong) id selectedItemToRemove;
@end

@implementation SelectItemsView
@synthesize isEditting;

- (id)initWithFrame:(CGRect)frame margin:(float)margin {
    if (self = [super initWithFrame:frame]) {
        self.margin = margin;
        self.filteredItems = [[NSMutableArray alloc] init];
        self.selectedItems = [[NSMutableArray alloc] init];
        
        //Selected list
        self.selectedCollectionView = [CommonLayout createCollectionViewWithFlowLayout:CGRectInset(self.bounds, self.margin, self.margin)  backgroundColor:kClearColor cellClass:[TagCollectionCell class] cellIdentifier:kDocumentSearchView_TagCollectionCellIdentifier superView:self delegateDataSource:self];
        self.selectedCollectionView.allowsSelection = YES;
        self.selectedCollectionView.hidden = YES;
        
        //Item list
        self.unselectedItemCollectionView = [CommonLayout createCollectionViewWithFlowLayout:CGRectInset(self.bounds, self.margin, self.margin) backgroundColor:kClearColor cellClass:[TagCollectionCell class] cellIdentifier:kDocumentSearchView_TagCollectionCellIdentifier superView:self delegateDataSource:self];
        self.unselectedItemCollectionView.allowsSelection = YES;
        
        [self filterItems];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.selectedCollectionView setRightWithoutChangingLeft:self.frame.size.width-self.margin];
    [self.unselectedItemCollectionView setRightWithoutChangingLeft:self.frame.size.width-self.margin];
    
    if (self.selectedCollectionView.hidden)
        [self.unselectedItemCollectionView setTop:[self.selectedCollectionView top] bottom:self.frame.size.height-self.margin];
    else
        [self.unselectedItemCollectionView setTop:[self.selectedCollectionView bottom]+20 bottom:self.frame.size.height-self.margin];
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
    NSArray *textAndBackgroundType = [self getTextAndBackgroundTypeForCellAtIndexPath:indexPath collectionView:collectionView];
    TagCollectionCell *cell = nil;
    if (collectionView == self.selectedCollectionView) {
        if (indexPath.row < [self.selectedItems count] + 1)
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentSearchView_TagCollectionCellIdentifier forIndexPath:indexPath];
    } else {
        if (indexPath.row < [self.filteredItems count] + 1)
            cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentSearchView_TagCollectionCellIdentifier forIndexPath:indexPath];
    }
    if (textAndBackgroundType && cell) {
        [cell setText:[textAndBackgroundType objectAtIndex:0] rightText:[textAndBackgroundType objectAtIndex:2] backgroundType:[[textAndBackgroundType objectAtIndex:1] intValue]];
    }
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *textAndBackgroundType = [self getTextAndBackgroundTypeForCellAtIndexPath:indexPath collectionView:collectionView];
    if (textAndBackgroundType)
        return [TagCollectionCell fitSizeForText:[textAndBackgroundType objectAtIndex:0] backgroundType:[[textAndBackgroundType objectAtIndex:1] intValue] maxWidth:kDocumentSearchView_CollectionCellMaxWidth];
    
    return CGSizeMake(kDocumentSearchView_CollectionCellMaxWidth, kDocumentSearchView_CollectionCellHeight);
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    if (![[NetworkReachability getInstance] checkInternetActiveManually]) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_NO_INTERNET_CONNECTION2", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    if (collectionView == self.selectedCollectionView) {
        if (indexPath.row > 0) {
            id item = [self.selectedItems objectAtIndex:indexPath.row - 1];
            if (self.isEditting) {
                [self removeItem:item];
            } else {
                [self.selectedItems removeObject:item];
                if ([self.delegate respondsToSelector:@selector(didDeselectItem:)]) {
                    [self.delegate didDeselectItem:item];
                }
                [self filterItems];
            }
        }
    } else {
        if (indexPath.row > 0) {
            id item = [self.filteredItems objectAtIndex:indexPath.row-1];
            if (self.isEditting) {
                [self removeItem:item];
            } else {
                [self.selectedItems addObject:item];
                if ([self.delegate respondsToSelector:@selector(didSelectItem:)]) {
                    [self.delegate didSelectItem:item];
                }
                [self filterItems];
            }
        }
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kSelectItemsView_AlertMessageItem_ConfirmRemveItem) {
        if (buttonIndex == 0) {
            if ([self removeDataForItem:self.selectedItemToRemove]) {
                NSLog(@"Item removed");
                [self.selectedItems removeObject:self.selectedItemToRemove];
                self.selectedItemToRemove = nil;
                [self filterItems];
            }
        }
    }
}

#pragma mark - Overridable
- (NSMutableArray*)getAllItems {
    return nil;
}

- (TagCollectionCellBackgroundType)backgroundTypeForSelectedItem {
    return TagCollectionCellBackgroundTypeTagOrangeWithTail;
}

- (TagCollectionCellBackgroundType)backgroundTypeForSelectedItemToRemove {
    return TagCollectionCellBackgroundTypeTagOrangeX;
}

- (TagCollectionCellBackgroundType)backgroundTypeForUnselectedItem {
    return TagCollectionCellBackgroundTypeTagWhiteWithTail;
}

- (TagCollectionCellBackgroundType)backgroundTypeForUnselectedItemToRemove {
    return TagCollectionCellBackgroundTypeTagWhiteX;
}

- (NSString*)titleForSelectedItems {
    return @"Selected items:";
}
- (NSString*)titleForSelectedItem {
    return @"Selected item:";
}
- (NSString*)titleForUnselectedItems {
    return @"Touch to select item:";
}

- (BOOL)removeDataForItem:(id)item {
    return YES;
}

- (NSString*)nameOfItem:(id)item {
    return @"";
}

- (NSString*)rightTextOfItem:(id)item {
    return @"";
}

- (NSString*)confirmMessageForRemoval:(id)item {
    return @"";
}

#pragma mark - MyFunc
- (void)filterItems {
    self.allItems = [self getAllItems];
    [self.filteredItems removeAllObjects];
    if ([self.filteredString length] == 0) {
        for (id item in self.allItems) {
            if (![self.selectedItems containsObject:item]) {
                [self.filteredItems addObject:item];
            }
        }
    } else  {
        for (id item in self.allItems) {
            if (![self.selectedItems containsObject:item]) {
                if ([[self nameOfItem:item] rangeOfStringSearchByWord:self.filteredString].location != NSNotFound)
                    [self.filteredItems addObject:item];
            }
        }
    }
    
    // Sort selectedItems and filterItems by alpha B
    [self.selectedItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[[self nameOfItem:obj1] lowercaseString] compare:[[self nameOfItem:obj2] lowercaseString]];
    }];
    
    [self.filteredItems sortUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [[[self nameOfItem:obj1] lowercaseString] compare:[[self nameOfItem:obj2] lowercaseString]];
    }];
    
    [self.selectedCollectionView reloadData];
    [self.selectedCollectionView setNeedsDisplay];
    [self.unselectedItemCollectionView reloadData];
    
    if ([self.selectedItems count] > 0) {
        self.selectedCollectionView.hidden = NO;
        float selectedDataHeight = [self.selectedCollectionView.collectionViewLayout collectionViewContentSize].height;
        if (selectedDataHeight > self.frame.size.height * 0.4) selectedDataHeight = self.frame.size.height * 0.4;
        
        [self.selectedCollectionView setHeight:selectedDataHeight];
    } else {
        self.selectedCollectionView.hidden = YES;
    }
    
    self.unselectedItemCollectionView.hidden = ([self.filteredItems count] == 0);
    self.hidden = (self.unselectedItemCollectionView.hidden && self.selectedCollectionView.hidden);
    [self setNeedsLayout];
}

- (void)setFilteredString:(NSString*)aString {
    _filteredString = aString;
    [self filterItems];
}

- (NSArray*)getTextAndBackgroundTypeForCellAtIndexPath:(NSIndexPath*)indexPath collectionView:(UICollectionView*)collectionView {
    NSString *text = nil;
    TagCollectionCellBackgroundType backgroundType;
    NSString *rightText = @"";
    
    if (collectionView == self.selectedCollectionView) {
        if (indexPath.row < [self.selectedItems count] + 1) {
            if (indexPath.row == 0) {
                backgroundType =TagCollectionCellBackgroundTypeClear;
                if ([self.selectedItems count] > 1)
                    text = [self titleForSelectedItems];
                else
                    text = [self titleForSelectedItem];
            } else {
                id item = [self.selectedItems objectAtIndex:indexPath.row-1];
                text = [self nameOfItem:item];
                if (isEditting) {
                    backgroundType = [self backgroundTypeForSelectedItemToRemove];
                } else {
                    backgroundType = [self backgroundTypeForSelectedItem];
                    rightText = [self rightTextOfItem:item];
                }
            }
        }
    } else {
        if (indexPath.row < [self.filteredItems count] + 1) {
            if (indexPath.row == 0) {
                text = [self titleForUnselectedItems];
                backgroundType = TagCollectionCellBackgroundTypeClear;
            } else {
                id item = [self.filteredItems objectAtIndex:indexPath.row-1];
                text = [self nameOfItem:item];
                if (isEditting) {
                    backgroundType = [self backgroundTypeForUnselectedItemToRemove];
                } else {
                    backgroundType = [self backgroundTypeForUnselectedItem];
                    rightText = [self rightTextOfItem:item];
                }
            }
        }
    }
    if (rightText == nil)
        rightText = @"";
    
    if (text)
        return [NSArray arrayWithObjects:text,[NSNumber numberWithInt:backgroundType],rightText,nil];
    
    return nil;
}

- (BOOL)isEditting {
    return isEditting;
}

- (void)setIsEditting:(BOOL)val {
    isEditting = val;
    [self filterItems];
}

- (void)removeItem:(id)ItemObj {
    self.selectedItemToRemove = ItemObj;
    [CommonLayout showConfirmAlert:[self confirmMessageForRemoval:ItemObj] tag:kSelectItemsView_AlertMessageItem_ConfirmRemveItem delegate:self];
}

@end
