//
//  DocumentMetadataView.m
//  FTMobile
//
//  Created by decuoi on 12/20/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "DocumentMetadataView.h"
#import "CommonVar.h"
#import "CommonFunc.h"
#import "Layout.h"
#import "CabinetController.h"
#import "TagController.h"
#import "DocumentDetailController.h"


@implementation DocumentMetadataView
@synthesize dictDoc;

/*
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
    }
    return self;
}
*/

- (void)dealloc {
    if ([[UIApplication sharedApplication] isIgnoringInteractionEvents]) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    }
}

- (void)firstLoad {
    imgTag = kImgTag;
    iDocId = [[dictDoc valueForKey:@"id"] intValue];
    
    vwAnimated = [MyAnimatedView newWithSuperview:self image:kImgSpinnerWhite];
    [Layout moveControl:vwAnimated toCenterOfControl:imvThumb];
    
    NSString *sFileName = [dictDoc valueForKey:@"filename"];
    lblTitle.text = sFileName;
    DocumentDetailController *docDetailCon = (DocumentDetailController*)[CommonVar mainNavigationController].visibleViewController;
    [docDetailCon setTitle:sFileName];
    
    lblKind.text = [dictDoc valueForKey:@"kind"];
    //if (!lblKind.text)
    //    lblKind.text = @"pdf";
    
    lDocSize = [[dictDoc valueForKey:@"size"] floatValue];
    lblSize.text = [CommonFunc getFileSizeString:lDocSize];
    
    lblDateAdded.text = [CommonFunc dateStringShortFromInt:[[dictDoc valueForKey:@"added"] intValue]];
    lblDateCreated.text = [CommonFunc dateStringShortFromInt:[[dictDoc valueForKey:@"created"] intValue]];    
    
    id obj = [dictDoc valueForKey:@"modified"];
    
    if (obj) {
        iDateModified = [obj intValue];
    } else {
        iDateModified = [[dictDoc valueForKey:@"created"] intValue];
    }
    
    NSArray *arrCabs = [dictDoc valueForKey:@"cabs"];
    switch ([arrCabs count]) {
        case 0:
            imvCab1.hidden = YES;
            lblCab1.hidden = YES;
            imvCab2.hidden = YES;
            lblCab2.hidden = YES;
            btnMoreCab.hidden = YES;
            break;
        case 1:
            [self displayCab:[arrCabs[0] intValue] imageView:imvCab1 titleLabel:lblCab1];
            imvCab2.hidden = YES;
            lblCab2.hidden = YES;
            btnMoreCab.hidden = YES;
            break;
        case 2:
            [self displayCab:[arrCabs[0] intValue] imageView:imvCab1 titleLabel:lblCab1];
            [self displayCab:[arrCabs[1] intValue] imageView:imvCab2 titleLabel:lblCab2];
            btnMoreCab.hidden = YES;
            break;
        default:
            [self displayCab:[arrCabs[0] intValue] imageView:imvCab1 titleLabel:lblCab1];
            [self displayCab:[arrCabs[1] intValue] imageView:imvCab2 titleLabel:lblCab2];
            break;
    }
    
    NSArray *arrTags = [dictDoc valueForKey:@"tags"];
    switch ([arrTags count]) {
        case 0:
            imvTag1.hidden = YES;
            lblTag1.hidden = YES;
            imvTag2.hidden = YES;
            lblTag2.hidden = YES;
            imvTag3.hidden = YES;
            lblTag3.hidden = YES;
            btnMoreTag.hidden = YES;
            break;
        case 1:
            imvTag1.image = imgTag;
            lblTag1.text = [CommonVar getTagName:[arrTags[0] intValue]];
            imvTag2.hidden = YES;
            lblTag2.hidden = YES;
            imvTag3.hidden = YES;
            lblTag3.hidden = YES;
            btnMoreTag.hidden = YES;
            break;
        case 2:
            imvTag1.image = imgTag;
            lblTag1.text = [CommonVar getTagName:[arrTags[0] intValue]];
            imvTag2.image = imgTag;
            lblTag2.text = [CommonVar getTagName:[arrTags[1] intValue]];
            imvTag3.hidden = YES;
            lblTag3.hidden = YES;
            btnMoreTag.hidden = YES;
            break;
        case 3:
            imvTag1.image = imgTag;
            lblTag1.text = [CommonVar getTagName:[arrTags[0] intValue]];
            imvTag2.image = imgTag;
            lblTag2.text = [CommonVar getTagName:[arrTags[1] intValue]];
            imvTag3.image = imgTag;
            lblTag3.text = [CommonVar getTagName:[arrTags[2] intValue]];
            btnMoreTag.hidden = YES;
            break;
        default:
            imvTag1.image = imgTag;
            lblTag1.text = [CommonVar getTagName:[arrTags[0] intValue]];
            imvTag2.image = imgTag;
            lblTag2.text = [CommonVar getTagName:[arrTags[1] intValue]];
            imvTag3.image = imgTag;
            lblTag3.text = [CommonVar getTagName:[arrTags[2] intValue]];
            break;
    }
    
    [vwAnimated startMyAnimation];
    [self performSelector:@selector(loadThumb) withObject:nil afterDelay:0.0];
}


