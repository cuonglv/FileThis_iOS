//
//  DocumentMetadataView.h
//  FTMobile
//
//  Created by decuoi on 12/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MyAnimatedView.h"

@interface DocumentMetadataView : UIView {
    NSMutableDictionary *dictDoc;
    
    IBOutlet UILabel *lblTitle, *lblKind, *lblSize, *lblDateCreated, *lblDateAdded;
    IBOutlet UIImageView *imvCab1, *imvCab2, *imvTag1, *imvTag2, *imvTag3;
    IBOutlet UILabel *lblCab1, *lblCab2, *lblTag1, *lblTag2, *lblTag3;
    IBOutlet UIButton *btnMoreCab, *btnMoreTag, *btnMoreComment;
    IBOutlet UIImageView *imvThumb;
    int iDocId;
    UIImage *imgTag;
    
    MyAnimatedView *vwAnimated;
    int iDateModified;
    double lDocSize;
    
    //NSArray *arrCabinets;
    IBOutlet UITabBar *myTabBar;
    IBOutlet UITabBarItem *tbiEmail, *tbiView, *tbiSettings, *tbiLogout;
}
@property (nonatomic, strong) NSMutableDictionary *dictDoc;
- (void)firstLoad;

#pragma mark -
#pragma mark MyFunc
- (void)loadThumb;
- (void)displayCab:(int)cabId imageView:(UIImageView*)imv titleLabel:(UILabel*)lbl;

#pragma mark -
#pragma mark Button
- (IBAction)handleMoreCabsBtn:(id)sender;
- (IBAction)handleMoreTagsBtn:(id)sender;

@end
