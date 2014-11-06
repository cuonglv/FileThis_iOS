//
//  RecentDocumentsController.h
//  FileThis
//
//  Created by Cao Huu Loc on 1/21/14.
//
//

#import "DocumentListViewController.h"
#import "EGORefreshTableHeaderView.h"

@interface RecentDocumentsController : DocumentListViewController<EventProtocol, EGORefreshTableHeaderDelegate>
@property (nonatomic, strong) UIButton *reloadButton;

@property (nonatomic, strong) EGORefreshTableHeaderView *headerViewRefresh;
@property (nonatomic, assign) BOOL loadingData;

@end
