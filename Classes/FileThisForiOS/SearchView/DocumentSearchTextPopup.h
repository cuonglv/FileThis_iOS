//
//  DocumentSearchTextPopup.h
//  FileThis
//
//  Created by Cuong Le on 1/13/14.
//
//

#import <UIKit/UIKit.h>
#import "CabinetDataManager.h"
#import "TagDataManager.h"

#define kDocumentSearchTextPopup_HearderHeight  45.0
#define kDocumentSearchTextPopup_RowHeight      60.0

@protocol DocumentSearchTextPopupDelegate <NSObject>

- (void)documentSearchTextPopup:(id)sender textSelected:(NSString*)text;
- (void)documentSearchTextPopup:(id)sender cabinetSelected:(CabinetObject*)cabinet;
- (void)documentSearchTextPopup:(id)sender tagSelected:(TagObject*)tag;

@end

@interface DocumentSearchTextPopup : UIView

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<DocumentSearchTextPopupDelegate>)delegate;

- (void)setSearchedString:(NSString*)aString;
- (BOOL)isEmptyData;
@end
