//
//  SearchByDateView.h
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//

#import <UIKit/UIKit.h>
#import "BorderView.h"
#import "DocumentSearchViewConstant.h"

@protocol SearchByDateViewDelegate <NSObject>
- (void)searchByDateView_ValueChanged:(id)sender date1:(NSDateComponents*)dateComps1 date2:(NSDateComponents*)dateComps2;
@end

#pragma mark -

@interface SearchByDateView : BorderView

@property (nonatomic, assign) id<SearchByDateViewDelegate, SearchComponentViewDelegate> delegate;

#pragma mark - MyFunc
- (void)setDate1:(NSDateComponents*)dateComps1 date2:(NSDateComponents*)dateComps2;
- (void)dismissPopopover;
@end
