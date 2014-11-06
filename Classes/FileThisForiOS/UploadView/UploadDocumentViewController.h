//
//  UploadDocumentViewController.h
//  FileThis
//
//  Created by Cuong Le on 12/16/13.
//
//

#import "MyDetailViewController.h"
#import "DraggableCollectionViewFlowLayout.h"
#import "UICollectionView+Draggable.h"

#define kUploadDocumentViewController_MaxDisplayedImageFileLength       100 * 1024
#define kUploadDocumentViewController_MaxTotalUploadedPhotoDataSize      40000000

@interface UploadDocumentViewController : MyDetailViewController <UICollectionViewDelegate, UICollectionViewDataSource_Draggable, UIActionSheetDelegate, UIAlertViewDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate>

@end
