//
//  UploadingProgressView.h
//  FileThis
//
//  Created by Cuong Le on 1/16/14.
//
//

#import <UIKit/UIKit.h>
#import "MyProgressView.h"

@protocol UploadingProgressViewDelegate <NSObject>
- (void)uploadingProgressView_Canceled:(id)sender;
- (void)uploadingProgressView_GoToDocuments:(id)sender;
- (void)uploadingProgressView_UploadAnother:(id)sender;
@end

@interface UploadingProgressView : UIView

@property (nonatomic, strong) MyProgressView *progressView;
- (id)initWithDocumentName:(NSString*)documentName pdfLocalFilePath:(NSString*)pdfLocalFilePath uploadingData:(NSData*)uploadingData superView:(UIView*)superView delegate:(id<UploadingProgressViewDelegate>)delegate;
- (void)startUploading;

@end
