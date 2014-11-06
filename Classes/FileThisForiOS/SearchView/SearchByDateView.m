//
//  SearchByDateView.m
//  FileThis
//
//  Created by Cuong Le on 1/8/14.
//
//

#import "SearchByDateView.h"
#import "CommonLayout.h"
#import "DocumentSearchCriteria.h"
#import "MonthYearPickerButton.h"
#import "FTMobileAppDelegate.h"

@interface SearchByDateView() <MonthYearPickerButtonDelegate>
@property (nonatomic, strong) BorderView *headerView;
@property (nonatomic, strong) UILabel *searchByLabel;
@property (nonatomic, strong) UISegmentedControl *segmentControl;
@property (nonatomic, strong) MonthYearPickerButton *monthYearPickerButton1, *monthYearPickerButton2;
@property (nonatomic, strong) UIButton *doneButton; //iPhone only
@end

@implementation SearchByDateView

- (id)initWithFrame:(CGRect)frame borderColor:(UIColor *)bordercolor borderWidths:(Offset)borderwidths superView:(UIView *)superView {
    if (self = [super initWithFrame:frame borderColor:bordercolor borderWidths:borderwidths superView:superView]) {
//        self.backgroundColor = kDocumentSearchView_SearchByDateViewBackColor;
        
        self.headerView = [[BorderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kDocumentSearchView_SearchByHeaderViewHeight) borderColor:bordercolor borderWidths:OffsetMake(0, 0, 0, 1) superView:self];
        self.headerView.backgroundColor = kDocumentSearchView_SearchByDateViewBackColor;
        
        self.searchByLabel = [CommonLayout createLabel:CGRectMake(kDocumentSearchView_MarginLeft, 0, kDocumentSearchView_SearchByLabelWidth,kDocumentSearchView_SearchByHeaderViewHeight) font:kDocumentSearchView_HeaderFont textColor:kDocumentSearchView_TextColor backgroundColor:nil text:NSLocalizedString(@"ID_SEARCH_BY_UPPERCASE", @"") superView:self.headerView];
        
        float verticalSpace;
        CGRect segmentControlFrame;
        FontSize segmentControlFontSize;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            verticalSpace = 30;
            [self.searchByLabel autoWidth];
            segmentControlFrame = [self.searchByLabel rectAtRight:10 width:140 height:30];
            segmentControlFontSize = FontSizexSmall;
            self.doneButton = [CommonLayout createTextButton:CGRectMake(self.frame.size.width - 60, kDocumentSearchView_SearchByHeaderViewHeight / 2 - 15, 50, 30) font:[CommonLayout getFont:FontSizexSmall isBold:YES] text:NSLocalizedString(@"ID_DONE", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleDoneButton) superView:self];
        } else {
            verticalSpace = 10;
            segmentControlFrame = CGRectMake([self.searchByLabel right], kDocumentSearchView_SearchByHeaderViewHeight / 2 - 15, roundf(self.frame.size.width - [self.searchByLabel right] - kDocumentSearchView_MarginRight), 30);
            segmentControlFontSize = FontSizeSmall;
        }
        self.segmentControl = [CommonLayout createSegmentControl:segmentControlFrame texts:[NSArray arrayWithObjects:NSLocalizedString(@"ID_MONTH", @""), NSLocalizedString(@"ID_YEAR", @""), nil] font:[CommonLayout getFont:segmentControlFontSize isBold:NO] tintColor:kTextOrangeColor target:self selector:@selector(handleSegmentControl:) superView:self.headerView];
        self.segmentControl.selectedSegmentIndex = 0;
        
        //FROM
        UILabel *label = [CommonLayout createLabel:CGRectMake(kDocumentSearchView_MarginLeft+20, kDocumentSearchView_SearchByHeaderViewHeight + 6 + verticalSpace, 60, 30) font:kDocumentSearchView_HeaderFont textColor:kDocumentSearchView_TextColor backgroundColor:nil text:NSLocalizedString(@"ID_FROM_UPPERCASE", @"") superView:self];
        label.textAlignment = NSTextAlignmentRight;
        
        self.monthYearPickerButton1 = [[MonthYearPickerButton alloc] initWithFrame:[label rectAtRight:15 width:150] superView:self delegate:self];
        
        //TO
        label = [CommonLayout createLabel:[label rectAtBottom:verticalSpace height:30] font:kDocumentSearchView_HeaderFont textColor:kDocumentSearchView_TextColor backgroundColor:nil text:NSLocalizedString(@"ID_TO_UPPERCASE", @"") superView:self];
        label.textAlignment = NSTextAlignmentRight;
        
        self.monthYearPickerButton2 = [[MonthYearPickerButton alloc] initWithFrame:[label rectAtRight:15 width:150] superView:self delegate:self];
    }
    return self;
}