#pragma mark -
#pragma mark MyFunc
- (void)loadThumb {
    //NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
    
    //NSLog(@"DocMeta - openThumb - medium - docId: %i", iDocId);
    //NSLog(@"DocMeta - openThumb - medium - arrThumb: %@", [[CommonVar arrThumbFilesMedium] description]);
    UIImage *img = [CommonVar openThumb:iDocId size:ThumbnailSizeMedium modifiedDate:iDateModified];
    if (!img) {
        NSString *req = [[CommonVar requestURL] stringByAppendingFormat:@"thumb&id=%i&size=medium", iDocId];
        //NSLog(@"DocMeta - openThumb - Medium thumb request: %@", req);
        img = [CommonFunc serverGETImage:req];
        [CommonVar saveThumb:img docId:iDocId size:ThumbnailSizeMedium modifiedDate:iDateModified];
    }
    
    imvThumb.image = img;
    if (imvThumb.image.size.width / imvThumb.image.size.height > imvThumb.frame.size.width / imvThumb.frame.size.height) { //imv should fit to horizontal side -> resize imv so that it always displays img at top
        imvThumb.frame = [Layout CGRectResize:imvThumb.frame newHeight:imvThumb.frame.size.width * imvThumb.image.size.height / imvThumb.image.size.width];
    }
    [vwAnimated stopMyAnimation];
    [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    //[pool release];
}

- (void)displayCab:(int)cabId imageView:(UIImageView*)imv titleLabel:(UILabel*)lbl {
    //NSLog(@"Cab id: %i", cabId);
    NSMutableDictionary *mdictAllCabs = [CommonVar mdictAllCabs];
    NSDictionary *dict = mdictAllCabs[@(cabId)];
    lbl.text = [dict valueForKey:@"name"];
    NSString *sType = [dict valueForKey:@"type"];
    if ([sType isEqualToString:@"alll"]) {
        imv.image = kImgCabAll;
    } else if ([sType isEqualToString:@"vitl"]) {
        imv.image = kImgCabVital;
    } else if ([sType isEqualToString:@"basc"]) {
        imv.image = kImgCabBasic;
    } else {
        imv.image = kImgCabComputed;
    }
}

#pragma mark -
#pragma mark Button
- (IBAction)handleMoreCabsBtn:(id)sender {
    NSMutableArray *arrCabs = [[NSMutableArray alloc] init];
    NSArray *arrCabIds = [dictDoc valueForKey:@"cabs"];
    NSMutableDictionary *mdictAllCabs = [CommonVar mdictAllCabs];
    for (id objCabId in arrCabIds) {
        [arrCabs addObject:mdictAllCabs[objCabId]];
    }
    
    CabinetController *target = [[CabinetController alloc]initWithNibName:@"CabinetController" bundle:[NSBundle mainBundle]];
    target.blnViewOnly = YES;
    target.arrCabinets = arrCabs;
    [[CommonVar mainNavigationController] pushViewController:target animated:YES];
}

- (IBAction)handleMoreTagsBtn:(id)sender {
    NSMutableArray *arrTags = [[NSMutableArray alloc] init];
    NSArray *arrTagIds = [dictDoc valueForKey:@"tags"];
    NSMutableDictionary *mdictAllTags = [CommonVar mdictAllTags];
    for (id objTagId in arrTagIds) {
        [arrTags addObject:mdictAllTags[objTagId]];
    }
    
    TagController *target = [[TagController alloc]initWithNibName:@"TagController" bundle:[NSBundle mainBundle]];
    target.blnViewOnly = YES;
    target.arrTagsInfo = arrTags;
    [[CommonVar mainNavigationController] pushViewController:target animated:YES];
}

#pragma mark -
#pragma mark Touch
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"DocMetadata - touchesEnded",@"");
    for (UITouch *touch in touches) {
        CGPoint point = [touch locationInView:self];
        if (![Layout isPointOutsideControl:point forControl:imvThumb]) {
            UINavigationController *con = [CommonVar mainNavigationController];
            DocumentDetailController *docDetailCon = (DocumentDetailController*)con.visibleViewController;
            [docDetailCon handleViewBarBtn];
        }
    }
}

@end
