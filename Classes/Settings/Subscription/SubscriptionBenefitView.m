//
//  SubscriptionBenefitView.m
//  FileThis
//
//  Created by Cao Huu Loc on 3/11/14.
//
//

#import "SubscriptionBenefitView.h"

@implementation SubscriptionBenefitView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self initializeControl];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self initializeControl];
    }
    return self;
}

- (void)initializeControl {
    self.benefitViews = [NSMutableArray arrayWithCapacity:4];
    
    CGRect rect = CGRectMake(0, 0, self.bounds.size.width, 100);
    IconAndTextView *v = [[IconAndTextView alloc] initWithFrame:rect];
    [self.benefitViews addObject:v];
    [self addSubview:v];
    [v setIcon:nil text1:@"Run more than 6 connections" text2:@"Connect to up to 30 institutions that provide your documents to you online"];
    [v resizeByWidth:self.bounds.size.width];
    rect = v.frame;
    
    rect.origin.y += rect.size.height;
    v = [[IconAndTextView alloc] initWithFrame:rect];
    [self.benefitViews addObject:v];
    [self addSubview:v];
    [v setIcon:nil text1:@"Supersize FileThis Cloud storage" text2:@"10 GB total storage on FileThis Cloud - OR - use a destination partner"];
    [v resizeByWidth:self.bounds.size.width];
    rect = v.frame;
    
    rect.origin.y += rect.size.height;
    v = [[IconAndTextView alloc] initWithFrame:rect];
    [self.benefitViews addObject:v];
    [self addSubview:v];
    [v setIcon:nil text1:@"Connect more frequently" text2:@"Download new documents in each of your connections daily instead of weekly"];
    [v resizeByWidth:self.bounds.size.width];
}

#pragma mark - Public methods
- (void)resizeByWidth:(float)width
{
    CGRect rect = CGRectMake(0, 0, width, 100);
    for (IconAndTextView *v in self.benefitViews) {
        v.frame = rect;
        [v resizeByWidth:width];
        rect = v.frame;
        rect.origin.y += rect.size.height;
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, width, rect.origin.y);
}

@end
