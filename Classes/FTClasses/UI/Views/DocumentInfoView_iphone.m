//
//  DocumentInfoView_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/25/14.
//
//

#import "DocumentInfoView_iphone.h"
#import "CommonLayout.h"

@implementation DocumentInfoView_iphone

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self.txtDocumentName setFont:[CommonLayout getFontWithSize:kFontSizeLarge isBold:NO]];
    }
    return self;
}

- (BOOL)shouldShowTitleHeader {
    return NO;
}

- (void)loadViewWithDocument:(DocumentObject *)documentObj {
    [super loadViewWithDocument:documentObj];
    //self.tagListView.showEditTagButton = NO;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self handleCloseButton:nil];
}

@end
