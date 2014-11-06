//
//  BaseCollectionCell.h
//  FileThis
//
//  Created by Manh nguyen on 1/12/14.
//
//

#import <UIKit/UIKit.h>

@interface BaseCollectionCell : UICollectionViewCell

@property (nonatomic, strong) NSObject *m_obj;
- (void)updateCellWithObject:(NSObject *)obj;

@end
