//
//  TagListView.m
//  FileThis
//
//  Created by Manh nguyen on 12/17/13.
//
//

#import "TagListView.h"
#import "TagObject.h"
#import "TagDataManager.h"
#import "TagView.h"

#define TOP_PADDING             10
#define SPACE_BETWEEN_TAGS      10

@implementation TagListView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.clipsToBounds = NO;
        
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.btnEditTag = btn;
        
        [self.btnEditTag setFrame:CGRectMake(0, -5, 30, 30)];
        [self.btnEditTag setImage:[UIImage imageNamed:@"edit_icon.png"] forState:UIControlStateNormal];
        [self.btnEditTag addTarget:self action:@selector(handleButtonTag:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnEditTag setImageEdgeInsets:UIEdgeInsetsMake(4, 8, 4, 0)];
        [self addSubview:self.btnEditTag];
        self.btnEditTag.hidden = YES;
    }
    return self;
}

- (void)setShowEditTagButton:(BOOL)show {
    _showEditTagButton = show;
    self.btnEditTag.hidden = !show;
}

- (void)setStyle:(TagViewStyle)style documentObj:(DocumentObject *)doc {
    [self removeAllSubViews];
    
    self.documentObj = doc;
    int x = 0;
    int y = 0;
    int padding = SPACE_BETWEEN_TAGS;
    
    int rightMargin = TAGLIST_VIEW_RIGHT_MARGIN_NORMAL;
    if (style == TagViewStyleNoneOrange)
        rightMargin = TAGLIST_VIEW_RIGHT_MARGIN_ORANGE;
    
    for (id tagId in doc.tags) {
        TagObject *tagObj = [[TagDataManager getInstance] getObjectByKey:tagId];
        if (tagObj != nil) {
            TagView *tagView = [[TagView alloc] initWithTagObject:tagObj tagViewStyle:style];
            [tagView setLeft:x top:y];
            
            if (x < self.frame.size.width - tagView.frame.size.width - rightMargin) {
                [self addSubview:tagView];
                x = x + tagView.frame.size.width + padding;
            } else {
                if (style == TagViewStyleNoneOrange) {
                    x = x + tagView.frame.size.width + padding;
                    [self addSubview:tagView];
                } else {
                    [self addSubview:tagView];
                    
                    x = 0;
                    y = y + TAG_VIEW_HEIGHT;
                    [self setHeight:self.frame.size.height + TAG_VIEW_HEIGHT];
                }
            }
        }
    }
    
    [self addSubview:self.btnEditTag];
    self.btnEditTag.hidden = (style == TagViewStyleNone);
}

- (void)layoutSubviews {
    int x = 0;
    int y = 0;
    int tagCount = 0;
    int rowCount = 1;
    BOOL hideRemainingTag = NO;
    for (UIView *view in [self subviews]) {
        if ([view isKindOfClass:[TagView class]]) {
            tagCount++;
            TagView *tagView = (TagView *)view;
            BOOL newLine = NO;
            float oldX = x;
            if (x + tagView.frame.size.width < self.frame.size.width) {
                [tagView setLeft:x top:y];
            } else {
                newLine = YES;
                x = 0;
                y = y + TAG_VIEW_HEIGHT;
                [tagView setLeft:x top:y];
                rowCount++;
            }
            
            x += tagView.frame.size.width + SPACE_BETWEEN_TAGS;
            [tagView setHidden:hideRemainingTag];
            [tagView restoreFullView];
            
            if (newLine && tagView.tagStyle == TagViewStyleNoneOrange) {
                hideRemainingTag = YES;
                [tagView setLeft:oldX top:y-TAG_VIEW_HEIGHT];
                [tagView showDotDotDotView];
            }
        }
    }
    //NSLog(@"TagCount: %d - RowCount: %d", tagCount, rowCount);
    //[self setHeight:[lastestTag bottom]];
    [self.btnEditTag setRight:self.frame.size.width];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
+ (int)getRowCountForDocument:(DocumentObject *)doc byWidth:(float)width
{
    if (doc.tags.count == 0)
        return 0;
    
    int row = 1;
    float nextX = 0;
    for (id tagId in doc.tags) {
        TagObject *tagObj = [[TagDataManager getInstance] getObjectByKey:tagId];
        CGSize sizeOfTag = [tagObj.name sizeWithFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeSmall] constrainedToSize:CGSizeMake(500, 500) lineBreakMode:NSLineBreakByWordWrapping];
        float viewWidth = TAG_VIEW_TEXT_MARGIN + sizeOfTag.width + 5;
        if (nextX + viewWidth >= width) {
            row++;
            nextX = viewWidth + SPACE_BETWEEN_TAGS;
        } else {
            nextX += viewWidth + SPACE_BETWEEN_TAGS;
        }
    }
    
    return row;
}
#pragma GCC diagnostic pop

#pragma mark - Button events
- (void)handleButtonTag:(id)sender {
    if ([self.delegate respondsToSelector:@selector(tagViewDidEditTouched:forDocument:)]) {
        [self.delegate tagViewDidEditTouched:self forDocument:self.documentObj];
    }
}

@end
