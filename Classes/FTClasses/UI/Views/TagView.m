//
//  TagView.m
//  FileThis
//
//  Created by Manh nguyen on 12/17/13.
//
//

#import "TagView.h"

@interface TagView ()
@property (retain) UIView *fullView;
@property (retain) UIView *dotView;
@end

@implementation TagView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
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

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (id)initWithTagObject:(TagObject *)tagObj tagViewStyle:(TagViewStyle)style {
    self = [super init];
    if (self) {
        UIView *v = [[UIView alloc] initWithFrame:self.frame];
        self.fullView = v;
        v = [[UIView alloc] initWithFrame:self.frame];
        self.dotView = v;
        [self addSubview:self.fullView];
        [self addSubview:self.dotView];
        self.dotView.hidden = YES;
        
        //Full view
        self.tagStyle = style;
        self.tagObject = tagObj;
        if (style == TagViewStyleNone || style == TagViewStyleNoneOrange) {
            UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 3, 12, 12)];
            [icon setImage:[UIImage imageNamed:@"tag_icon_small.png"]];
            [self.fullView addSubview:icon];
            
            self.tagButton = [[UIButton alloc] init];
            [self.tagButton setTitle:self.tagObject.name forState:UIControlStateNormal];
            [self.tagButton setTitleColor:kGrayColor forState:UIControlStateNormal];
            if (style == TagViewStyleNoneOrange) {
                [self.tagButton setTitleColor:kCabColorAll forState:UIControlStateNormal];
            }
            
            UIFont *font = [UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeSmall];
            [self.tagButton.titleLabel setFont:font];
            [self.tagButton setEnabled:NO];
            
            CGSize sizeOfTag = [self.tagButton.titleLabel.text sizeWithFont:font constrainedToSize:CGSizeMake(500, 500) lineBreakMode:NSLineBreakByWordWrapping];
            [self.tagButton setFrame:CGRectMake(TAG_VIEW_TEXT_MARGIN, 0, sizeOfTag.width + 5, TAG_VIEW_HEIGHT)];
            [self.fullView addSubview:self.tagButton];
        }
        
        //Dot view
        self.dotButton = [UIButton buttonWithType:UIButtonTypeCustom];
        self.dotButton.frame = self.frame;
        UIFont *font = [UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeXNormal];
        [self.dotButton.titleLabel setFont:font];
        [self.dotButton setEnabled:NO];
        self.dotButton.backgroundColor = [UIColor clearColor];
        [self.dotButton setTitleColor:[self.tagButton titleColorForState:UIControlStateNormal] forState:UIControlStateNormal];
        [self.dotButton setTitle:@"..." forState:UIControlStateNormal];
        [self.dotButton setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        self.dotButton.titleLabel.textAlignment = NSTextAlignmentLeft;
        [self.dotView addSubview:self.dotButton];
        
        //Set width for tag button
        [self setWidth:self.tagButton.frame.size.width height:TAG_VIEW_HEIGHT];
        
        //Set frame for self, sub views
        CGRect rect = self.tagButton.frame;
        float width = rect.origin.x + rect.size.width;
        rect = self.frame;
        rect.size.width = width;
        self.frame = rect;
        self.fullView.frame = rect;
        self.dotView.frame = rect;
        self.dotButton.frame = rect;
    }
    return self;
}
#pragma GCC diagnostic pop

- (void)restoreFullView
{
    self.fullView.hidden = NO;
    self.dotView.hidden = YES;
}

- (void)showDotDotDotView
{
    self.fullView.hidden = YES;
    self.dotView.hidden = NO;
}

@end
