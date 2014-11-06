//
//  MyPopoverWrapper.h
//  FileThis
//
//  Created by Cao Huu Loc on 2/20/14.
//
//

#import <Foundation/Foundation.h>
#import "MyTouchView.h"

typedef enum {
    PopoverLayoutModeVerticalTop = 0,
    PopoverLayoutModeVerticalBottom = 1,
    PopoverLayoutModeVerticalCenter = 2,
} PopoverLayoutMode;

@interface MyPopoverWrapper : NSObject <MyViewTouchEvent>

@property (nonatomic, assign) CGSize popoverContentSize;
@property (nonatomic, readonly, getter=isPopoverVisible) BOOL popoverVisible;

@property (nonatomic, strong) UIPopoverController *popoverController;
@property (nonatomic, assign) id <UIPopoverControllerDelegate> delegate;

@property (nonatomic, strong) MyTouchView *overlayView;
@property (nonatomic, strong) UIView *popoverView;

@property (nonatomic, assign) PopoverLayoutMode layoutMode;
@property (nonatomic, assign) float layoutTopMargin;

- (id)initWithContentViewController:(UIViewController *)viewController;

- (UIView*)getContentView;

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated;
- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated;
- (void)dismissPopoverAnimated:(BOOL)animated;

@end
