//
//  DocumentPreviewView.m
//  FTMobile
//
//  Created by decuoi on 12/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "DocumentPreviewView.h"
#import "Constants.h"
#import "CommonVar.h"
#import "Layout.h"
#import "CommonFunc.h"
#import "DocumentDetailController.h"

@implementation DocumentPreviewView
@synthesize dictDoc;
@synthesize vwcDocumentDetail;


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code.
    }
    return self;
}

- (void)setNeedsDisplay {
    //NSLog(@"DocPreviewView - Need display", @"");
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code.
}
*/

- (void)dealloc {
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];

    blnExit = YES;
    //NSLog(@"DocPreviewView - dealloc", @"");
    if (blnDownloading) {
        //NSLog(@"DocPreviewView - dealloc - cancel urlCon", @"");
        [urlCon cancel];
    }
    //NSLog(@"DocPreviewView - dealloc2", @"");
    
    [vwAnimated stopMyAnimation];
    //NSLog(@"DocPreviewView - dealloc3", @"");
    
    //NSLog(@"DocPreviewView - dealloc4", @"");
    //NSLog(@"DocPreviewView - dealloc5", @"");
    //NSLog(@"DocPreviewView - dealloc6", @"");
}


#pragma mark -
#pragma mark MyFunc
- (void)firstLoad {
    //NSLog(@"DocPreView - firstload", @"");
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    blnExit = NO;
    urlCon = nil;
    lblCacheUsed.hidden = YES;
    
    iDocId = [[dictDoc valueForKey:@"id"] intValue];
    
    sFileName = [dictDoc valueForKey:@"filename"];
    DocumentDetailController *docDetailCon = (DocumentDetailController*)vwcDocumentDetail;
    [docDetailCon setTitle:sFileName];
    
    //NSLog(@"File name: %@", sFileName);
    sFileExt = [sFileName pathExtension];
    //NSLog(@"File ext: %@", sFileExt);
    
    lDocSize = [[dictDoc valueForKey:@"size"] longLongValue];
    
    id obj = [dictDoc valueForKey:@"modified"];
    if (obj)
        iModifiedDate = [obj intValue];
    else
        iModifiedDate = [[dictDoc valueForKey:@"created"] intValue];
    
    vwAnimated = [MyAnimatedView newWithSuperview:self image:kImgSpinner];
    [Layout moveControl:vwAnimated toCenterOfControl:myWebView];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [self performSelector:@selector(loadDoc) withObject:nil afterDelay:0.0];        
}

- (void)loadDoc {
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    NSMutableArray *arrCachedDocs = [CommonVar arrCachedDocs];
    //NSLog(@"DocPreview - loadDoc - arrCachedDocs: %@", [arrCachedDocs description]);
    NSURL *urlLocalDoc = nil;
    
    [vwAnimated startMyAnimation];
    
    if (arrCachedDocs) {
        if ([arrCachedDocs containsObject:@(iDocId)]) {
            urlLocalDoc = [CommonVar getDocURL:iDocId modifiedDate:iModifiedDate fileExt:sFileExt];
            if (urlLocalDoc) {
                [self displayDocInWebView:urlLocalDoc];
                [[UIApplication sharedApplication] endIgnoringInteractionEvents];
                return;
            }
        }
    }
    
    //prepare to request download...
    
    lblProgress = [Layout labelWithFrame:CGRectMake(0, 0, 60, 24) text:@"0%..." font:[UIFont boldSystemFontOfSize:13] textColor:[UIColor blackColor] backColor:[UIColor clearColor]];
    lblProgress.contentMode = UIControlContentHorizontalAlignmentCenter;
    [Layout moveControl:lblProgress toCenterOfControl:myWebView];
    lblProgress.frame = [Layout CGRectMoveBy:lblProgress.frame dx:10 dy:0];
    [self addSubview:lblProgress];
    
    NSURL *urlServerReq = [NSURL URLWithString:[kServer stringByAppendingFormat:@"ticket=%@&op=download&id=%i",[CommonVar ticket],iDocId]];
    //NSLog(@"DocPreview - load doc from server URL: %@", urlServerReq);
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:urlServerReq cachePolicy: NSURLCacheStorageNotAllowed timeoutInterval: 30];
    [request setHTTPMethod:@"GET"];
    //NSURLResponse *response = nil;
    //NSError *err = nil;
    
    //NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&err];
    myData = [[NSMutableData alloc] init];
    urlCon = [NSURLConnection connectionWithRequest:request delegate:self];
    blnDownloading = YES;
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    [urlCon start];
}

