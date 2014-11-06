//
//  MonthYearPickerButton.h
//  FileThis
//
//  Created by Cuong Le on 1/17/14.
//
//

#import <UIKit/UIKit.h>

@protocol MonthYearPickerButtonDelegate <NSObject>

- (void)monthYearPickerButton:(id)sender valueChanged:(NSDateComponents*)dateComps;

@end

@interface MonthYearPickerButton : UIButton

@property (nonatomic, strong) UILabel *searchDateButtonLabel;
@property (nonatomic, strong) UIImageView *searchDateButtonIconView;
@property (nonatomic, strong) NSDateComponents *selectedDateComps; //day or month = -1 to ignore
@property (nonatomic, assign) id<MonthYearPickerButtonDelegate> delegate;
@property (assign) BOOL isShowingYear;

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<MonthYearPickerButtonDelegate>)delegate;
- (void)updateUI;
- (void)dismissPopopover;

@end
