//
//  SelectDateView.m
//  FileThis
//
//  Created by Manh nguyen on 1/20/14.
//
//

#import "SelectDateView.h"
#import "CommonLayout.h"

#define PADDING     20

@implementation SelectDateView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIDatePicker *datePicker=[[UIDatePicker alloc]init];//Date picker
        datePicker.frame = CGRectMake(PADDING, PADDING, frame.size.width - PADDING*2, frame.size.height - 40);
        datePicker.datePickerMode = UIDatePickerModeDate;
        [datePicker setMinuteInterval:5];
        [datePicker setTag:10];
        [datePicker addTarget:self action:@selector(dateChanged:) forControlEvents:UIControlEventValueChanged];
        self.datePicker = datePicker;
        [self addSubview:self.datePicker];
        
        UIButton *cancel = [UIButton buttonWithType:UIButtonTypeCustom];
        [cancel setFrame:CGRectMake(0, [self.datePicker bottom] + 10, 150, 30)];
        self.btnCancel = cancel;
        [self.btnCancel setTitle:NSLocalizedString(@"ID_CANCEL", @"") forState:UIControlStateNormal];
        [self.btnCancel setTitleColor:kCabColorAll forState:UIControlStateNormal];
        [self.btnCancel.titleLabel setFont:[CommonLayout getFont:kFontSizeLarge isBold:NO]];
        [self addSubview:self.btnCancel];
        [self.btnCancel addTarget:self action:@selector(handleCancelButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *done = [UIButton buttonWithType:UIButtonTypeCustom];
        [done setFrame:CGRectMake([self.btnCancel right], [self.datePicker bottom] + 10, 150, 30)];
        self.btnDone = done;
        [self.btnDone setTitle:NSLocalizedString(@"ID_DONE", @"") forState:UIControlStateNormal];
        [self.btnDone setTitleColor:kCabColorAll forState:UIControlStateNormal];
        [self.btnDone.titleLabel setFont:[CommonLayout getFont:kFontSizeLarge isBold:NO]];
        [self addSubview:self.btnDone];
        [self.btnDone addTarget:self action:@selector(handleDoneButton:) forControlEvents:UIControlEventTouchUpInside];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setDate:(NSDate *)date {
    [self.datePicker setDate:date];
}

- (void)dateChanged:(id)sender {
}

- (void)handleCancelButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didCloseDate:)]) {
        [self.delegate didCloseDate:self];
    }
}

- (void)handleDoneButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectDate:date:)]) {
        [self.delegate didSelectDate:self date:self.datePicker.date];
    }
}

@end
