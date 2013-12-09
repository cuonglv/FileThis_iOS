//
//  DestinationCell.h
//  FileThis
//
//  Created by Drew Wilson on 2/26/13.
//
//

#import <UIKit/UIKit.h>
#import "FTDestination.h"

@interface DestinationCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *logoView;
@property (weak, nonatomic) IBOutlet UILabel *nameView;

- (void)configure:(FTDestination *)destination;
@end
