//
//  DocumentRecentSearchView.h
//  FileThis
//
//  Created by Cuong Le on 1/11/14.
//
//

#import <UIKit/UIKit.h>
#import "BorderView.h"
#import "DocumentSearchCriteria.h"
#import "DocumentSearchViewConstant.h"

@protocol DocumentRecentSearchViewDelegate <NSObject>
- (void)documentRecentSearchView:(id)sender touchItem:(DocumentSearchCriteria*)documentSearchCriteria;
@end

@interface DocumentRecentSearchView : UIView
@property (nonatomic, assign) id<DocumentRecentSearchViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<DocumentRecentSearchViewDelegate>)delegate;
- (void)reloadData;
- (void)removeInvalidData;
@end
