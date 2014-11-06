//
//  CacheManager.m
//  FileThis
//
//  Created by Manh nguyen on 12/9/13.
//
//

#import "CacheManager.h"
#import "NSString+Custom.h"
#import "CommonFunc.h"
#import "NSData+AES256.h"

@implementation CacheManager

#define kServerKey  @"SERVER"

static CacheManager *instance = nil;
+ (CacheManager *)getInstance {
    @synchronized(self) {
        if (instance == nil) {
            instance = [[CacheManager alloc] init];
        }
    }
    
    return instance;
}

- (void)setServerUrl:(NSString *)serverUrl {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    [userDefault setValue:serverUrl forKey:kServerKey];
    [userDefault synchronize];
}

- (NSString *)getServerUrl {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *serverUrl = [[userDefault valueForKey:kServerKey] description];
    return serverUrl;
}

- (NSString *)getThumbnailFolderPath {
    if ([CommonFunc getUsername]) {
        NSString *cachedfolder = [[CACHE_ROOTPATH stringByAppendingPathComponent:CACHE_THUMBNAILS_FOLDER] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [CommonFunc getUsername]]];
        
        //create extend folder if not exist
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:cachedfolder]) {
            [fileManager createDirectoryAtPath:cachedfolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        return cachedfolder;
    }
    
    return nil;
}

