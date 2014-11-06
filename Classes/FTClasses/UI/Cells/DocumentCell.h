//
//  DocumentCell.h
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseCell.h"
#import "TagListView.h"
#import "DocumentInfoView.h"

@class DocumentCell;
@protocol DocumentCellDelegate <NSObject>

@optional
- (void)didButtonInfoTouched:(id)sender for:(DocumentObject *)docObj;
- (void)didCloseButtonTouched:(id)sender for:(DocumentObject *)docObj;
- (void)didTouchCell:(id)sender documentObject:(DocumentObject *)docObj;
- (void)documentCell:(DocumentCell*)cell willUpdateDocumentValue:(DocumentObject*)newDoc withProperties:(NSArray*)properties;

@end

@interface DocumentCell : BaseCell<DocumentInfoViewDelegate>

@property (nonatomic, strong) UIView *mainView;
@property (nonatomic, strong) UIImageView *imvThumb;
@property (nonatomic, strong) UILabel *lblName, *lblDate;
@property (nonatomic, strong) DocumentInfoView *documentInfoView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) TagListView *tagListView;
@property (nonatomic, strong) UIButton *btnInfo;
@property (nonatomic, assign) id<DocumentCellDelegate> delegate;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView *)tableView;
- (void)updateCellWithObject:(NSObject *)obj isSelected:(BOOL)isSelected;
- (void)showDocumentInfo:(BOOL)documentInfoVisible;
- (void)refreshThumbnail;

@end
