//
//  BorderTextField.m
//  FileThis
//
//  Created by Manh nguyen on 1/1/14.
//
//

#import "BorderTextField.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"

@implementation BorderTextField

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
    self.borderColor = [UIColor colorWithRed:220.0/255 green:220.0/255 blue:220.0/255 alpha:1.0]; //kWhiteLightGrayColor;
    self.cornerRadius = 5;
    
    [self.layer setBorderColor:self.borderColor.CGColor];
    [self.layer setBorderWidth:1.0];
    [self setBackgroundColor:kWhiteColor];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    [self.layer setBorderColor:self.borderColor.CGColor];
    [self.layer setBorderWidth:1.0];
    self.layer.cornerRadius = self.cornerRadius;
    [self setBackgroundColor:kWhiteColor];
}


- (CGRect)textRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 0 );
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return CGRectInset( bounds , 10 , 0 );
}

@end
