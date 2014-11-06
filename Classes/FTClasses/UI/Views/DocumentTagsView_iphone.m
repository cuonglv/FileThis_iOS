//
//  DocumentTagsView_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/27/14.
//
//

#import "DocumentTagsView_iphone.h"

@implementation DocumentTagsView_iphone

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.lblTitle.text = @"Tags";
        self.lblTitle.textAlignment = NSTextAlignmentCenter;
        self.lblTitle.font = [CommonLayout getFont:18 isBold:YES];
        
        self.topView.frame = CGRectMake(0, 0, self.bounds.size.width, 80);
        
        int searchMargin = 5;
        self.txtSearchTags.frame = CGRectMake(10, 40 + searchMargin, self.bounds.size.width - 20, 40 - searchMargin*2);
        
        self.lblTemp.hidden = YES;
        [self.btnAddThisTag setTitle:@"Add" forState:UIControlStateNormal];
        self.btnAddThisTag.backgroundColor = [UIColor clearColor];
        
        [self.btnDone setContentHorizontalAlignment:UIControlContentHorizontalAlignmentCenter];
    }
    return self;
}

- (void)refreshTextStatus {
    [super refreshTextStatus];
    if (self.selectTagsView.isEditting) {
        self.lblTitle.text = NSLocalizedString(@"ID_EDIT_TAG", @"");
    } else {
        self.lblTitle.text = NSLocalizedString(@"ID_TAGS_NO_DOT", @"");
    }
}

#pragma mark - Layout
- (void)layoutSubviews_topView {
    int searchMargin = 5;
    self.topView.frame = CGRectMake(0, 0, self.frame.size.width, 80);
    self.lblTitle.frame = CGRectMake(0, 0, self.frame.size.width, 40);
    self.txtSearchTags.frame = CGRectMake(10, 40 + searchMargin, self.bounds.size.width - 20 - 50, 40 - searchMargin*2);
    
    CGRect rect = self.editButton.frame;
    rect.origin.x = 0;
    self.editButton.frame = rect;
    
    rect = self.btnDone.frame;
    rect.origin.x = self.frame.size.width - rect.size.width - 5;
    self.btnDone.frame = rect;
    
    self.btnAddThisTag.frame = [self.txtSearchTags rectAtRight:5 width:50];
}

#pragma mark - Touch events
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [self.txtSearchTags resignFirstResponder];
}

@end
