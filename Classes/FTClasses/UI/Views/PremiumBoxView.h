//
//  PremiumBoxView.h
//  FileThis
//
//  Created by Manh nguyen on 1/21/14.
//
//

#import "BaseView.h"

@interface PremiumBoxView : BaseView

@property (nonatomic, strong) UILabel *lblTitle, *lblPrice;
@property (nonatomic, strong) UIButton *btnIcon;
@property (nonatomic, strong) UIButton *btnGo;

- (void)resize;

@end
