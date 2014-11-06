//
//  StorageUsageView.m
//  FileThis
//
//  Created by Cao Huu Loc on 6/2/14.
//
//

#import "StorageUsageView.h"
#import "CommonLayout.h"

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

@implementation StorageUsageView

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
    self.lblTitle.text = [NSLocalizedString(@"ID_STORAGE", @"") uppercaseString];
    self.lblMaxQuota.text = @"0";
    self.lblUnit.text = NSLocalizedString(@"ID_GB", @"");
}

- (void)refreshLabelText {
    if (self.maxQuota >= KB_TO_GB_UNIT) {
        self.lblMaxQuota.text = [NSString stringWithFormat:@"%0.2f", (float)self.maxQuota / KB_TO_GB_UNIT];
        self.lblUnit.text = NSLocalizedString(@"ID_GB", @"");
    } else {
        self.lblMaxQuota.text = [NSString stringWithFormat:@"%d", self.maxQuota / KB_TO_MB_UNIT];
        self.lblUnit.text = NSLocalizedString(@"ID_MB", @"");
    }
    
    float percent = 0;
    if (self.maxQuota > 0) {
        percent = (float)self.progressValue / self.maxQuota * 100;
        //percent = floorf(percent);
    }
    NSString *detail = [[NSString alloc] initWithFormat:@"%@ (%0.0f%%) %@ %@", [CommonLayout storageTextFromKB:self.progressValue decimalPlaces:2], percent, NSLocalizedString(@"ID_OF", @""), [CommonLayout storageTextFromKB:self.maxQuota decimalPlaces:2]];
    self.lblDescription2.text = detail;
}

@end
