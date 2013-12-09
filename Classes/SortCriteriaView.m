//
//  SortCriteriaView.m
//  GreatestRoad
//
//  Created by Nam Phan on 4/25/10.
//  Copyright 2010 filethis.com. All rights reserved.
//

#import "SortCriteriaView.h"
//#import "Layout.h"

@implementation SortCriteriaView

@synthesize items, delegate;

- (id)initWithFrame:(CGRect)frame delegate:myDelegate items:(NSArray*)itemArray{
    
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        delegate = myDelegate;
        items = itemArray;
        self.backgroundColor = [UIColor blackColor];
        
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, 36)];
        lbl.font = [UIFont boldSystemFontOfSize:20];
        lbl.textAlignment = NSTextAlignmentCenter; //UITextAlignmentCenter deprecated in iOS 6.0
        lbl.text = @"Sort";
        lbl.textColor = [UIColor whiteColor];
        lbl.backgroundColor = [UIColor clearColor];
        [self addSubview:lbl];
        
        criteriaPicker = [[UIPickerView alloc] initWithFrame:CGRectMake(0, 30, self.frame.size.width, 180)];
        //criteriaPicker.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        criteriaPicker.showsSelectionIndicator = YES;	// note this is default to NO
        criteriaPicker.delegate = self;
        criteriaPicker.dataSource = self;
        [self addSubview:criteriaPicker];
        
        UIImage *imgButton = [UIImage imageNamed:@"btn_topright.png"];
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(4, 250, 70, 30);
        [btn setBackgroundImage:imgButton forState:UIControlStateNormal];
        [btn setTitle:@"Cancel" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [btn addTarget:self action:@selector(handleCancelBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(self.frame.size.width - 64, 250, 60, 30);
        [btn setBackgroundImage:imgButton forState:UIControlStateNormal];
        [btn setTitle:@"Done" forState:UIControlStateNormal];
        [btn.titleLabel setFont:[UIFont boldSystemFontOfSize:16]];
        [btn addTarget:self action:@selector(handleDoneBtn:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:btn];
        
        [criteriaPicker selectRow:0 inComponent:0 animated:NO];
        iSelectedIndex = 0;
    }
    return self;
}

+ (id)newWithSuperView:(UIView*)view delegate:(id)myDelegate items:(NSArray*)itemArray {
    SortCriteriaView *ret = [[SortCriteriaView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - 280, view.frame.size.width, 280) delegate:myDelegate items:itemArray];
    [view addSubview:ret];
    return ret;
}
/*
- (void)drawRect:(CGRect)rect {
    // Drawing code
    
}
*/


- (void)handleCancelBtn:(id)sender
{
	if ([delegate respondsToSelector:@selector(didCancelSortingCriteria)]) {
        [delegate didCancelSortingCriteria];
    }
}

- (void)handleDoneBtn:(id)sender
{
	//NSInteger selectedRow = [criteriaPicker selectedRowInComponent:0];
	//NSString *criteriaSyntax = [StaticFunction getCriteria:selectedRow];
	//[StaticFunction saveSelectedCriteria:criteriaSyntax atRow:selectedRow];
	if ([delegate respondsToSelector:@selector(didSelectSortingCriteria)]) {
        [delegate didSelectSortingCriteria];
    }
}

#pragma mark PickerView's delegate

// tell the picker how many rows are available for a given component (in our case we have one component)
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return (items.count);
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)aRow forComponent:(NSInteger)component reusingView:(UIView *)view 
{
	CGRect rect = CGRectMake(30, 0, self.frame.size.width - 60, 28);
	UILabel* label = [[UILabel alloc] initWithFrame:rect];
    label.font = [UIFont boldSystemFontOfSize:20];
    label.text = items[aRow];
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentLeft; //UITextAlignmentLeft deprecated in iOS 6.0
	return label;
}

// tell the picker how many components it will have (in our case we have one component)
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
	return 1;
}
/*
 // tell the picker the width of each row for a given component (in our case we have one component)
 - (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component {
 return kWidthForPickerComponent;
 }
 
 // tell the picker the height of each row for a given component (in our case we have one component).
 - (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
 return kRowHeightForComponent;
 }
 */
// get current value at selected row on each component.
- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    iSelectedIndex = row;
}


#pragma mark -
#pragma mark MyFunc
- (int)getSelectedIndex{
    return iSelectedIndex;
}
- (void)setSelectedIndex:(int)value {
    iSelectedIndex = value;
    [criteriaPicker selectRow:value inComponent:0 animated:NO];
}
@end
