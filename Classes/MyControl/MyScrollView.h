//
//  MyScrollView.h
//  FileThis
//
//  Created by Cao Huu Loc on 2/18/14.
//

#import <UIKit/UIKit.h>

@protocol MyScrollViewTouchEvent <NSObject>
@optional
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event sender:(id)sender;
@end

@interface MyScrollView : UIScrollView
@property (nonatomic, assign) id<MyScrollViewTouchEvent> touchDelegate;
@end
