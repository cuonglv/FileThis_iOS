//
//  DocumentThumbCell.m
//  FileThis
//
//  Created by Manh nguyen on 1/12/14.
//
//

#import "DocumentThumbCell.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "UIView+ExtLayout.h"
#import "UILabel+Style.h"
#import "DocumentObject.h"
#import "CommonLayout.h"

#define PADDING 10

@implementation DocumentThumbCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isSelected = NO;
        
        // Initialization code
        self.thumbImage = [[UIImageView alloc] initWithFrame:CGRectMake(PADDING, PADDING, frame.size.width - PADDING*2, frame.size.height - 40)];
        [self addSubview:self.thumbImage];
        [self.thumbImage.layer setBorderColor:kLightGrayColor.CGColor];
        [self.thumbImage.layer setBorderWidth:1.0];
        [self.thumbImage setContentMode:UIViewContentModeScaleAspectFit];
        
        self.lblDocName = [CommonLayout createLabel:CGRectMake([self.thumbImage left], [self.thumbImage bottom] + 5, self.thumbImage.frame.size.width, 30) fontSize:FontSizexSmall isBold:NO textColor:kCabColorAll backgroundColor:nil text:@"" superView:self];
        self.lblDocName.textAlignment = NSTextAlignmentCenter;
//        self.lblDocName.adjustsFontSizeToFitWidth = YES;
//        self.lblDocName.minimumScaleFactor = 0.8;
        self.lblDocName.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        self.checkButton = [[UIButton alloc] initWithFrame:CGRectMake([self.thumbImage right] - 27, [self.thumbImage bottom] - 27, 22, 22)];
        [self addSubview:self.checkButton];
        [self.checkButton setImage:[UIImage imageNamed:@"check_icon.png"] forState:UIControlStateNormal];
        [self.checkButton setHidden:YES];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)updateCellWithObject:(NSObject *)obj {
    [super updateCellWithObject:obj];
    
    DocumentObject *docObj = (DocumentObject *)obj;
    if (docObj.docThumbImage) {
        self.thumbImage.image = docObj.docThumbImage;
    } else if ([[docObj.kind lowercaseString] isEqualToString:[kPDF lowercaseString]]) {
        self.thumbImage.image = [UIImage imageNamed:@"pdf_icon.png"];
    } else {
        self.thumbImage.image = [UIImage imageNamed:@"other_type_icon.png"];
    }
    
    NSString *documentName = docObj.docname?docObj.docname:docObj.filename;
    
    self.lblDocName.text = documentName;
    NSString *ext = [documentName pathExtension];
    if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
        self.lblDocName.text = [documentName stringByDeletingPathExtension];
    }
    
    if (self.isSelected) {
        [self.checkButton setHidden:NO];
    } else {
        [self.checkButton setHidden:YES];
    }
}

- (void)refreshThumbnail {
    DocumentObject *doc = (DocumentObject*)self.m_obj;
    if ([doc isKindOfClass:[DocumentObject class]]) {
        if (doc.docThumbImage) {
            self.thumbImage.image = doc.docThumbImage;
        }
    }
}

@end