#pragma mark -
#pragma mark UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if (lblProgress)
        lblProgress.hidden = YES;
    if (vwAnimated) 
        [vwAnimated stopMyAnimation];
    
    DocumentDetailController *docDetailCon = (DocumentDetailController*)vwcDocumentDetail;
    docDetailCon.tbiEmail.enabled = YES;
    //tbiEmail.enabled = YES;
    
    //display cache size used + add animation to make it fade out
    NSArray *arrExtensions = kSupportedFileExts;
    double dCacheUsed = [CommonVar getDirSize:[kPathDocThumb stringByAppendingPathComponent:@"DocFile"] fileExtensions:arrExtensions];
    dCacheUsed /= (1024 * 1024);
    lblCacheUsed.text = [NSString stringWithFormat:@"Cache used: %0.2f MB", dCacheUsed];
    lblCacheUsed.hidden = NO;
    
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents]; //must lock to avoid quit, until ending animation
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    [animation setDuration:0.25];
    [animation setDelegate:self];
    [animation setToValue:@0.0f];
    [animation setRepeatCount:1];
    [animation setRemovedOnCompletion:YES];
    [animation setAutoreverses:NO];
    
    [lblCacheUsed.layer addAnimation:animation forKey:nil];
}


#pragma mark -
#pragma mark URLConnectionDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [myData appendData:data];
    NSUInteger iDataLen = [myData length] * 100 / lDocSize;
    lblProgress.text = [NSString stringWithFormat:@"%d%%...", iDataLen];
}

/*
 - (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response {
 }
 */

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    blnDownloading = NO;
    //NSLog(@"DocPreview - connectionDidFinishLoading - write to file: %@, url: %@", sLocalDocPath, urlLocalDoc);
    //NSLog(@"DocPreview - save doc %@", sFileExt);
    urlLocalFile = [CommonVar saveDoc:myData docId:iDocId modifiedDate:iModifiedDate fileExt:sFileExt];
    //NSLog(@"DocPreview - end save doc %i", iDocId);
    [self displayDocInWebView:urlLocalFile];
}

- (void)displayDocInWebView:(NSURL*)url {
    NSMutableURLRequest *requestLocal = [NSMutableURLRequest requestWithURL:url cachePolicy:NSURLCacheStorageAllowed timeoutInterval: 30];
    [requestLocal setHTTPMethod:@"GET"];
    [myWebView loadRequest:requestLocal];
}

- (IBAction)handleScrollBtn:(id)sender {
    UIScrollView *svw = (myWebView.subviews)[0];
    //NSLog(@"Scroll view: %@", [svw.subviews description]);
    UIView *vwBrowser = nil;
    for (id vw in svw.subviews) {
        if ([NSStringFromClass([vw class]) isEqualToString:@"UIWebBrowserView"]) {
            vwBrowser = vw;
            //NSLog(@"Found Browser view", @"");
        }
    }
    if (vwBrowser) {
        float fNewOffsetX = svw.contentOffset.x;
        float fNewOffsetY = svw.contentOffset.y;
        
        if (sender == btnScrollUp) {
            fNewOffsetY -= svw.frame.size.height * svw.zoomScale;
            if (fNewOffsetY < 0)    //just scroll up maximum to top of first page
                fNewOffsetY = 0;
        } else if (sender == btnScrollDown) {
            fNewOffsetY += svw.frame.size.height * svw.zoomScale;
            if (fNewOffsetY > vwBrowser.frame.size.height - svw.frame.size.height * svw.zoomScale) //just scroll down maximum to top of last page
                fNewOffsetY = vwBrowser.frame.size.height - svw.frame.size.height * svw.zoomScale;
        } else if (sender == btnScrollLeft) {
            fNewOffsetX -= svw.frame.size.width * svw.zoomScale;
            if (fNewOffsetX < 0)    //just scroll left maximum to top of first page
                fNewOffsetX = 0;
        } else if (sender == btnScrollRight) {
            fNewOffsetX += svw.frame.size.width * svw.zoomScale;
            if (fNewOffsetX > vwBrowser.frame.size.width - svw.frame.size.width * svw.zoomScale) //just scroll right maximum to top of last page
                fNewOffsetX = vwBrowser.frame.size.width - svw.frame.size.width * svw.zoomScale;
        } else {
            return;
        }
        
        [svw setContentOffset:CGPointMake(fNewOffsetX, fNewOffsetY) animated:YES];
        //NSLog(@"Scroll WebView to new offset x = %f, y = %f", fNewOffsetX, fNewOffsetY);
    }
}

#pragma mark -
#pragma mark CAAnimation
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag { //fade out CacheUsed label
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents])
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    
    if (!blnExit) {
        lblCacheUsed.hidden = YES;
    }
}

@end
