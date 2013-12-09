//
//  ConnectionErrorViewController.m
//  FileThis
//
//  Created by Drew Wilson on 12/28/12.
//
//

#import <Crashlytics/Crashlytics.h>
#import "UIKitExtensions.h"
#import "ConnectionErrorViewController.h"

#import "FTInstitution.h"
#import "FTSession.h"

@interface ConnectionErrorViewController ()
@property (nonatomic, strong) FTConnection *connection;
@property (weak, nonatomic) IBOutlet UILabel *messageTextView;
@property (weak, nonatomic) IBOutlet UIImageView *institutionIconView;
@property (weak, nonatomic) IBOutlet UILabel *institutionNameView;
@end

@implementation ConnectionErrorViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)dealloc {
    CLS_LOG(@"dealloc %@", self.class);
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"ConnectionErrorViewController viewWillAppear:");
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"ConnectionErrorViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self updateMessage];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateMessage
{
    if (self.messageTextView != nil && self.connection != nil) {
        NSString *rawMessage = self.messageTextView.text;
        FTInstitution *institution = [[FTSession sharedSession] institutionWithId:self.connection.institutionId];
        NSString *message = [NSString stringWithFormat:rawMessage,
                             self.connection.name, institution.homePageAddress];
        self.messageTextView.text = message;
        self.institutionNameView.text = institution.name;
        [self.institutionIconView setImageWithURL:institution.logoURL placeholderImage:[FTInstitution placeholderImage] cached:YES];
    }
}

- (void)setConnection:(FTConnection *)connection {
    _connection = connection;
    [self updateMessage];
}

- (void)dismiss
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    } else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - Actions

- (IBAction)ok:(id)sender {
    [self dismiss];
}

- (IBAction)retry:(id)sender {
    [self.connection refetch];
    [self dismiss];
    //    [self.host performSelector:@selector(refetch) withObject:self.connection];
}

#pragma mark - UIPopoverControllerDelegate delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController {
    self.popover = nil;
    NSLog(@"dispose of vc?");
}

@end
