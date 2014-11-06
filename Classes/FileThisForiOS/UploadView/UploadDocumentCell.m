//
//  UploadDocumentCell.m
//  FileThis
//
//  Created by Cuong Le on 12/17/13.
//
//

#import "UploadDocumentCell.h"
#import "CommonLayout.h"
#import "UIImage+Ext.h"
#import "UIImage+Resize.h"

@interface UploadDocumentCell()


@end

@implementation UploadDocumentCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
//        float width = self.frame.size.width;
//        float height = self.frame.size.height;
//        self.myImageView = [CommonLayout createImageView:CGRectMake(width * 0.1,0, width * 0.8, height * 0.7) image:nil contentMode:UIViewContentModeScaleAspectFit superView:self];
//        self.myLabel = [CommonLayout createLabel:[self.myImageView rectAtBottom:0 height:height*0.3] fontSize:FontSizeXXSmall isBold:NO textColor:kTextOrangeColor backgroundColor:nil text:@"" superView:self];
        self.myImageView = [CommonLayout createImageView:CGRectMake(0, kUploadDocumentCell_RemoveButtonRadius, self.frame.size.width-kUploadDocumentCell_RemoveButtonRadius, self.frame.size.height - kUploadDocumentCell_RemoveButtonRadius) image:nil contentMode:UIViewContentModeScaleAspectFit superView:self];
        self.myImageView.layer.borderWidth = 1.0;
        self.myImageView.layer.borderColor = kTextGrayColor.CGColor;
        
        self.removeButton = [CommonLayout createImageButton:CGRectMake(self.frame.size.width-2*kUploadDocumentCell_RemoveButtonRadius,0,2*kUploadDocumentCell_RemoveButtonRadius,2*kUploadDocumentCell_RemoveButtonRadius) image:[UIImage imageNamed:@"x_icon_orange.png"] contentMode:UIViewContentModeScaleToFill touchTarget:self touchSelector:@selector(handleRemoveButton) superView:self];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
        [self addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)setHighlighted:(BOOL)highlighted {
    [super setHighlighted:highlighted];
    if (highlighted) {
//        self.myImageView.alpha = 0.5f;
        self.myImageView.layer.borderColor = kTextOrangeColor.CGColor;
        self.myImageView.layer.borderWidth = 3.0;
    } else {
//        self.myImageView.alpha = 1.0f;
        self.myImageView.layer.borderColor = kTextGrayColor.CGColor;
        self.myImageView.layer.borderWidth = 1.0;
    }
}

- (void)setImage:(UIImage*)img {
    //resize displayed image to reduce memory usage, avoid app crash
    [img setToImageView:self.myImageView];
}

#pragma mark - Gesture
- (void)handleTap:(id)sender {
    self.myImageView.layer.borderColor = [UIColor yellowColor].CGColor;
    self.myImageView.layer.borderWidth = 2.0;
    [self.delegate uploadDocumentCellTouched:self];
    [self performSelector:@selector(resetBorder) withObject:nil afterDelay:1.0];
}

#pragma mark - Button
- (void)handleRemoveButton {
    [self.delegate uploadDocumentCellRemoved:self];
}

- (void)resetBorder {
    [self setHighlighted:NO];
}
@end
