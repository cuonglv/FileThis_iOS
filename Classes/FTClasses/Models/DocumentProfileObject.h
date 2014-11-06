//
//  DocumentProfileObject.h
//  FileThis
//
//  Created by Manh nguyen on 1/3/14.
//
//

#import "BaseObject.h"
#import "ProfileObject.h"

@interface DocumentProfileObject : BaseObject

@property (nonatomic, strong) ProfileObject *profileObj;
@property (nonatomic, strong) NSMutableArray *arrDocuments;

@end
