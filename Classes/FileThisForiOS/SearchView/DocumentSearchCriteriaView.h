//
//  DocumentSearchCriteriaView.h
//  FileThis
//
//  Created by Cuong Le on 1/9/14.
//
//

#import <UIKit/UIKit.h>
#import "DocumentSearchViewConstant.h"
#import "CabinetObject.h"
#import "DocumentSearchCriteria.h"

@protocol DocumentSearchCriteriaViewDelegate <NSObject>
- (void)documentSearchCriteriaView_removedDate:(id)sender;
- (void)documentSearchCriteriaView_removedSearchText:(id)sender;
- (void)documentSearchCriteriaView_removedCabinetOrProfile:(id)sender;
- (void)documentSearchCriteriaView_removedTag:(id)sender newTags:(NSMutableArray*)newTags;
- (void)documentSearchCriteriaView_addedTag:(id)sender newTags:(NSMutableArray*)newTags;
- (void)documentSearchCriteriaView_didBecomeEmpty:(id)sender;
- (void)documentSearchCriteriaView_searchNow:(id)sender;
@end

#pragma mark -

@interface DocumentSearchCriteriaView : UIView

@property (nonatomic, strong) DocumentSearchCriteria *documentSearchCriteria;

@property (nonatomic, assign) id<DocumentSearchCriteriaViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<DocumentSearchCriteriaViewDelegate>)delegate;

- (void)updateUI;
@end
