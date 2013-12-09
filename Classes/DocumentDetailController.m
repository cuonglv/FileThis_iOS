//
//  DocumentDetailController.m
//  FTMobile
//
//  Created by decuoi on 12/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "DocumentDetailController.h"
#import "DocumentMetadataController.h"
#import "DocumentMetadataView.h"
#import "DocumentPreviewController.h"
#import "DocumentPreviewView.h"
#import "CommonVar.h"
#import "CommonFunc.h"
#import "SettingsController.h"

@implementation DocumentDetailController
@synthesize docCon, dictDoc, blnIsMetadataActive, tbiEmail;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        docCon = nil;
        vwDocMetadata = nil;
        vwDocPreview = nil;
        imgView = [UIImage imageNamed:@"eye_41x25.png"];
        imgInfo = [UIImage imageNamed:@"Info_26x26.png"];
        blnCallFirstLoadLater = NO;
        blnIsFirstLoad = YES;
    }
    return self;
}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.navigationController setNavigationBarHidden:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if (blnIsFirstLoad) {
        if (blnIsMetadataActive) {
            [self showMetadata];
        } else {
            [self showPreview];
        }
        blnCallFirstLoadLater = YES;
        blnIsFirstLoad = NO;
    }
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




#pragma mark -
#pragma mark UITabBarDelegate
- (void)tabBar:(UITabBar *)tabBar didSelectItem:(UITabBarItem *)item {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    if (item == tbiView) {
        [self performSelector:@selector(handleViewBarBtn) withObject:nil afterDelay:0.1];   //must delay to see item's selected style
    } else if (item == tbiSettings) {
        [self performSelector:@selector(handleSettingsBarBtn) withObject:nil afterDelay:0.1];   //must delay to see item's selected style
    } else if (item == tbiEmail) {
        [self performSelector:@selector(handleMailBarBtn) withObject:nil afterDelay:0.1];   //must delay to see item's selected style
    } else if (item == tbiLogout) {
        [self performSelector:@selector(handleLogoutBarBtn) withObject:nil afterDelay:0.1];   //must delay to see item's selected style
    }
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)handleMailBarBtn {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    //get first name
    NSDictionary *dictAccountInfo = nil;
    while (!(dictAccountInfo = [CommonVar dictAccountInfo])) { //wait until Account Info loaded
        [NSThread sleepForTimeInterval:.5];
    }
    NSArray *arrUsers = [dictAccountInfo valueForKey:@"users"];
    NSDictionary *dictUser = arrUsers[0];
    NSString *sFirstName = [dictUser valueForKey:@"first"];
    
    //get document download link
    int iDocId = [[dictDoc valueForKey:@"id"] intValue];
    NSString *sFileName = [dictDoc valueForKey:@"filename"];
    NSDictionary *dictDocGetLinks = [CommonFunc jsonObjGET:[[CommonVar requestURL] stringByAppendingFormat:@"docgetlinks&id=%i", iDocId]];
    NSArray *arrDocUrls = [dictDocGetLinks valueForKey:@"urls"];
    NSString *sDocUrl = arrDocUrls[0];
    NSString *sBranding = [dictDocGetLinks valueForKey:@"branding"];
    NSString *sMailBody = [NSString stringWithFormat:@"%@ has sent you a file. Click on the link below to view or download it.<br/><br/><a href=\"%@\">%@</a><br/><br/>(Note: this link is only valid for 72 hours (3 days) from the time it was sent)<br/><br/>%@", sFirstName, sDocUrl, sFileName, sBranding];
    
    MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
    
	[picker setSubject:[NSString stringWithFormat:@"FileThis Document For You From %@", sFirstName]];
    //NSString *sMimeType = [[dictDoc valueForKey:@"mimeType"] retain]; 
    
    [picker setMessageBody:sMailBody isHTML:YES];
    
	[self presentModalViewController:picker animated:YES];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [myTabBar setSelectedItem:nil];
}

- (void)handleSettingsBarBtn { 
    SettingsController *target = [[SettingsController alloc] initWithNibName:@"SettingsController" bundle:[NSBundle mainBundle]];
    [self.navigationController pushViewController:target animated:YES];
    [myTabBar setSelectedItem:nil];
}

- (void)handleViewBarBtn {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
	[UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:0.7];
    if (blnCallFirstLoadLater) {
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
    }

    blnIsMetadataActive = !blnIsMetadataActive;
    if (blnIsMetadataActive) {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:vwMain cache:YES];
        [vwDocPreview removeFromSuperview];
        [self showMetadata];
        [UIView commitAnimations];
    } else {
        [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:vwMain cache:YES];
        [vwDocMetadata removeFromSuperview];
        [self showPreview];
        [UIView commitAnimations];
    }
    [myTabBar setSelectedItem:nil];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}

- (void)handleLogoutBarBtn {
    [docCon logout];
    [self.navigationController popToRootViewControllerAnimated:YES];
}


#pragma mark -
#pragma mark MyFunc
- (void)showMetadata {
    if (!vwDocMetadata) {
        DocumentMetadataController *target = [[DocumentMetadataController alloc]initWithNibName:@"DocumentMetadataController" bundle:[NSBundle mainBundle]];
        vwDocMetadata = (DocumentMetadataView*)target.view;
        //[vwDocMetadata autorelease];
        vwDocMetadata.dictDoc = dictDoc;
        vwDocMetadata.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - myTabBar.frame.size.height);
        if (!blnCallFirstLoadLater)
            [vwDocMetadata firstLoad];
    }
    [vwMain addSubview:vwDocMetadata];
    tbiView.image = imgView;
    tbiView.title = @"View";
}

- (void)showPreview {
    if (!vwDocPreview) {
        DocumentPreviewController *target = [[DocumentPreviewController alloc]initWithNibName:@"DocumentPreviewController" bundle:[NSBundle mainBundle]];
        vwDocPreview = (DocumentPreviewView*)target.view;
        //[vwDocPreview autorelease];
        vwDocPreview.dictDoc = dictDoc;
        vwDocPreview.vwcDocumentDetail = self;
        vwDocPreview.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - myTabBar.frame.size.height);
        if (!blnCallFirstLoadLater)
            [vwDocPreview firstLoad];
    }
    [vwMain addSubview:vwDocPreview];
    tbiView.image = imgInfo;
    tbiView.title = @"Info";
}


#pragma mark -
#pragma mark Animation delegate
-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context {
    if (blnIsMetadataActive) {
        [vwDocMetadata firstLoad];
    } else {
        [vwDocPreview firstLoad];
    }
    blnCallFirstLoadLater = NO;
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
}


#pragma mark -
#pragma mark MFMailComposeViewController
// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{
    [self dismissModalViewControllerAnimated:YES];
}
@end