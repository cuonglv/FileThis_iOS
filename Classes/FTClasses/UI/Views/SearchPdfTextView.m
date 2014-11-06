//
//  SearchPdfTextView.m
//  FileThis
//
//  Created by Manh nguyen on 1/2/14.
//
//

#import "SearchPdfTextView.h"
#import "CommonLayout.h"

@implementation SearchPdfTextView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:kCabColorAll];
        
        // Initialization code
        UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 10, 150, 30)];
        [self addSubview:lbl];
        [lbl setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kWhiteColor backgroundColor:nil text:NSLocalizedString(@"ID_SEARCH_IN_DOC", @"") numberOfLines:0 textAlignment:NSTextAlignmentRight];
        self.lblTitle = lbl;
        
        self.txtKeyword = [CommonLayout createTextField:[lbl rectAtRight:10 width:frame.size.width - [lbl right] - 100] fontSize:kFontSizeNormal isBold:NO textColor:kDarkGrayColor backgroundColor:nil text:@"" superView:self];
        [self.txtKeyword setPlaceholder:NSLocalizedString(@"ID_TYPE_WORDS_OR_WORD", @"")];
        [self.txtKeyword setReturnKeyType:UIReturnKeySearch];
        self.txtKeyword.delegate = self;
        
        self.btnDone = [CommonLayout createTextButton:CGRectMake(frame.size.width - 100, 10, 100, 30) fontSize:kFontSizeNormal isBold:NO text:NSLocalizedString(@"ID_DONE", @"") textColor:kWhiteColor touchTarget:self touchSelector:@selector(handleDoneButton:) superView:self];
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

- (void)handleDoneButton:(id)sender {
    [self.txtKeyword resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(didDoneButtonTouched:)]) {
        [self.delegate didDoneButtonTouched:self];
    }
}

- (void)resetView {
    [self.txtKeyword setText:@""];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [self.txtKeyword resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(didDoneButtonTouched:)]) {
        [self.delegate didDoneButtonTouched:self];
    }
    return YES;
}

- (void)layoutSubviews {
    [self.txtKeyword setFrame:[self.lblTitle rectAtRight:10 width:self.frame.size.width - [self.lblTitle right] - 100]];
    [self.btnDone setFrame:CGRectMake(self.frame.size.width - 100, 10, 100, 30)];
}

@end
