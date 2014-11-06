//
//  DocumentSearchCriteriaCell.m
//  FileThis
//
//  Created by Cuong Le on 1/17/14.
//
//

#import "DocumentSearchCriteriaCell.h"

@interface DocumentSearchCriteriaCell()

@property (nonatomic, weak) UITableView *myTable;
@property (nonatomic, strong) TagCollectionCell *tagCollectionCell;
@property (nonatomic, strong) UIButton *goNextButton;
@property (nonatomic, assign) id<DocumentSearchCriteriaCellDelegate> delegate;

@end

@implementation DocumentSearchCriteriaCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView*)tableView delegate:(id<DocumentSearchCriteriaCellDelegate>)delegate {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.delegate = delegate;
        self.myTable = tableView;
        self.tagCollectionCell = [[TagCollectionCell alloc] initWithFrame:CGRectMake(20, roundf(self.myTable.rowHeight/2 -  kTagCollectionCell_Height/2), 300, kTagCollectionCell_Height)];
        [self addSubview:self.tagCollectionCell];
        
        self.goNextButton = [CommonLayout createImageButton:[self.tagCollectionCell rectAtRight:20 width:35 height:35] image:[UIImage imageNamed:@"go_next_icon.png"] contentMode:UIViewContentModeCenter touchTarget:self touchSelector:@selector(handleGoNextButton) superView:self];
        
        UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
        [self.tagCollectionCell addGestureRecognizer:tapGestureRecognizer];
    }
    return self;
}

- (void)setText:(NSString*)aText rightText:(NSString*)aRightText backgroundType:(TagCollectionCellBackgroundType)backgroundType indentLevel:(int)indentLevel {
    CGSize fitSize = [TagCollectionCell fitSizeForText:aText backgroundType:backgroundType maxWidth:self.myTable.frame.size.width-indentLevel*kDocumentSearchCriteriaCellIndent-80];
    [self.tagCollectionCell setWidth:fitSize.width height:fitSize.height];
    [self.tagCollectionCell setText:aText rightText:aRightText backgroundType:backgroundType];
    [self.tagCollectionCell setLeft:20+indentLevel*kDocumentSearchCriteriaCellIndent];
    [self.goNextButton moveToRightOfView:self.tagCollectionCell offset:20];
    self.goNextButton.hidden = ([aRightText length] == 0);
}

- (void)handleTapGestureRecognizer:(id)sender {
    [self.delegate documentSearchCriteriaCellTouched:self];
}

- (void)handleGoNextButton {
    [self.delegate documentSearchCriteriaCell_ShouldGoNext:self];
}
@end
