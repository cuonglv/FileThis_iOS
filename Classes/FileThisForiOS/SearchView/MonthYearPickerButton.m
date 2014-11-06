//
//  MonthYearPickerButton.m
//  FileThis
//
//  Created by Cuong Le on 1/17/14.
//
//

#import "MonthYearPickerButton.h"
#import "DocumentSearchViewConstant.h"
#import "SearchDatePopupViewController.h"
#import "CommonLayout.h"
#import "FTMobileAppDelegate.h"
#import "DateHandler.h"
#import "MyPopoverWrapper.h"

@interface MonthYearPickerButton() <SearchDatePopupViewControllerDelegate>

@property (nonatomic, strong) SearchDatePopupViewController *searchDatePopupViewController;
@property (nonatomic, strong) MyPopoverWrapper *popupViewController;

@end

@implementation MonthYearPickerButton

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<MonthYearPickerButtonDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        
        self.layer.borderColor = kBorderLightGrayColor.CGColor;
        self.layer.borderWidth = 1.0;
        self.layer.cornerRadius = 5.0;
        self.backgroundColor = [UIColor whiteColor];
        [self addTarget:self action:@selector(handleSearchDateButton) forControlEvents:UIControlEventTouchUpInside];
        
        self.searchDateButtonLabel = [CommonLayout createLabel:CGRectMake(10, 4, self.frame.size.width - 40, self.frame.size.height-8) font:[CommonLayout getFont:FontSizeXSmall isBold:NO isItalic:YES] textColor:kDocumentSearchView_TextColor backgroundColor:nil text:NSLocalizedString(@"ID_TAP_TO_SELECT", @"") superView:self];
        self.searchDateButtonIconView = [CommonLayout createImageView:CGRectMake(self.frame.size.width - 38, 4, 36, self.frame.size.height-8) image:[UIImage imageNamed:@"date_icon_orange.png"] contentMode:UIViewContentModeScaleAspectFit superView:self];
        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.searchDatePopupViewController = [[SearchDatePopupViewController alloc] initWithNibName:nil bundle:nil];
            self.searchDatePopupViewController.delegate = self;
            self.popupViewController = [[MyPopoverWrapper alloc] initWithContentViewController:self.searchDatePopupViewController];
            self.popupViewController.popoverContentSize = CGSizeMake(kSearchDatePopupViewWidth, kSearchDatePopupViewHeight);
//        }
        [superView addSubview:self];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.popupViewController.isPopoverVisible) {
        UIView *vw = ((FTMobileAppDelegate*)[UIApplication sharedApplication].delegate).navigationController.view;
        [self.popupViewController presentPopoverFromRect:[self.superview convertRect:self.frame toView:vw] inView:vw permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    }
}

#pragma mark - SearchDatePopupViewControllerDelegate
- (void)searchDatePopupViewController_Canceled:(id)sender {
    [self.popupViewController dismissPopoverAnimated:YES];
    if (self.selectedDateComps) {
        self.selectedDateComps = nil;
        [self.delegate monthYearPickerButton:self valueChanged:self.selectedDateComps];
        [self updateUI];
    }
}

- (void)searchDatePopupViewController_Done:(id)sender {
    self.selectedDateComps = [self.searchDatePopupViewController selectedDateComps];
    [self updateUI];
    [self.popupViewController dismissPopoverAnimated:YES];
    [self.delegate monthYearPickerButton:self valueChanged:self.selectedDateComps];
}

#pragma mark - Button
- (void)handleSearchDateButton {
    [self.searchDatePopupViewController setDate:self.selectedDateComps isShowingYear:self.isShowingYear];
    UIView *vw = ((FTMobileAppDelegate*)[UIApplication sharedApplication].delegate).navigationController.view;
    [self.popupViewController presentPopoverFromRect:[self.superview convertRect:self.frame toView:vw] inView:vw permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

#pragma mark - MyFunc
- (void)updateUI {
    if (self.selectedDateComps) {
        self.searchDateButtonLabel.text = [DateHandler displayedMonthYearStringForDateComps:self.selectedDateComps];
        self.searchDateButtonLabel.font = kDocumentSearchView_Font;
    } else {
        self.searchDateButtonLabel.text = NSLocalizedString(@"ID_TAP_TO_SELECT", @"");
        self.searchDateButtonLabel.font = [CommonLayout getFont:FontSizeXSmall isBold:NO isItalic:YES];
    }
}

- (void)dismissPopopover {
    if (self.popupViewController.isPopoverVisible) {
        [self.popupViewController dismissPopoverAnimated:NO];
    }
}

@end
