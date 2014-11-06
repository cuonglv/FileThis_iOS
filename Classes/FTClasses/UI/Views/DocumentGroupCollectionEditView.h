//
//  DocumentGroupCollectionEditView.h
//  FileThis
//
//  Created by Manh nguyen on 1/14/14.
//
//

#import <UIKit/UIKit.h>

@protocol DocumentGroupCollectionEditViewDelegate <NSObject>

- (void)didShowEditingMode:(id)sender;
- (void)didCancelEditingMode:(id)sender;
- (void)didSelectAllEditingMode:(id)sender;

@end

@interface DocumentGroupCollectionEditView : UICollectionReusableView

@property (nonatomic, strong) UILabel *lblHeaderInSection;
@property (nonatomic, strong) id documentGroup;
@property (nonatomic, strong) UIButton *btnCancel, *btnSelect, *btnSelectAll;
@property (nonatomic, assign) BOOL editingMode;
@property (nonatomic, assign) id<DocumentGroupCollectionEditViewDelegate> delegate;
@property (nonatomic, strong) NSString *headerTitleFormat;

- (void)setDocumentGroupData:(id)group;
- (NSString *)getHeaderString;
- (void)refreshHeaderButtons:(BOOL)selectMode;

@end
