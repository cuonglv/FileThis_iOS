//
//  MyDebugLogViewController.m
//  FileThis
//
//  Created by Cuong Le on 2/20/14.
//
//

#import <MessageUI/MessageUI.h>
#import <Crashlytics/Crashlytics.h>
#import "MyDebugLogViewController.h"
#import "CommonLayout.h"
#import "MyLog.h"

@interface MyDebugLogViewController () <MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) UITextView *logTextView;
@property (nonatomic, strong) UIButton *closeButton, *clearButton, *sendMailButton;
@end

@implementation MyDebugLogViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0];
    self.closeButton = [CommonLayout createTextButton:CGRectMake(20, 30, 70, 40) fontSize:FontSizeMedium isBold:NO text:@"Close" textColor:[UIColor blueColor] touchTarget:self touchSelector:@selector(handleCloseButton) superView:self.view];
    self.clearButton = [CommonLayout createTextButton:[self.closeButton rectAtRight:40 width:70] fontSize:FontSizeMedium isBold:NO text:@"Clear" textColor:[UIColor blueColor] touchTarget:self touchSelector:@selector(handleClearButton) superView:self.view];
    self.sendMailButton = [CommonLayout createTextButton:CGRectMake(self.view.frame.size.width-90, 30, 70, 40) fontSize:FontSizeMedium isBold:NO text:@"Email" textColor:[UIColor blueColor] touchTarget:self touchSelector:@selector(handleEmailButton) superView:self.view];
    
    self.logTextView = [CommonLayout createTextView:CGRectMake(20, 70, self.view.frame.size.width-40, self.view.frame.size.height-100) fontSize:FontSizeSmall isBold:NO textColor:[UIColor blackColor] backgroundColor:[UIColor whiteColor] text:@"My log" superView:self.view delegate:nil];
    self.logTextView.text = [MyLog getLog];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)handleCloseButton {
    [self dismissViewControllerAnimated:YES completion:^(){}];
}

- (void)handleClearButton {
    [MyLog clearLog];
    self.logTextView.text = [MyLog getLog];
}

- (void)handleEmailButton {
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
    
    picker.mailComposeDelegate = self;
    [picker setSubject:@"FileThis for iOS Log"];
    
    // Set up the recipients.
    NSArray *toRecipients = [NSArray arrayWithObjects:@"cuonglv@planvsoftware.com", nil];
//    NSArray *ccRecipients = [NSArray arrayWithObjects:@"second@example.com", @"third@example.com", nil];
//    NSArray *bccRecipients = [NSArray arrayWithObjects:@"four@example.com", nil];
    [picker setToRecipients:toRecipients];
//    [picker setCcRecipients:ccRecipients];
//    [picker setBccRecipients:bccRecipients];
    
    // Attach an image to the email.
    NSData *myData = [NSData dataWithContentsOfFile:LOG_CACHE_PATH];
    [picker addAttachmentData:myData mimeType:@"text/html" fileName:@"Log.txt"];
    
    // Fill out the email body text.
    NSString *emailBody = @"<i>Log sent from FileThis for iOS app<i>";
    [picker setMessageBody:emailBody isHTML:YES];
    
    // Present the mail composition interface.
    [self presentViewController:picker animated:YES completion:^{  }];
}

// The mail compose view controller delegate method
- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [self dismissViewControllerAnimated:YES completion:^{ }];
}
@end
