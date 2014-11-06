//
//  DocumentInfoViewController.h
//  FileThis
//
//  Created by Cao Huu Loc on 2/25/14.
//
//

#import "MyDetailViewController.h"
#import "DocumentInfoView_iphone.h"
#import "DocumentObject.h"

@interface DocumentInfoViewController : MyDetailViewController <DocumentInfoViewDelegate, TagListViewDelegate>

@property (nonatomic, strong) NSMutableArray *arrDocuments;
@property (nonatomic, strong) DocumentInfoView_iphone *documentView;
@property (nonatomic, strong) DocumentObject *document;

@end
