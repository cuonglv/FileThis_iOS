//
//  SearchDatePopupViewController.h
//  FileThis
//
//  Created by Cuong Le on 1/9/14.
//
//

#import <UIKit/UIKit.h>
#import "DateHandler.h"

#define kSearchDatePopupViewWidth   300
#define kSearchDatePopupViewHeight  320

@protocol SearchDatePopupViewControllerDelegate <NSObject>
- (void)searchDatePopupViewController_Canceled:(id)sender;
- (void)searchDatePopupViewController_Done:(id)sender;
@end

@interface SearchDatePopupViewController : UIViewController
@property (nonatomic, assign) id<SearchDatePopupViewControllerDelegate> delegate;

- (NSDateComponents*)selectedDateComps;
- (void)setDate:(NSDateComponents*)dateComps isShowingYear:(BOOL)isShowingYear;
@end
