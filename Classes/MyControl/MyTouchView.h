//
//  MyTouchView.h
//  FileThis
//
//  Created by Cao Huu Loc on 2/20/14.
//
//

#import <UIKit/UIKit.h>

@protocol MyViewTouchEvent <NSObject>
@optional
- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent*)event sender:(id)sender;
@end

@interface MyTouchView : UIView
@property (nonatomic, assign) id<MyViewTouchEvent> touchDelegate;
@end
