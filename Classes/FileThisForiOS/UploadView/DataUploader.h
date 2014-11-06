//
//  DataUploader.h
//  OnMat
//
//  Created by Cuong Le Viet on 8/22/13.
//
//

#import <Foundation/Foundation.h>
#import "Constants.h"

@protocol DataUploaderDelegate <NSObject>
- (void)dataUploaderFinishedUploading:(id)sender;
- (void)dataUploaderFailToUpload:(id)sender;
@end

@interface DataUploader : NSObject {
    id<DataUploaderDelegate> dataUploaderDelegate;
}
@property (nonatomic,copy) NSString *uploadingURL, *fileName, *dataParamName, *dataContentType;
@property (nonatomic,retain) NSData *uploadingData;
@property (nonatomic,retain) NSArray *otherParamNames, *otherParamValues;
- (id)initWithURL:(NSString*)url fileName:(NSString*)fileName data:(NSData*)data dataParamName:(NSString*)dataParamName dataContentType:(NSString*)dataContentType otherParamNames:(NSArray*)otherParamNames otherParamValues:(NSArray*)otherParamValues delegate:(id<DataUploaderDelegate>)delegate;
- (NSData*)upload;
@end
