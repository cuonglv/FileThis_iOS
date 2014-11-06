//
//  SearchCabinetAccountView.h
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//

#import "BorderView.h"
#import "DocumentSearchViewConstant.h"
#import "CabinetDataManager.h"
#import "ProfileDataManager.h"
#import "ProfileObject.h"

@protocol SearchCabinetAccountViewDelegate <NSObject>
- (void)searchCabinetAccountView_SelectedItemChanged:(id)sender;
@end

@interface SearchCabinetAccountView : BorderView

@property (nonatomic, strong) BorderView *headerView;
@property (nonatomic, assign) id<SearchCabinetAccountViewDelegate, SearchComponentViewDelegate> delegate;
@property (nonatomic, strong) CabinetObject *selectedCabinet;
@property (nonatomic, strong) ProfileObject *selectedProfile;

@property (nonatomic, strong) NSMutableDictionary *filteredCabIdsAndDocCountsByDate, *filteredProfIdsAndDocCountsByDate;

- (id)initWithFrame:(CGRect)frame borderColor:(UIColor *)bordercolor borderWidths:(Offset)borderwidths superView:(UIView *)superView delegate:(id<SearchCabinetAccountViewDelegate, SearchComponentViewDelegate>)delegate;

- (void)updateUI;
- (void)selectCabinet:(CabinetObject*)aCabinet profile:(ProfileObject*)aProfile;
- (void)setFilteredCabIdsAndDocCountsByDate:(NSMutableDictionary*)dict1 filteredProfIdsAndDocCountsByDate:(NSMutableDictionary*)dict2;
@end
