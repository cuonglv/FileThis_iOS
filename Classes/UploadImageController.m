//
//  UploadImageController.m
//  FTMobile
//
//  Created by decuoi on 12/15/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "UploadImageController.h"
#import "Constants.h"
#import "Layout.h"
#import "CommonVar.h"
#import "DocumentController.h"

@implementation UploadImageController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil image:(UIImage*)image {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
        img = image;
        myData = nil;
    }
    return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
    imv.image = img;
    [self.navigationController setNavigationBarHidden:NO];
    self.title = @"Upload File";
    lblUploadProgress.hidden = YES;
    
    //generate random file name
    NSDate *now = [NSDate date];
    int iDateInterval = [now timeIntervalSince1970];
    tfFileName.text = [NSString stringWithFormat:@"file%i.jpg", iDateInterval];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    vwAnimated = [MyAnimatedView newWithSuperview:self.view image:kImgSpinner];
    [Layout moveControl:vwAnimated toCenterOfControl:imv];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}




#pragma mark -
#pragma mark Button
- (IBAction)handleUploadBtn {
    tfFileName.text = [tfFileName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ([tfFileName.text length] == 0) {
        [Layout alertWarning:@"Please enter new file name" delegate:nil];
        [tfFileName becomeFirstResponder];
        return;
    }
    
    NSString *sFileName = [tfFileName.text stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSRange rangeOfJpgExt = [sFileName rangeOfString:@".jpg"];
    if (rangeOfJpgExt.length == 0)
        sFileName = [sFileName stringByAppendingString:@".jpg"];
    else if (rangeOfJpgExt.location != [sFileName length] - 4) {
        sFileName = [sFileName stringByAppendingString:@".jpg"];
    }
    
    NSURL *urlServerReq = [NSURL URLWithString:[kServer stringByAppendingFormat:@"ticket=%@&op=upload&filename=%@&path=/",[CommonVar ticket],sFileName]];
    //NSLog(@"DocPreview - load doc from server URL: %@", urlServerReq);
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlServerReq cachePolicy: NSURLCacheStorageNotAllowed timeoutInterval: 30];
    [request setHTTPMethod:@"POST"];
    
    NSString *boundry = @"0xKhTmLbOuNdArY";
    [request setValue:[NSString stringWithFormat:@"multipart/form-data; boundary=%@", boundry] forHTTPHeaderField:@"Content-Type"];
    
    NSData *data = UIImageJPEGRepresentation(imv.image, 1.0);
    
    NSMutableData *postData = [NSMutableData dataWithCapacity:[data length] + 512];
    [postData appendData:[[NSString stringWithFormat:@"--%@\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n\r\n", @"uploaded", sFileName] dataUsingEncoding:NSUTF8StringEncoding]];
    [postData appendData:data];
    [postData appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n", boundry] dataUsingEncoding:NSUTF8StringEncoding]];
    [request setHTTPBody:postData];
    //NSURLResponse *response = nil;
    //NSError *err = nil;
    
    //NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    lDocSize = [data length];
    myData = [[NSMutableData alloc] init];
    
    NSURLConnection *urlCon = [NSURLConnection connectionWithRequest:request delegate:self];
    lblUploadProgress.hidden = NO;
    [vwAnimated startMyAnimation];
    [urlCon start];
}



#pragma mark -
#pragma mark TextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField endEditing:YES];
    return YES;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self.view];
        if ([tfFileName isEditing]) {
            if ([Layout isPointOutsideControl:point forControl:tfFileName]) {
                [tfFileName endEditing:YES];
            }
        }
        
    }
}

#pragma mark -
#pragma mark URLConnectionDelegate

/*- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
}

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
}*/

- (void)connection:(NSURLConnection *)connection didSendBodyData:(NSInteger)bytesWritten totalBytesWritten:(NSInteger)totalBytesWritten totalBytesExpectedToWrite:(NSInteger)totalBytesExpectedToWrite {
    //NSLog(@"Uploading: %i - %i", totalBytesWritten, totalBytesExpectedToWrite);
    
    lblUploadProgress.text = [NSString stringWithFormat:@"%lli%%...", totalBytesWritten * 100 / lDocSize];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    //NSLog(@"DocPreview - connectionDidFinishLoading - write to file: %@, url: %@", sLocalDocPath, urlLocalDoc);
    lblUploadProgress.text = @"Upload finished";
    DocumentController *docCon = (DocumentController*)[CommonVar docCon];
    docCon.blnNeedToReloadDocInfo = YES;
    [vwAnimated stopMyAnimation];
}

@end
