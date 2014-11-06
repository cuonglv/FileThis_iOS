//
//  DocumentSearchTextPopupCell.h
//  FileThis
//
//  Created by Cuong Le on 1/13/14.
//
//

#import <UIKit/UIKit.h>
#import "TagCollectionCell.h"

#define kDocumentSearchTextPopupCell_ContentInset   15.0

@interface DocumentSearchTextPopupCell : UITableViewCell

@property (nonatomic, strong) UICollectionView *myCollectionView;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView*)tableView cellIndex:(int)cellIndex collectionDelegate:(id<UICollectionViewDelegate,UICollectionViewDataSource>)collectionDelegate;

@end
