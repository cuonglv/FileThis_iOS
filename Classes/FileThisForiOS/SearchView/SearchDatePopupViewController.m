//
//  SearchDatePopupViewController.m
//  FileThis
//
//  Created by Cuong Le on 1/9/14.
//
//

#import "SearchDatePopupViewController.h"
#import <Crashlytics/Crashlytics.h>
#import "CommonLayout.h"

#define kNumberOfYears  20

@interface SearchDatePopupViewController () <UIPickerViewDelegate, UIPickerViewDataSource>
@property (nonatomic, strong) UIButton *cancelButton, *doneButton;
@property (nonatomic, strong) UIPickerView *yearPickerView, *monthYearPickerView;
@property (assign) int maxYear;
@end

@implementation SearchDatePopupViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.view.clipsToBounds = YES;
        
        self.monthYearPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(20, 20, kSearchDatePopupViewWidth - 40, kSearchDatePopupViewHeight - 70)];
        self.monthYearPickerView.delegate = self;
        self.monthYearPickerView.dataSource = self;
        [self.view addSubview:self.monthYearPickerView];
        
        self.yearPickerView = [[UIPickerView alloc] initWithFrame:self.monthYearPickerView.frame];
        self.yearPickerView.delegate = self;
        self.yearPickerView.dataSource = self;
        self.yearPickerView.hidden = YES;
        [self.view addSubview:self.yearPickerView];
        
        self.cancelButton = [CommonLayout createTextButton:CGRectMake(0, kSearchDatePopupViewHeight-45, kSearchDatePopupViewWidth/2, 45) fontSize:FontSizeMedium isBold:NO text:NSLocalizedString(@"ID_CLEAR", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleCancelButton) superView:self.view];
        self.doneButton = [CommonLayout createTextButton:[self.cancelButton rectAtRight:-1 width:self.cancelButton.frame.size.width+1] fontSize:FontSizeMedium isBold:YES text:NSLocalizedString(@"ID_DONE", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleDoneButton) superView:self.view];
        self.view.layer.borderColor = self.cancelButton.layer.borderColor = self.doneButton.layer.borderColor = kBorderLightGrayColor.CGColor;
        self.view.layer.borderWidth = self.cancelButton.layer.borderWidth = self.doneButton.layer.borderWidth = 1.0;
        
        self.maxYear = [DateHandler todayDateComps].year;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
}

#pragma mark - PickerView
// tell the picker how many rows are available for a given component (in our case we have one component)
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.monthYearPickerView)
        if (component == 0)
            return 12;  //month
    
    return kNumberOfYears; //year
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)aRow forComponent:(NSInteger)component reusingView:(UIView *)view {
	CGRect rect = CGRectMake(0, 0, 180, 28);
	UILabel* label = [[UILabel alloc] initWithFrame:rect];
    label.font = [UIFont systemFontOfSize:20];
    int number;
    if (pickerView == self.monthYearPickerView && component == 0) {
//        number = aRow + 1;
        label.text = [kMonthsOfYear objectAtIndex:aRow];
    } else {
        number = self.maxYear - aRow;
        label.text = [NSString stringWithFormat:@"%i", number];
    }
    label.textColor = [UIColor blackColor];
    label.backgroundColor = [UIColor clearColor];
	label.textAlignment = NSTextAlignmentCenter;
	return label;
}

// tell the picker how many components it will have (in our case we have one component)
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.monthYearPickerView)
        return 2;
    
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
//    if (component == 0) {
//        month = row + 1;
//    } else {
//        year = [[years objectAtIndex:row] intValue];
//    }
}


- (void)handleCancelButton {
    [self.delegate searchDatePopupViewController_Canceled:self];
}

- (void)handleDoneButton {
    [self.delegate searchDatePopupViewController_Done:self];
}

#pragma mark - Func
- (NSDateComponents*)selectedDateComps {
    NSDateComponents *ret = [[NSDateComponents alloc] init];
    if (self.monthYearPickerView.hidden) {
        ret.day = ret.month = -1;
        ret.year = [self.yearPickerView selectedRowInComponent:0];
        if (ret.year < 0) ret.year = 0;
        ret.year = self.maxYear - ret.year;
    } else {
        ret.day = -1;
        ret.month = [self.monthYearPickerView selectedRowInComponent:0];
        if (ret.month < 0) ret.month = 0;
        ret.month++;
        
        ret.year = [self.monthYearPickerView selectedRowInComponent:1];
        if (ret.year < 0) ret.year = 0;
        ret.year = self.maxYear - ret.year;
    }
    return ret;
}

- (void)setDate:(NSDateComponents*)dateComps isShowingYear:(BOOL)isShowingYear {
    self.monthYearPickerView.hidden = isShowingYear;
    self.yearPickerView.hidden = !isShowingYear;
    
    if (dateComps.month > 0) {
        [self.monthYearPickerView selectRow:dateComps.month-1 inComponent:0 animated:NO];
    }
    
    int yearIndex = self.maxYear - dateComps.year;
    if (yearIndex >= 0 && yearIndex < kNumberOfYears) {
        [self.yearPickerView selectRow:yearIndex inComponent:0 animated:NO];
        [self.monthYearPickerView selectRow:yearIndex inComponent:1 animated:NO];
    }
}
@end
