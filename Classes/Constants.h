//
//  Constants.h
//  FTMobileApp
//
//  Created by decuoi on 11/19/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol Constants
#define kMarginTop              50
#define kMarginLeft             20

#define kFontSizeXLarge         20
#define kFontSizeLarge          16
#define kFontSizeNormal         15
#define kFontSizeSmall          12
#define kFontSizeXSmall         11
#define kServer                @"https://filethis.com/ftapi/ftapi?"
//#define kServer               @"https://alpha.filethis.com/ftapi/ftapi?"
//#define kServer               @"https://staging.filethis.com/ftapi/ftapi?"
//#define kServer               @"http://allinone.quad/ftapi/ftapi?"

#define kThumbImage1            @"thumb1.png"
#define kThumbImage2            @"thumb2.jpg"
#define kThumbImage3            @"thumb3.jpg"

#define kExceptionalCharacters  @""

#pragma mark -
#pragma mark Cabinet

#define kCabIdAll               -1001

#define kCabColorAll            [UIColor orangeColor]
#define kCabColorVital          [UIColor colorWithRed:252.0/255 green:197.0/255 blue:0.0 alpha:1.0]  // F5C500
#define kCabColorBasic          [UIColor colorWithRed:189.0/255 green:57.0/255 blue:0.0/255 alpha:1.0]  // BD3900
#define kCabColorComputed       [UIColor colorWithRed:139.0/255 green:0.0/255 blue:0.0/255 alpha:1.0]  // 8B0000

#define kCabCellHeight          35

#define kCabTypeAll             @"alll"
#define kCabTypeVital           @"vitl"
#define kCabTypeBasic           @"basc"

#define kImgCabAll              [UIImage imageNamed:@"rrect_orange.png"]
#define kImgCabVital            [UIImage imageNamed:@"rrect_gold.png"]
#define kImgCabBasic            [UIImage imageNamed:@"rrect_red_light.png"]
#define kImgCabComputed         [UIImage imageNamed:@"rrect_red_dark.png"]

#pragma mark -
#pragma mark Tag
#define kTagCellHeight          35
#define kImgTag                 [UIImage imageNamed:@"rrect_gray.png"]

#pragma mark -
#pragma mark DocumentThumbnail
#define kPathDocThumb           [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"DocThumb"]
//[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"DocThumb"]
#define kPathSettings           [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"MyData.plist"]
//[[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"Settings"] stringByAppendingPathComponent:@"MyData.plist"]


#pragma mark -
#pragma mark Cache Options
#define kCacheThumbSmallCount   10DE
#define kCacheThumbMediumCount  10
#define kDocCacheSize           5.0

#define kImgSpinner             [UIImage imageNamed:@"arrow_spin_blue.png"]
#define kImgSpinnerWhite        [UIImage imageNamed:@"arrow_spin_white.png"]

#define kSupportedFileExts      [NSArray arrayWithObjects:@"pdf",@"jpg",@"png",@"gif",nil];
#define kPathUserAlbum          @"/var/mobile/Media/DCIM"

#define kColorLightSteelBlue    [UIColor colorWithRed:0.0/255 green:102.0/255 blue:153.0/255 alpha:1.0]

#define kColorMyDarkBlue        [UIColor colorWithRed:65.0/255 green:93.0/255 blue:158.0/255 alpha:1.0]
#define kColorMyOrange          [UIColor colorWithRed:222.0/255 green:141.0/255 blue:52.0/255 alpha:1.0]

//Edited by Cuong 10/22/2013
#define SYSTEM_VERSION_EQUAL_TO(v)                  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedSame)
#define SYSTEM_VERSION_GREATER_THAN(v)              ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedDescending)
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN(v)                 ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] == NSOrderedAscending)
#define SYSTEM_VERSION_LESS_THAN_OR_EQUAL_TO(v)     ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedDescending)

#define kIOS7CarrierbarHeight   20.0
#define kIOS7ToolbarHeight      66.0
#define kIOS7BottomBarHeight    46.0

@end