- (NSString *)getDocumentFolderPath {
    if ([CommonFunc getUsername]) {
        NSString *cachedfolder = [[CACHE_ROOTPATH stringByAppendingPathComponent:CACHE_DOCUMENTS_FOLDER] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@", [CommonFunc getUsername]]];
        
        //create extend folder if not exist
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if (![fileManager fileExistsAtPath:cachedfolder]) {
            [fileManager createDirectoryAtPath:cachedfolder withIntermediateDirectories:YES attributes:nil error:nil];
        }
        
        return cachedfolder;
    }
    
    return nil;
}

- (NSString *)getTempFolderPath {
    return [NSTemporaryDirectory() stringByAppendingPathComponent:TEMP_DOCUMENTS_FOLDER];
}

- (void)setDocumentThumbnailCache:(DocumentObject *)documentObj size:(ThumbnailSize)size {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *thumbFolderPath = [self getThumbnailFolderPath];
    if (thumbFolderPath == nil) return;
    NSString *docFolderPath = [thumbFolderPath stringByAppendingPathComponent:[((NSNumber *)documentObj.id) stringValue]];
    
    if (![fileManager fileExistsAtPath:docFolderPath]) {
        [fileManager createDirectoryAtPath:docFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    // Delete old files
    NSArray *matches = [fileManager contentsOfDirectoryAtPath:docFolderPath error:&error];
    for (NSString *file in matches) {
        if ([file rangeOfString:[NSString stringWithFormat:@"%i_", size]].location != NSNotFound) {
            NSString *oldFilePath = [docFolderPath stringByAppendingPathComponent:file];
            [fileManager removeItemAtPath:oldFilePath error:&error];
        }
    }
    
    //Create new file: size_modifiedDate
    NSNumber *modifiedDate = documentObj.modified?documentObj.modified:documentObj.added;
    NSString *fileName = [NSString stringWithFormat:@"%i_%@", size, [modifiedDate stringValue]];
    NSString *filePath = [docFolderPath stringByAppendingPathComponent:[fileName md5]];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        return;
    }
    
    @synchronized(self) {
        NSData *data = UIImageJPEGRepresentation(documentObj.docThumbImage, 0.8f);
        if ([data length] > 0) {
            [data writeToFile:filePath atomically:YES];
        }
    }
}

- (UIImage *)getDocumentThumbnailCache:(DocumentObject *)documentObj size:(ThumbnailSize)size {
    NSString *thumbFolderPath = [self getThumbnailFolderPath];
    NSString *docFolderPath = [thumbFolderPath stringByAppendingPathComponent:[((NSNumber *)documentObj.id) stringValue]];
    NSNumber *modifiedDate = documentObj.modified?documentObj.modified:documentObj.added;
    NSString *fileName = [NSString stringWithFormat:@"%i_%@", size, [modifiedDate stringValue]];
    NSString *filePath = [docFolderPath stringByAppendingPathComponent:[fileName md5]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (![fileManager fileExistsAtPath:filePath]) {
        return nil;
    }
    NSError *error = nil;
    NSData *result = nil;
    
    @synchronized(self) {
        result = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
    }
    if (error) {
        result = nil;
    }
    return  [UIImage imageWithData:result];
}

- (NSString *)setDocumentDataCache:(NSData *)data forDoc:(DocumentObject *)documentObj {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error = nil;
    NSString *documentFolderPath = [self getDocumentFolderPath];
    if (documentFolderPath == nil) return nil;
    NSString *docIdFolderPath = [documentFolderPath stringByAppendingPathComponent:[((NSNumber *)documentObj.id) stringValue]];
    
    // Delete old docId folder
    if ([fileManager fileExistsAtPath:docIdFolderPath]) {
        [fileManager removeItemAtPath:docIdFolderPath error:&error];
    }
    
    if (![fileManager fileExistsAtPath:docIdFolderPath]) {
        [fileManager createDirectoryAtPath:docIdFolderPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    //docId_modifiedDate.ext
    NSNumber *modifiedDate = documentObj.modified?documentObj.modified:documentObj.added;
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@", [((NSNumber *)documentObj.id) stringValue], [modifiedDate stringValue], documentObj.filename];
    //NSString *filePath = [docIdFolderPath stringByAppendingPathComponent:[fileName md5]];
    NSString *filePath = [docIdFolderPath stringByAppendingPathComponent:fileName];
    
    if ([fileManager fileExistsAtPath:filePath]) {
        //delete it
        [fileManager removeItemAtPath:filePath error:&error];
    }
    
    @synchronized(self) {
        if ([data length] > 0) {
            // Encrypt data file
            NSData *encryptedData = [data AES256EncryptWithKey:[CommonFunc getSecretKey]];
            if ([encryptedData length] > 0) {
                [encryptedData writeToFile:filePath atomically:YES];
            }
            
            return [[CacheManager getInstance] createTempFile:data fileName:fileName];
        }
    }
    
    return nil;
}

- (NSString *)getDocumentDataCacheFor:(DocumentObject *)documentObj {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *docIdFolderPath = [[self getDocumentFolderPath] stringByAppendingPathComponent:[((NSNumber *)documentObj.id) stringValue]];
    
    // Delete old docId folder
    if (![fileManager fileExistsAtPath:docIdFolderPath]) {
        return nil;
    }
    
    NSNumber *modifiedDate = documentObj.modified?documentObj.modified:documentObj.added;
    NSString *fileName = [NSString stringWithFormat:@"%@_%@_%@", [((NSNumber *)documentObj.id) stringValue], [modifiedDate stringValue], documentObj.filename];
    //NSString *filePath = [docIdFolderPath stringByAppendingPathComponent:[fileName md5]];
    NSString *filePath = [docIdFolderPath stringByAppendingPathComponent:fileName];
    
    if (![fileManager fileExistsAtPath:filePath]) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *data = nil;
    
    @synchronized(self) {
        data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingUncached error:&error];
        
        // Descrypt data file
        NSData *decryptData = [data AES256DecryptWithKey:[CommonFunc getSecretKey]];
        
        // Create temp file
        return [[CacheManager getInstance] createTempFile:decryptData fileName:fileName];
    }
    
    return nil;
}

- (NSString *)createTempFile:(NSData *)data fileName:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:@"documents"];
    if (![fileManager fileExistsAtPath:tempFolder]) {
        [fileManager createDirectoryAtPath:tempFolder withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *tempFilePath = [tempFolder stringByAppendingPathComponent:fileName];
    [data writeToFile:tempFilePath atomically:YES];
    
    return tempFilePath;
}

- (void)deleteTempFiles {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *tempFolder = [NSTemporaryDirectory() stringByAppendingPathComponent:@"documents"];
    NSError *error;
    if ([fileManager fileExistsAtPath:tempFolder]) {
        [fileManager removeItemAtPath:tempFolder error:&error];
    }
}

- (BOOL)isExistCacheForUsername:(NSString *)username {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSString *documentFolderPath = [CACHE_ROOTPATH stringByAppendingPathComponent:CACHE_DOCUMENTS_FOLDER];
    
    NSError *error;
    NSArray *documentFolderList = [fileManager contentsOfDirectoryAtPath:documentFolderPath error:&error];
    for (NSString *folderName in documentFolderList) {
        if ([folderName isEqualToString:username]) return YES;
    }
    
    return NO;
}

- (void)clearCacheData{
    NSString *documentFolderPath = [CACHE_ROOTPATH stringByAppendingPathComponent:CACHE_DOCUMENTS_FOLDER];
    NSString *thumbnailFolderPath = [CACHE_ROOTPATH stringByAppendingPathComponent:CACHE_THUMBNAILS_FOLDER];
    
    NSError *error;
    NSArray *documentFolderList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:documentFolderPath error:&error];
    for (NSString *folderName in documentFolderList) {
        NSString *folderPath = [documentFolderPath stringByAppendingPathComponent:folderName];
        [[NSFileManager defaultManager] removeItemAtPath:folderPath error:&error];
    }
    
    NSArray *thumbnailFolderList = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:thumbnailFolderPath error:&error];
    for (NSString *folderName in thumbnailFolderList) {
        NSString *folderPath = [thumbnailFolderPath stringByAppendingPathComponent:folderName];
        [[NSFileManager defaultManager] removeItemAtPath:folderPath error:&error];
    }
}

@end
