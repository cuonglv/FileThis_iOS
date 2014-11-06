//
//  DocumentSearchTextPopupCell.m
//  FileThis
//
//  Created by Cuong Le on 1/13/14.
//
//

#import "DocumentSearchTextPopupCell.h"
#import "CommonLayout.h"

@interface DocumentSearchTextPopupCell()

@property (nonatomic, weak) UITableView *myTable;

@end

@implementation DocumentSearchTextPopupCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView*)tableView cellIndex:(int)cellIndex collectionDelegate:(id<UICollectionViewDelegate,UICollectionViewDataSource>)collectionDelegate {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.myTable = tableView;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        flowLayout.minimumInteritemSpacing = 10.0;
        flowLayout.minimumLineSpacing = 0;
        flowLayout.sectionInset = UIEdgeInsetsMake(kDocumentSearchTextPopupCell_ContentInset, kDocumentSearchTextPopupCell_ContentInset, kDocumentSearchTextPopupCell_ContentInset, kDocumentSearchTextPopupCell_ContentInset);
        
        self.myCollectionView = [CommonLayout createCollectionView:CGRectMake(0,0, self.myTable.frame.size.width, self.myTable.rowHeight) backgroundColor:kClearColor layout:flowLayout cellClass:[TagCollectionCell class] cellIdentifier:[@"DocumentSearchTextPopupCell" stringByAppendingFormat:@"%i",cellIndex] superView:self delegateDataSource:collectionDelegate];
        self.myCollectionView.tag = cellIndex;
        self.myCollectionView.allowsSelection = YES;
        self.myCollectionView.scrollEnabled = YES;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state 
}

@end
