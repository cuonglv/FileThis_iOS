//
//  DocumentsBlankViewController.m
//  FileThis
//
//  Created by Manh Nguyen on 3/6/14.
//
//

#import "DocumentsBlankViewController.h"
#import "Utils.h"

@interface DocumentsBlankViewController ()

@end

@implementation DocumentsBlankViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)relayout {
    [super relayout];
    
    [self.text1 setWidth:self.view.bounds.size.width];
    [self.text2 setWidth:self.view.bounds.size.width];
    
    [self.documentsButton setLeft:self.view.bounds.size.width/2 - self.documentsButton.frame.size.width/2];
    [self.logo setLeft:self.view.bounds.size.width/2 - self.logo.frame.size.width/2];
    [self.text3 setLeft:self.view.bounds.size.width/2 - self.text3.frame.size.width/2];
}

- (void)initializeScreen {
    [super initializeScreen];
    
    UIFont *font = [CommonLayout getFont:FontSizeMedium isBold:NO];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        font = [CommonLayout getFont:FontSizeXSmall isBold:NO];
    }
    
    [self.logo setContentMode:UIViewContentModeScaleAspectFit];
    [self.text1 setText:[NSString stringWithFormat:NSLocalizedString(@"ID_DOCUMENT_BLANK_TEXT1", @""), self.destination.name]];
    [self.text1 setFont:font];
    [self.text2 setText:[NSString stringWithFormat:NSLocalizedString(@"ID_DOCUMENT_BLANK_TEXT2", @""), self.destination.name]];
    [self.text2 setFont:font];
    
    [self.text3 setText:[NSString stringWithFormat:NSLocalizedString(@"ID_OPEN_DOCUMENTS_ON", @""), self.destination.name]];
    [self.text3 setFont:font];
    
    [self.destination configureForImageView:self.logo];
}

- (IBAction)handleDocumentsButton:(id)sender {
    NSURL *url = [self getAppUrlScheme];
    if (url != nil && [[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    } else {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:[NSString stringWithFormat:NSLocalizedString(@"ID_APP_NOT_INSTALLED", @""), self.destination.name] delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
    }
}

- (NSURL *)getAppUrlScheme {
    NSString *provider = [self.destination.provider stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([provider isEqualToString:DEST_EVERNOTE_PROVIDER]) {
        return [NSURL URLWithString:@"evernote://"];
    } else if ([provider isEqualToString:DEST_DROPBOX_PROVIDER]) {
        return [NSURL URLWithString:@"dbapi-1://"];
    } else if ([provider isEqualToString:DEST_BOX_PROVIDER]) {
        return [NSURL URLWithString:@"box://"];
    } else if ([provider isEqualToString:DEST_GOOGLE_DRIVE_PROVIDER]) {
        return [NSURL URLWithString:@"googledrive://"];
    } else if ([provider isEqualToString:DEST_PERSONAL_PROVIDER]) {
        return [NSURL URLWithString:@"prsnl://"];
    } else if ([provider isEqualToString:DEST_EVERNOTE_B_PROVIDER]) {
        return [NSURL URLWithString:@"evernote://"];
    } else if ([provider isEqualToString:DEST_ABOUTONE_PROVIDER]) {
        return [NSURL URLWithString:@"aboutone://"];
    }
    
    return nil;
}

@end
