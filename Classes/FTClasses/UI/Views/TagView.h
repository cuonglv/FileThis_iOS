//
//  TagView.h
//  FileThis
//
//  Created by Manh nguyen on 12/17/13.
//
//

#import <UIKit/UIKit.h>
#import "TagObject.h"

#define TAG_VIEW_HEIGHT         20
#define TAG_VIEW_TEXT_MARGIN    12

typedef enum TagViewStyle {
    TagViewStyleNone, //Multiple lines
    TagViewStyleNoneOrange, //One line, have "Edit" button
} TagViewStyle;

@interface TagView : UIView

@property (nonatomic, strong) UIButton *tagButton;
@property (nonatomic, strong) UIImageView *tagIcon;
@property (nonatomic, strong) TagObject *tagObject;
@property (nonatomic, assign) TagViewStyle tagStyle;
@property (nonatomic, strong) UIButton *dotButton;

- (id)initWithTagObject:(TagObject *)tagObj tagViewStyle:(TagViewStyle)style;
- (void)restoreFullView;
- (void)showDotDotDotView;

@end