#pragma mark - ButtonGroupDelegate
- (void)handleSegmentControl:(id)sender {
    if (self.segmentControl.selectedSegmentIndex == 0) {
        self.monthYearPickerButton1.isShowingYear = self.monthYearPickerButton2.isShowingYear = NO;
        if (self.monthYearPickerButton1.selectedDateComps.month == -1)
            self.monthYearPickerButton1.selectedDateComps.month = self.monthYearPickerButton2.selectedDateComps.month = 1;
    } else {
        self.monthYearPickerButton1.isShowingYear = self.monthYearPickerButton2.isShowingYear = YES;
        if (self.monthYearPickerButton1.selectedDateComps.month > 0)
            self.monthYearPickerButton1.selectedDateComps.month = self.monthYearPickerButton2.selectedDateComps.month = -1;
    }
    [self.monthYearPickerButton1 updateUI];
    [self.monthYearPickerButton2 updateUI];
    if (self.monthYearPickerButton1.selectedDateComps) //if no date selected, nothing changes outside
        [self.delegate searchByDateView_ValueChanged:self date1:self.monthYearPickerButton1.selectedDateComps date2:self.monthYearPickerButton2.selectedDateComps];
}

#pragma mark - MonthYearPickerButtonDelegate
- (void)monthYearPickerButton:(id)sender valueChanged:(NSDateComponents *)dateComps {
    MonthYearPickerButton *button = (MonthYearPickerButton*)sender;
    MonthYearPickerButton *otherButton = (button == self.monthYearPickerButton1 ? self.monthYearPickerButton2 : self.monthYearPickerButton1);
    if (button.selectedDateComps) {
        if (otherButton.selectedDateComps == nil) {
            otherButton.selectedDateComps = button.selectedDateComps;
        }
    } else {
        if (otherButton.selectedDateComps) {
            otherButton.selectedDateComps = nil;
        }
    }
    [button updateUI];
    [otherButton updateUI];
    [self.delegate searchByDateView_ValueChanged:self date1:self.monthYearPickerButton1.selectedDateComps date2:self.monthYearPickerButton2.selectedDateComps];
}

#pragma mark - Button
- (void)handleDoneButton {
    if ([self.delegate respondsToSelector:@selector(searchComponentView_shouldClose:)])
        [self.delegate searchComponentView_shouldClose:self];
}

#pragma mark - MyFunc
- (void)setDate1:(NSDateComponents*)dateComps1 date2:(NSDateComponents*)dateComps2 {
    if (dateComps1.month == -1 && [self.segmentControl selectedSegmentIndex] == 0) {
        self.segmentControl.selectedSegmentIndex = 1;
    } else if (dateComps1.month > 0 && [self.segmentControl selectedSegmentIndex] == 1) {
        self.segmentControl.selectedSegmentIndex = 0;
    }
    self.monthYearPickerButton1.selectedDateComps = dateComps1;
    self.monthYearPickerButton2.selectedDateComps = dateComps2;
    [self.monthYearPickerButton1 updateUI];
    [self.monthYearPickerButton2 updateUI];
}

- (void)dismissPopopover {
    [self.monthYearPickerButton1 dismissPopopover];
    [self.monthYearPickerButton2 dismissPopopover];
}

@end
