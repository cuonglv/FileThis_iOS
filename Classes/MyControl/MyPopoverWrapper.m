//
//  MyPopoverWrapper.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/20/14.
//
//

#import "MyPopoverWrapper.h"
#import "UIView+Ext.h"

@implementation MyPopoverWrapper

- (id)initWithContentViewController:(UIViewController *)viewController
{
    self = [super init];
    if (self)
    {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        {
            UIPopoverController *obj = [[UIPopoverController alloc] initWithContentViewController:viewController];
            self.popoverController = obj;
        }
        else
        {
            MyTouchView *v = [[MyTouchView alloc] initWithFrame:CGRectMake(0, 0, [[UIScreen mainScreen] bounds].size.width, [[UIScreen mainScreen] bounds].size.height)];
            v.backgroundColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:0.5];
            v.touchDelegate = self;
            self.overlayView = v;
            self.overlayView.hidden = YES;
            self.popoverView = viewController.view;
            self.popoverView.layer.cornerRadius = 7;
            self.popoverView.backgroundColor = [UIColor whiteColor];
            [self.overlayView addSubview:self.popoverView];
        }
        
        self.layoutMode = PopoverLayoutModeVerticalCenter;
    }
    return self;
}

- (UIView*)getContentView
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        return self.popoverController.contentViewController.view;
    return self.popoverView;
}

- (void)setPopoverContentSize:(CGSize)size
{
    [self setPopoverContentSize:size animated:NO];
}

- (BOOL)isPopoverVisible
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        return self.popoverController.isPopoverVisible;
    }
    return !self.overlayView.hidden;
}

- (void)setPopoverContentSize:(CGSize)size animated:(BOOL)animated
{
    _popoverContentSize = size;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.popoverController setPopoverContentSize:size animated:animated];
    }
    else
    {
        self.popoverView.frame = CGRectMake(0, 0, size.width, size.height);
    }
}

- (void)presentPopoverFromRect:(CGRect)rect inView:(UIView *)view permittedArrowDirections:(UIPopoverArrowDirection)arrowDirections animated:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.popoverController presentPopoverFromRect:rect inView:view permittedArrowDirections:arrowDirections animated:animated];
    }
    else
    {
        self.overlayView.hidden = YES;
        CGRect temp = self.popoverView.frame;
        temp.origin.x = (self.overlayView.frame.size.width - temp.size.width) / 2;
        if (self.layoutMode == PopoverLayoutModeVerticalBottom) {
            temp.origin.y = rect.origin.y - temp.size.height;
        } else if (self.layoutMode == PopoverLayoutModeVerticalTop) {
            temp.origin.y = self.layoutTopMargin;
        } else {
            temp.origin.y = (self.overlayView.frame.size.height - temp.size.height) / 2;
        }
        self.popoverView.frame = temp;
        
        [view addSubview:self.overlayView];
        [UIView animateWithDuration:0.5 animations:^(void) {
            self.overlayView.hidden = NO;
        }];
    }
}

- (void)setDelegate:(id<UIPopoverControllerDelegate>)aDelegate
{
    _delegate = aDelegate;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        self.popoverController.delegate = aDelegate;
    }
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
    {
        [self.popoverController dismissPopoverAnimated:animated];
    }
    else
    {
        [UIView animateWithDuration:0.5 animations:^(void) {
            self.overlayView.hidden = YES;
        } completion:^(BOOL finished) {
            [self.overlayView removeFromSuperview];
            if ([self.delegate respondsToSelector:@selector(popoverControllerDidDismissPopover:)]) {
                [self.delegate popoverControllerDidDismissPopover:nil];
            }
        }];
    }
}

#pragma mark - MyViewTouchEvent
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event sender:(id)sender {
    if (![self.popoverView containsTouch:[touches anyObject]])
        [self dismissPopoverAnimated:YES];
}

@end
