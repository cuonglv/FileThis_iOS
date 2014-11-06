//
//  UploadDocumentCell.h
//  FileThis
//
//  Created by Cuong Le on 12/17/13.
//
//

#import <UIKit/UIKit.h>
#import "Constants.h"

#define kUploadDocumentCell_RemoveButtonRadius   15.0
#define kUploadDocumentCell_Size  (IS_IPHONE ? 120 : 150.0)

@protocol UploadDocumentCellDelegate <NSObject>
- (void)uploadDocumentCellTouched:(id)sender;
- (void)uploadDocumentCellRemoved:(id)sender;
@end

@interface UploadDocumentCell : UICollectionViewCell
@property (nonatomic, strong) UIImageView *myImageView;
@property (nonatomic, strong) UIButton *removeButton;
@property (nonatomic, assign) id<UploadDocumentCellDelegate> delegate;
//@property (nonatomic, strong) UILabel *myLabel; //still need?

- (void)setImage:(UIImage*)img;
@end
