//
//  SearchPdfTextView.h
//  FileThis
//
//  Created by Manh nguyen on 1/2/14.
//
//

#import "BaseView.h"

@protocol SearchPdfTextViewDelegate <NSObject>

- (void)didDoneButtonTouched:(id)sender;

@end

@interface SearchPdfTextView : BaseView<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *txtKeyword;
@property (nonatomic, strong) UIButton *btnDone;
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, assign) id<SearchPdfTextViewDelegate> delegate;

@end
