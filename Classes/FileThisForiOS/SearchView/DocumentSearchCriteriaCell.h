//
//  DocumentSearchCriteriaCell.h
//  FileThis
//
//  Created by Cuong Le on 1/17/14.
//
//

#import <UIKit/UIKit.h>
#import "TagCollectionCell.h"

#define kDocumentSearchCriteriaCellHeight   45.0
#define kDocumentSearchCriteriaCellIndent   (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 10.0 : 20.0)

@protocol DocumentSearchCriteriaCellDelegate <NSObject>

- (void)documentSearchCriteriaCellTouched:(id)sender;
- (void)documentSearchCriteriaCell_ShouldGoNext:(id)sender;

@end

@interface DocumentSearchCriteriaCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView*)tableView delegate:(id<DocumentSearchCriteriaCellDelegate>)delegate;
- (void)setText:(NSString*)aText rightText:(NSString*)aRightText backgroundType:(TagCollectionCellBackgroundType)backgroundType indentLevel:(int)indentLevel;

@end
