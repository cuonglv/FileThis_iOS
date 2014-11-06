//
//  FinishUploadingViewController.h
//  FileThis
//
//  Created by Cuong Le on 12/17/13.
//
//

#import "MyDetailViewController.h"

#define kUploadDocumentViewController_MaxUploadedImageFileLength        100 * 1024
#define kUploadDocumentViewController_MaxImageWidth     800
#define kUploadDocumentViewController_MaxImageHeight    1200

@interface FinishUploadingViewController : MyDetailViewController
@property (strong) NSMutableArray *takenImages;
@property (nonatomic, strong) NSData *uploadingData;
- (id)initWithTakenImages:(NSMutableArray*)takenImages;
@end
