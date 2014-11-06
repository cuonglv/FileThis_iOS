//
//  ConnectionUsageView.m
//  FileThis
//
//  Created by Cao Huu Loc on 6/2/14.
//
//

#import "ConnectionUsageView.h"

//Declare parents members
@interface ProgressUsageView ()
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblMaxQuota;
@property (nonatomic, strong) UILabel *lblUnit;
@property (nonatomic, strong) CustomProgressBar *progress;
@property (nonatomic, strong) UILabel *lblDescription1;
@property (nonatomic, strong) UILabel *lblDescription2;
- (void)initialize;
@end

@implementation ConnectionUsageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)initialize {
    [super initialize];
    self.lblTitle.text = [NSLocalizedString(@"ID_CONNECTIONS", @"") uppercaseString];
    self.lblMaxQuota.text = @"0";
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.lblUnit.text = nil;
    } else {
        self.lblUnit.text = NSLocalizedString(@"ID_CONNECTIONS", @"");
    }
}

- (void)refreshLabelText {
    self.lblMaxQuota.text = [NSString stringWithFormat:@"%d", self.maxQuota];
    NSString *detail = [[NSString alloc] initWithFormat:@"%d %@ %d %@", self.progressValue, NSLocalizedString(@"ID_OF", @""), self.maxQuota, [NSLocalizedString(@"ID_CONNECTIONS", @"") lowercaseString]];
    self.lblDescription2.text = detail;
}

@end
