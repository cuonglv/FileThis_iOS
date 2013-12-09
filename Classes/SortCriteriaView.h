//
//  SortCriteriaView.h
//  GreatestRoad
//
//  Created by Nam Phan on 4/25/10.
//  Copyright 2010 filethis.com. All rights reserved.
//

#import <UIKit/UIKit.h>


@protocol SortCriteriaDelegate <NSObject>

@required

- (void)didSelectSortingCriteria;
- (void)didCancelSortingCriteria;

@end

@interface SortCriteriaView : UIView <UIPickerViewDelegate, UIPickerViewDataSource>
{
	NSArray *items;
	id __weak delegate;
	UIPickerView *criteriaPicker;
    int iSelectedIndex;
}

@property (nonatomic, weak) id delegate;
@property (nonatomic, strong) NSArray *items;

- (id)initWithFrame:(CGRect)frame delegate:myDelegate items:(NSArray*)itemArray;
+ (id)newWithSuperView:(UIView*)view delegate:(id)myDelegate items:(NSArray*)itemArray;
- (void)handleCancelBtn:(id)sender;
- (void)handleDoneBtn:(id)sender;

- (int)getSelectedIndex;
- (void)setSelectedIndex:(int)value;
@end
