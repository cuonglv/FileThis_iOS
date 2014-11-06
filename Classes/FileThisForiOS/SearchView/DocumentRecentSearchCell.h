//
//  DocumentRecentSearchCell.h
//  FileThis
//
//  Created by Cuong Le on 1/11/14.
//
//

#import <UIKit/UIKit.h>
#import "CabinetObject.h"
#import "DocumentSearchCriteria.h"

@interface DocumentRecentSearchCell : UITableViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView*)tableview;
- (void)setDocumentSearchCriteria:(DocumentSearchCriteria*)criteria;
+ (float)heightForCellWithCriteria:(DocumentSearchCriteria*)criteria reuseId:(NSString*)cellId tableView:(UITableView*)tableview;
@end
