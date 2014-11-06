//
//  SelectItemsView.h
//  FileThis
//
//  Created by Cuong Le on 1/22/14.
//
//

#import <UIKit/UIKit.h>
#import "CommonLayout.h"
#import "TagCollectionCell.h"
#import "LabelCollectionReusableView.h"

@protocol SelectItemsViewDelegate <NSObject>
- (void)didSelectItem:(id)item;
- (void)didDeselectItem:(id)item;
@optional
- (void)selectItemsView_heightChanged:(id)sender;
@end

@interface SelectItemsView : UIView <UICollectionViewDataSource, UICollectionViewDelegate>
@property (assign) float margin;
@property (nonatomic, strong) NSString *filteredString;
@property (nonatomic, strong) NSMutableArray *selectedItems;
@property (nonatomic, strong) NSMutableArray *allItems, *filteredItems;
@property (nonatomic, strong) UICollectionView *unselectedItemCollectionView, *selectedCollectionView;
@property (nonatomic, assign) id<SelectItemsViewDelegate> delegate;
@property (assign) BOOL isEditting;

- (id)initWithFrame:(CGRect)frame margin:(float)margin;

#pragma mark - Overridable
- (NSMutableArray*)getAllItems;
- (BOOL)removeDataForItem:(id)item;
- (NSString*)nameOfItem:(id)item;
- (NSString*)rightTextOfItem:(id)item;
- (NSString*)confirmMessageForRemoval:(id)item;

#pragma mark - MyFunc
- (void)filterItems;

@end
