//
//  CacheManager.h
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "BaseObject.h"
#import "CommonVar.h"
#import "DocumentObject.h"

@interface CacheManager : BaseObject

+ (CacheManager *)getInstance;
- (void)setServerUrl:(NSString *)serverUrl;
- (NSString *)getServerUrl;

- (NSString *)getThumbnailFolderPath;
- (NSString *)getDocumentFolderPath;
- (NSString *)getTempFolderPath;

- (void)setDocumentThumbnailCache:(DocumentObject *)documentObj size:(ThumbnailSize)size;
- (UIImage *)getDocumentThumbnailCache:(DocumentObject *)documentObj size:(ThumbnailSize)size;

- (NSString *)setDocumentDataCache:(NSData *)data forDoc:(DocumentObject *)documentObj;
- (NSString *)getDocumentDataCacheFor:(DocumentObject *)documentObj;

- (BOOL)isExistCacheForUsername:(NSString *)username;
- (void)clearCacheData;

- (NSString *)createTempFile:(NSData *)data fileName:(NSString *)fileName;
- (void)deleteTempFiles;

@end
