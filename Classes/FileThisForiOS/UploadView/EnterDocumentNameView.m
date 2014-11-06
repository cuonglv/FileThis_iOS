//
//  EnterDocumentNameView.m
//  FileThis
//
//  Created by Cuong Le on 12/26/13.
//
//

#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "EnterDocumentNameView.h"
#import "CommonLayout.h"
#import "DateHandler.h"

@implementation EnterDocumentNameView

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<EnterDocumentNameViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.enterDocumentNameViewDelegate = delegate;
        self.clipsToBounds = YES;
        self.layer.cornerRadius = 6;
        self.backgroundColor = [UIColor whiteColor];
        
        float leftMargin;
        FontSize titleFontSize, textFontSize;
        if (IS_IPHONE) {
            leftMargin = 10;
            titleFontSize = FontSizexSmall;
            textFontSize = FontSizeSmall;
        } else {
            leftMargin = 20;
            titleFontSize = FontSizeLarge;
            textFontSize = FontSizeMedium;
        }
        
        self.titleLabel = [CommonLayout createLabel:CGRectMake(5, 5, self.frame.size.width - 10, IS_IPHONE ? 65 : 50) fontSize:titleFontSize isBold:YES isItalic:NO textColor:kTextGrayColor backgroundColor:nil text:@"Your document is ready to upload." superView:self];
        self.titleLabel.numberOfLines = (IS_IPHONE ? 2 : 1);
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        
        self.descriptionLabel = [CommonLayout createLabel:CGRectMake(leftMargin, 60, self.frame.size.width - 2 * leftMargin, 40) fontSize:textFontSize isBold:NO isItalic:YES textColor:kTextGrayColor backgroundColor:nil text:@"Name your upload document" superView:self];
        self.descriptionLabel.textAlignment = NSTextAlignmentLeft;
        
        NSDateComponents *today = [DateHandler todayDateComps];
        NSString *defaultDocumentName = [NSString stringWithFormat:@"iOS Upload %@",[DateHandler yyyyMMddStringFromDateComps:today]];
        
        self.nameTextField = [CommonLayout createTextField:[self.descriptionLabel rectAtBottom:0 height:38] font:self.descriptionLabel.font textColor:self.descriptionLabel.textColor backgroundColor:nil text:defaultDocumentName superView:self];
        self.nameTextField.placeholder = @"Enter the title of document";
        self.nameTextField.delegate = self;
        
        self.cancelButton = [CommonLayout createTextButton:CGRectMake(0, self.frame.size.height-45, self.frame.size.width/2, 45) fontSize:textFontSize isBold:NO text:NSLocalizedString(@"ID_CANCEL", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleCancelButton) superView:self];
        self.uploadButton = [CommonLayout createTextButton:[self.cancelButton rectAtRight:-1 width:self.cancelButton.frame.size.width+1] fontSize:textFontSize isBold:YES text:NSLocalizedString(@"ID_UPLOAD", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleUploadButton) superView:self];
        self.layer.borderColor = self.cancelButton.layer.borderColor = self.uploadButton.layer.borderColor = kBorderLightGrayColor.CGColor;
        self.layer.borderWidth = self.cancelButton.layer.borderWidth = self.uploadButton.layer.borderWidth = 1.0;
        
        [superView addSubview:self];
    }
    return self;
}

- (void)handleCancelButton {
    [self.nameTextField endEditing:YES];
    [self.enterDocumentNameViewDelegate enterDocumentNameView_DidCancel:self];
}

- (void)handleUploadButton {
    if ([[self.nameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length] == 0) {
        [CommonLayout showWarningAlert:NSLocalizedString(@"ID_WARNING_ENTER_DOCUMENT_NAME", @"") errorMessage:nil delegate:nil];
        [self.nameTextField becomeFirstResponder];
        return;
    }
    [self.nameTextField endEditing:YES];
    [self.enterDocumentNameViewDelegate enterDocumentNameView:self doneWithName:self.nameTextField.text];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.nameTextField) {
        [self.nameTextField resignFirstResponder];
        return YES;
    }
    
    return NO;
}

@end
