//
//  TagListView.h
//  FileThis
//
//  Created by Manh nguyen on 12/17/13.
//
//

#import <UIKit/UIKit.h>
#import "DocumentObject.h"
#import "TagView.h"

#define TAGLIST_VIEW_RIGHT_MARGIN_NORMAL    120
#define TAGLIST_VIEW_RIGHT_MARGIN_ORANGE    35

@protocol TagListViewDelegate <NSObject>
@optional
- (void)tagViewDidEditTouched:(id)sender forDocument:(DocumentObject *)docObj;
@end

@interface TagListView : UIView

@property (nonatomic, strong) DocumentObject *documentObj;
@property (nonatomic, strong) UILabel *lblDot;
@property (nonatomic, strong) UIButton *btnEditTag;
@property (nonatomic, assign) BOOL showEditTagButton;

@property (nonatomic, assign) id<TagListViewDelegate> delegate;

- (void)setStyle:(TagViewStyle)style documentObj:(DocumentObject *)doc;
+ (int)getRowCountForDocument:(DocumentObject *)doc byWidth:(float)width;

@end
