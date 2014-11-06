//
//  DocumentGroupCollectionHeaderView.m
//  FileThis
//
//  Created by Manh nguyen on 1/12/14.
//
//

#import "DocumentGroupCollectionHeaderView.h"
#import <QuartzCore/QuartzCore.h>
#import "DocumentCabinetObject.h"
#import "DocumentProfileObject.h"

@implementation DocumentGroupCollectionHeaderView

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self setBackgroundColor:kDocumentGroupHeaderColor];
        self.sectionView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        [self addSubview:self.sectionView];
        [self.sectionView setHidden:NO];
        
        UIImageView *imgIcon = [[UIImageView alloc] initWithFrame:CGRectMake(8, 15, 16, 16)];
        [self.sectionView addSubview:imgIcon];
        self.imgIcon = imgIcon;
        [imgIcon setImage:[UIImage imageNamed:@"plus_icon.png"]];
        
        self.lblCabinetName = [[UILabel alloc] initWithFrame:[imgIcon rectAtRight:5 width:500 height:30]];
        [self.sectionView addSubview:self.lblCabinetName];
        [self.lblCabinetName setFont:[UIFont fontWithName:kAppFontNormal size:kFontSizeNormal] textColor:kDarkGrayColor backgroundColor:nil text:@"" numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        
        UIButton *btnDisclosure = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 10 - 15, 12, 10, 14)];
        [self.sectionView addSubview:btnDisclosure];
        [btnDisclosure addTarget:self action:@selector(handleThumbViewAllTouched:) forControlEvents:UIControlEventTouchUpInside];
        [btnDisclosure setImage:[UIImage imageNamed:@"arrow_icon.png"] forState:UIControlStateNormal];
        self.btnDisclosure = btnDisclosure;
        
        int viewAllWidth = 80;
        if (IS_IPHONE)
            viewAllWidth = 60;
        self.btnViewAll = [[UIButton alloc] initWithFrame:CGRectMake([btnDisclosure left]-viewAllWidth, 1, viewAllWidth, frame.size.height-1)];
//        [self.btnViewAll setTop:[btnDisclosure top] + 4];
        [self.sectionView addSubview:self.btnViewAll];
        [self.btnViewAll.titleLabel setFont:[UIFont fontWithName:kAppFontNormal size:kFontSizeNormal] textColor:nil backgroundColor:nil text:@"" numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        if (!IS_IPHONE) {
            [self.btnViewAll setTitle:NSLocalizedString(@"ID_VIEW_ALL", @"") forState:UIControlStateNormal];
        }
        [self.btnViewAll setTitleColor:kCabColorAll forState:UIControlStateNormal];
        [self.btnViewAll addTarget:self action:@selector(handleThumbViewAllTouched:) forControlEvents:UIControlEventTouchUpInside];
        
        self.lblDocumentCount = [[UILabel alloc] initWithFrame:[self.btnViewAll rectAtLeft:10 width:120]];
        [self.sectionView addSubview:self.lblDocumentCount];
        [self.lblDocumentCount setFont:[UIFont fontWithName:kAppFontItalic size:kFontSizeXNormal] textColor:kDarkGrayColor backgroundColor:nil text:@"" numberOfLines:0 textAlignment:NSTextAlignmentRight];
        
        UILabel *separate = [[UILabel alloc] initWithFrame:CGRectMake(0, frame.size.height - 1, frame.size.width, 1)];
        [self.sectionView addSubview:separate];
        [separate setBackgroundColor:kLightGrayColor];
        self.line = separate;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGRect rect = self.lblCabinetName.frame;
            CGSize size = [self.lblCabinetName.text sizeWithFont:self.lblCabinetName.font];
            rect.size.width = size.width + 10;
            self.lblCabinetName.frame = rect;
            
            self.lblDocumentCount.backgroundColor = [UIColor whiteColor];
            self.lblDocumentCount.textAlignment = NSTextAlignmentCenter;
            self.lblDocumentCount.layer.cornerRadius = 5;
        }
    }
    return self;
}
#pragma GCC diagnostic pop

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */
- (void)handleThumbViewAllTouched:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didViewAllButtonTouched:documentGroup:)]) {
        [self.delegate didViewAllButtonTouched:sender documentGroup:self.documentGroupObj];
    }
}

- (void)updateIcon:(BOOL)isExpand {
    if (isExpand) {
        [self.imgIcon setImage:[UIImage imageNamed:@"minus_icon.png"]];
    } else {
        [self.imgIcon setImage:[UIImage imageNamed:@"plus_icon.png"]];
    }
}

- (void)updateData:(id)documentGroup {
    NSString *groupName = @"";
    int numDocs = 0;
    if ([documentGroup isKindOfClass:[DocumentCabinetObject class]]) {
        groupName = ((DocumentCabinetObject *)documentGroup).cabinetObj.name;
        numDocs = [((DocumentCabinetObject *)documentGroup).arrDocuments count];
    } else {
        groupName = ((DocumentProfileObject *)documentGroup).profileObj.name;
        numDocs = [((DocumentProfileObject *)documentGroup).arrDocuments count];
    }
    
    [self.lblCabinetName setText:groupName];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.lblDocumentCount setText:[NSString stringWithFormat:@"%d", numDocs]];
    } else {
        [self.lblDocumentCount setText:[NSString stringWithFormat:NSLocalizedString(@"ID_I_DOCUMENTS", @""), numDocs]];
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
        [self layoutForPhone];
}

- (void)layoutSubviews {
    [self.sectionView setFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    [self.btnDisclosure setFrame:CGRectMake(self.frame.size.width - 10 - 15, 13, 10, 14)];
    [self.btnViewAll setRight:[self.btnDisclosure left]];
    [self.lblDocumentCount setFrame:[self.btnViewAll rectAtLeft:10 width:120]];
    [self.line setFrame:CGRectMake(0, self.frame.size.height - 1, self.frame.size.width, 1)];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        [self layoutForPhone];
    }
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (void)layoutForPhone {
    CGRect rect = self.lblCabinetName.frame;
    CGSize size = [self.lblCabinetName.text sizeWithFont:self.lblCabinetName.font];
    rect.size.width = size.width + 10;
    self.lblCabinetName.frame = rect;
    
    size = [self.lblDocumentCount.text sizeWithFont:self.lblDocumentCount.font];
    rect.origin.x = [self.lblCabinetName right] + 5;
    rect.origin.y = 10;
    rect.size.width = size.width + 17;
    rect.size.height = self.frame.size.height - 20;
    if (rect.origin.x > [self.btnViewAll left] - rect.size.width)
    {
        rect.origin.x = [self.btnViewAll left] - rect.size.width;
    }
    self.lblDocumentCount.frame = rect;
    if ([self.lblCabinetName right] > rect.origin.x)
    {
        int width = rect.origin.x - self.lblCabinetName.frame.origin.x - 1;
        [self.lblCabinetName setWidth:width];
    }
    
    [self.btnViewAll setRight:self.bounds.size.width];
}
#pragma GCC diagnostic pop

@end
