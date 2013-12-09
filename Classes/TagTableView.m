//
//  TagTableView.m
//  FTMobile
//
//  Created by decuoi on 12/2/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "TagTableView.h"
#import "CommonVar.h"
#import "TagData.h"
#import "TagController.h"

@implementation TagTableView
@synthesize blnViewOnly;

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
        blnViewOnly = NO;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/


#pragma mark Touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if (!blnViewOnly) {
        //NSLog(@"table view touch", @"");
        for (UITouch *touch in touches) {
            CGPoint point = [touch locationInView:self];
            NSIndexPath *indexPath = [self indexPathForRowAtPoint:point];
            if (indexPath) {
                TagCell *tagCell = (TagCell*)[self cellForRowAtIndexPath:indexPath];
                if ([tagCell changeCheck]) {
                    [self performSelector:@selector(checkCell:) withObject:tagCell afterDelay:0.1];
                    //must delay to see tag checked
                    //[self checkCell:tagCell];
                } else {
                    [self performSelector:@selector(uncheckCell:) withObject:indexPath afterDelay:0.1];
                    //must delay to see tag unchecked
                    //[self uncheckCell:indexPath];
                }
                
                return; //just handle first correct touch
            }
        }
    }
}

#pragma mark -
- (void)checkCell:(TagCell*)tagCell {
    TagController *tagCon = (TagController*)self.delegate;
    TagData *tagData = [tagCell tagData];
    int iNewIndex = [tagCon insertTagData:tagData toCheckedArray:YES];
    //NSLog(@"Tag Cell Data: %@", tagData.sTagName);
    
    [tagCon loadData];
    [self scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:iNewIndex inSection:0] atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
}
- (void)uncheckCell:(NSIndexPath*)indexPath {
    TagController *tagCon = (TagController*)self.delegate;
    [tagCon removeTagChecked:indexPath.row];
    [tagCon loadData];
}
@end
