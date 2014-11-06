//
//  DocumentGroupHeaderView.h
//  FileThis
//
//  Created by Manh nguyen on 12/12/13.
//
//

#import "BaseView.h"

@protocol DocumentGroupHeaderViewDelegate  <NSObject>

- (void)didViewAllButtonTouched:(id)sender documentGroup:(id)documentGroup;

@end

@interface DocumentGroupHeaderView : BaseView

@property (nonatomic, strong) UILabel *lblCabinetName, *lblDocumentCount, *line;
@property (nonatomic, strong) UIButton *btnViewAll, *btnDisclosure;
@property (nonatomic, strong) UIImageView *imgIcon;
@property (nonatomic, strong) id documentGroupObj;
@property (nonatomic, assign) id<DocumentGroupHeaderViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame documentGroup:(id)documentGroup;
- (void)updateIcon:(BOOL)isExpand;

@end
