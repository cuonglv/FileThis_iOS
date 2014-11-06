//
//  SelectCabinetView.h
//  FileThis
//
//  Created by Cuong Le on 12/31/13.
//
//

#import <UIKit/UIKit.h>
#import "BaseView.h"
#import "CommonLayout.h"
#import "CabinetCollectionCell.h"

@protocol SelectCabinetViewDelegate <NSObject>

- (void)didSelectCabinet:(CabinetObject *)cabObj;
- (void)didDeselectCabinet:(CabinetObject *)cabObj;
@optional
- (void)selectCabinetView_heightChanged:(id)sender;

@end

@interface SelectCabinetView : BaseView <UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, assign) id<SelectCabinetViewDelegate> selectCabinetViewDelegate;

@property (assign) float margin;
@property (assign) int maxNumberOfSelectedItems;
@property (assign) float maxHeight;
@property (nonatomic, strong) NSString *filteredString;
@property (nonatomic, strong) NSMutableArray *allItems, *filteredItems, *selectedItems;
@property (nonatomic, strong) NSString *titleForSelectedItems, *titleForSelectedItem, *titleForUnselectedItems;
@property (nonatomic, strong) UICollectionView *selectedCollectionView, *unselectedCollectionView;
@property (nonatomic, strong) UIView *bottomLine;
@property (nonatomic, assign) BOOL showAllCabinets;

- (id)initWithFrame:(CGRect)frame margin:(float)margin;
- (id)initWithFrame:(CGRect)frame margin:(float)margin showAll:(BOOL)showAll;
- (void)initializeViewWithMargin:(float)margin showAll:(BOOL)showAll;
- (void)reloadAllCabinets;

#pragma mark - MyFunc
- (void)filter;

@end
