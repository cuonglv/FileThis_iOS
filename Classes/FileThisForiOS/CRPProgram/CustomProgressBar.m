//
//  CustomProgressBar.m
//  FileThis
//
//  Created by Cao Huu Loc on 5/30/14.
//
//

#import "CustomProgressBar.h"

@interface CustomProgressBar ()
@property (nonatomic, strong) UIImageView *imgvwBackground;
@property (nonatomic, strong) UIImageView *imgvwProgress;

@end

@implementation CustomProgressBar

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
    self.imgvwBackground = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_background.png"]];
    self.imgvwBackground.frame = self.bounds;
    [self addSubview:self.imgvwBackground];
    
    self.imgvwProgress = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"progress_image.png"]];
    self.imgvwProgress.frame = CGRectMake(0, 0, 0, self.bounds.size.height);
    [self addSubview:self.imgvwProgress];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.imgvwBackground.frame = self.bounds;
    
    float width = self.bounds.size.width * self.progress;
    self.imgvwProgress.frame = CGRectMake(0, 0, width, self.bounds.size.height);
}

#pragma mark - Setter
- (void)setBackgroundImage:(UIImage *)image {
    _backgroundImage = image;
    self.imgvwBackground.image = image;
}

- (void)setProgressImage:(UIImage *)image {
    _progressImage = image;
    self.imgvwProgress.image = image;
}

- (void)setProgress:(float)progress {
    _progress = progress;
    float width = self.bounds.size.width * progress;
    self.imgvwProgress.frame = CGRectMake(0, 0, width, self.bounds.size.height);
}

@end
