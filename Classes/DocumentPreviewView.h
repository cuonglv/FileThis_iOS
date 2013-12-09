//
//  DocumentPreviewView.h
//  FTMobile
//
//  Created by decuoi on 12/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAnimatedView.h"

@interface DocumentPreviewView : UIView <UITabBarDelegate, UIWebViewDelegate> {
    NSMutableDictionary *dictDoc;
    
    IBOutlet UIWebView *myWebView;
    int iDocId;
    int iModifiedDate;
    MyAnimatedView *vwAnimated;
    
    NSMutableData *myData;
    long long int lDocSize;
    NSString *sFileExt, *sFileName;
    
    UILabel *lblProgress;
    IBOutlet UILabel *lblCacheUsed;
    IBOutlet UIButton *btnScrollUp, *btnScrollDown, *btnScrollLeft, *btnScrollRight;
    
    NSURL *urlLocalFile;
    NSURLConnection *urlCon;
    
    BOOL blnDownloading;
    BOOL blnExit;
    
    UIViewController *vwcDocumentDetail;
}

@property (nonatomic, strong) NSMutableDictionary *dictDoc;
@property (nonatomic, strong) UIViewController *vwcDocumentDetail;
- (void)firstLoad;
- (void)loadDoc;
- (void)displayDocInWebView:(NSURL *)url;
- (IBAction)handleScrollBtn:(id)sender;
@end
