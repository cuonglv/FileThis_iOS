//
//  SelectDateView.h
//  FileThis
//
//  Created by Manh nguyen on 1/20/14.
//
//

#import "BaseView.h"

@protocol SelectDateViewDelegate <NSObject>

- (void)didCloseDate:(id)sender;
- (void)didSelectDate:(id)sender date:(NSDate *)date;

@end

@interface SelectDateView : BaseView

@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIButton *btnCancel, *btnDone;
@property (nonatomic, assign) id<SelectDateViewDelegate> delegate;

- (void)setDate:(NSDate *)date;

@end
