//
//  ProgressUsageView.m
//  FileThis
//
//  Created by Cao Huu Loc on 5/30/14.
//
//

#import "ProgressUsageView.h"
#import "CommonLayout.h"

@interface ProgressUsageView ()
@property (nonatomic, strong) UILabel *lblTitle;
@property (nonatomic, strong) UILabel *lblMaxQuota;
@property (nonatomic, strong) UILabel *lblUnit;
@property (nonatomic, strong) CustomProgressBar *progress;
@property (nonatomic, strong) UILabel *lblDescription1;
@property (nonatomic, strong) UILabel *lblDescription2;

@end

@implementation ProgressUsageView

#pragma mark - Initialize
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    self.lblTitle = [CommonLayout createLabel:CGRectZero font:[CommonLayout getFontWithSize:18 isBold:YES] textColor:kTextOrangeColor backgroundColor:[UIColor clearColor] text:@"" superView:self];
    self.lblMaxQuota = [CommonLayout createLabel:CGRectZero font:[UIFont boldSystemFontOfSize:27] textColor:kTextOrangeColor backgroundColor:[UIColor clearColor] text:@"" superView:self];
    self.lblUnit = [CommonLayout createLabel:CGRectZero font:[CommonLayout getFontWithSize:16 isBold:NO] textColor:kTextOrangeColor backgroundColor:[UIColor clearColor] text:@"" superView:self];
    
    self.progress = [[CustomProgressBar alloc] initWithFrame:CGRectZero];
    self.progress.progress = 0.0;
    [self addSubview:self.progress];
    
    self.lblDescription1 = [CommonLayout createLabel:CGRectZero font:[CommonLayout getFont:FontSizeXSmall isBold:NO isItalic:YES] textColor:kTextGrayColor backgroundColor:[UIColor clearColor] text:NSLocalizedString(@"ID_YOU_ARE_USING", @"") superView:self];
    self.lblDescription2 = [CommonLayout createLabel:CGRectZero font:[CommonLayout getFont:FontSizeXSmall isBold:YES isItalic:NO] textColor:[UIColor blackColor] backgroundColor:[UIColor clearColor] text:@"" superView:self];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [self.lblTitle sizeToFit];
    [self.lblTitle setBottom:30];
    
    [self.lblUnit sizeToFit];
    [self.lblUnit setRight:self.frame.size.width];
    [self.lblUnit setBottom:30];
    
    [self.lblMaxQuota sizeToFit];
    [self.lblMaxQuota setRight:[self.lblUnit left] - 5];
    [self.lblMaxQuota setBottom:32];
    
    self.progress.frame = [self.lblTitle rectAtBottom:10 height:28];
    [self.progress setWidth:self.frame.size.width];
    
    [self.lblDescription1 sizeToFit];
    [self.lblDescription1 setTop:[self.progress bottom] + 10];
    
    [self.lblDescription2 sizeToFit];
    [self.lblDescription2 setTop:[self.lblDescription1 top]];
    [self.lblDescription2 setLeft:[self.lblDescription1 right] + 5];
}

#pragma mark - Setter
- (void)setMaxQuota:(int)maxQuota {
    _maxQuota = maxQuota;
    
    [self refreshProgressBar];
    [self refreshLabelText];
    [self setNeedsLayout];
}

- (void)setProgressValue:(int)progressValue {
    _progressValue = progressValue;
    
    [self refreshProgressBar];
    [self refreshLabelText];
    [self setNeedsLayout];
}

#pragma mark - Refresh GUI
- (void)refreshProgressBar {
    if (self.maxQuota == 0) {
        self.progress.progress = 0;
    } else {
        self.progress.progress = MIN(1, (float)self.progressValue / self.maxQuota);
    }
}

- (void)refreshLabelText {
    //Override at subclass
}

@end
