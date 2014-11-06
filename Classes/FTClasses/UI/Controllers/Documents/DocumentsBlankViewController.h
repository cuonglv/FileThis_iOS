//
//  DocumentsBlankViewController.h
//  FileThis
//
//  Created by Manh Nguyen on 3/6/14.
//
//

#import "MyDetailViewController.h"
#import "FTDestination.h"

@interface DocumentsBlankViewController : MyDetailViewController

@property (nonatomic, strong) IBOutlet UILabel *text1, *text2, *text3;
@property (nonatomic, strong) IBOutlet UIButton *documentsButton;
@property (nonatomic, strong) IBOutlet UIImageView *logo;

@property (nonatomic, strong) FTDestination *destination;

- (IBAction)handleDocumentsButton:(id)sender;

@end
