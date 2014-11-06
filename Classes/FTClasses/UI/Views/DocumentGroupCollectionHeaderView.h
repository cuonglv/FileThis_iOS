//
//  DocumentGroupCollectionHeaderView.h
//  FileThis
//
//  Created by Manh nguyen on 1/12/14.
//
//

#import <UIKit/UIKit.h>

@protocol DocumentGroupCollectionHeaderViewDelegate  <NSObject>

- (void)didViewAllButtonTouched:(id)sender documentGroup:(id)documentGroup;

@end

@interface DocumentGroupCollectionHeaderView : UICollectionReusableView

@property (nonatomic, strong) UILabel *lblCabinetName, *lblDocumentCount, *line;
@property (nonatomic, strong) UIButton *btnViewAll, *btnDisclosure;
@property (nonatomic, strong) UIImageView *imgIcon;
@property (nonatomic, strong) id documentGroupObj;
@property (nonatomic, assign) id<DocumentGroupCollectionHeaderViewDelegate> delegate;
@property (nonatomic, strong) UIView *sectionView;

- (void)updateIcon:(BOOL)isExpand;
- (void)updateData:(id)documentGroup;

@end
