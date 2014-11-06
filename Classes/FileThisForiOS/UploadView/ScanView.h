//
//  ScanView.h
//  FileThis
//
//  Created by Cuong Le on 1/15/14.
//
//

#import <UIKit/UIKit.h>

@protocol ScanViewDelegate <NSObject>

- (void)scanViewExit:(id)sender;
- (void)scanViewSwitchCamera:(id)sender;
- (void)scanViewTakePhoto:(id)sender;
- (void)scanViewSwitchFlashStatus:(id)sender;

@end

@interface ScanView : UIView

- (id)initWithFrame:(CGRect)frame delegate:(id<ScanViewDelegate>)delegate;
- (void)updateFlashIcon:(BOOL)turnon;

@end
