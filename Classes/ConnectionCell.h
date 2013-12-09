//
//  ConnectionCell.h
//  FileThis
//
//  Created by Cuong Le on 11/18/13.
//
//

#import <UIKit/UIKit.h>
#import "FTConnection.h"

@interface ConnectionCell : UITableViewCell {
}

@property (strong, nonatomic) FTConnection *connection;
@property (weak) id host;
@property (strong, nonatomic) IBOutlet UILabel *nameLabel;

- (id)initWithTableView:(UITableView*)tableView reuseIdentifier:(NSString *)reuseIdentifier;

- (IBAction)question:(UIButton *)sender;
- (IBAction)refresh:(id)sender;
- (IBAction)explain:(id)sender;

- (void)setConnection:(FTConnection *)connection withEditing:(BOOL)isEditing;

@end
