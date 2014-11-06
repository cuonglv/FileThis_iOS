//
//  SearchTagsView.h
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//

#import <UIKit/UIKit.h>
#import "BorderView.h"
#import "DocumentSearchViewConstant.h"
#import "CabinetObject.h"

@protocol SearchTagsViewDelegate <NSObject>
- (void)searchTagsView:(id)sender selectedItemsChanged:(NSMutableArray*)selectedItems;
@end

#pragma mark -

@interface SearchTagsView : UIView

@property (nonatomic, strong) NSMutableArray *selectedItems;
@property (nonatomic, assign) id<SearchTagsViewDelegate, SearchComponentViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<SearchTagsViewDelegate, SearchComponentViewDelegate>)delegate;
- (void)updateUI;
- (void)removeInvalidData;
- (void)setFilteredTagIdsAndDocCountsByDateCabinetProfile:(NSMutableDictionary*)dictionary;
@end
