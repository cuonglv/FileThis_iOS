//
//  DocumentControlView.m
//  FileThis
//
//  Created by Manh nguyen on 12/19/13.
//
//

#import "DocumentControlView.h"
#import "Utils.h"

#define INFO_WIDTH 22
#define INFO_HEIGHT 22

#define TAG_WIDTH 22
#define TAG_HEIGHT 22

#define DELETE_WIDTH 21
#define DELETE_HEIGHT 25

#define PADDING 35
#define kConfirmToDeleteDoc 1

@implementation DocumentControlView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIButton *delete = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - DELETE_WIDTH - 30, 27, DELETE_WIDTH, DELETE_HEIGHT)];
        [delete setBackgroundImage:[UIImage imageNamed:@"delete_icon.png"] forState:UIControlStateNormal];
        [self addSubview:delete];
        [delete addTarget:self action:@selector(handleDeleteButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *tag = [[UIButton alloc] initWithFrame:[delete rectAtLeft:PADDING width:TAG_WIDTH height:TAG_HEIGHT]];
        [tag setBackgroundImage:[UIImage imageNamed:@"tags_icon.png"] forState:UIControlStateNormal];
        [self addSubview:tag];
        [tag addTarget:self action:@selector(handleTagsButton:) forControlEvents:UIControlEventTouchUpInside];
        
        UIButton *info = [[UIButton alloc] initWithFrame:[tag rectAtLeft:PADDING width:INFO_WIDTH height:INFO_HEIGHT]];
        [info setBackgroundImage:[UIImage imageNamed:@"info_icon.png"] forState:UIControlStateNormal];
        [self addSubview:info];
        [info setTop:[delete top] + 2];
        [info addTarget:self action:@selector(handleInfoButton:) forControlEvents:UIControlEventTouchUpInside];
        
        [self setBackgroundColor:kDocumentGroupHeaderColor];
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

- (void)handleInfoButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didInfoButtonTouched:)]) {
        [self.delegate didInfoButtonTouched:self];
    }
}

- (void)handleTagsButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didTagsButtonTouched:)]) {
        [self.delegate didTagsButtonTouched:self];
    }
}

- (void)handleDeleteButton:(id)sender {
    [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_CONFIRM", @"") tag:kConfirmToDeleteDoc content:NSLocalizedString(@"ID_DELETE_DOC_CONFIRM", @"") delegate:self cancelButtonTitle:NSLocalizedString(@"ID_OK", @"") otherButtonTitles:NSLocalizedString(@"ID_CANCEL", @"")];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == kConfirmToDeleteDoc) {
        if (buttonIndex == 0) {
            if ([self.delegate respondsToSelector:@selector(didDeleteButtonTouched:)]) {
                [self.delegate didDeleteButtonTouched:self];
            }
        }
    }
}

@end
