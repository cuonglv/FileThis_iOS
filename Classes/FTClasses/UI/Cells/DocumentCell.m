//
//  DocumentCell.m
//  FTMobile
//
//  Created by decuoi on 11/21/10.
//  Copyright 2010 Global Cybersoft. All rights reserved.
//

#import "DocumentCell.h"
#import "Constants.h"
#import "CommonVar.h"
#import "DocumentDetailController.h"
#import "DocumentObject.h"
#import "CommonFunc.h"
#import "CommonDataManager.h"
#import "DocumentDataManager.h"
#import "CacheManager.h"
#import <QuartzCore/QuartzCore.h>
#import "UIColor+Ext.h"

#define CONTROL_WIDTH   200

@interface DocumentCell()
@property (nonatomic, strong) UITapGestureRecognizer *tapGestureRecognizer;
@end

@implementation DocumentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView *)tableView {
    if ((self = [super initWithStyle:style reuseIdentifier:reuseIdentifier])) {
        self.tableView = tableView;
        [self setTintColor:kCabColorAll];
        
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        self.mainView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, tableView.rowHeight)];
        self.mainView.userInteractionEnabled = YES;
        [self.mainView addGestureRecognizer:self.tapGestureRecognizer];
        [self.contentView addSubview:self.mainView];
        
        
        self.imvThumb = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10, 50, 60)];
        [self.mainView addSubview:self.imvThumb];
        [self.imvThumb.layer setBorderColor:kLightGrayColor.CGColor];
        [self.imvThumb.layer setBorderWidth:1.0];
        self.imvThumb.contentMode = UIViewContentModeScaleAspectFit;
        
        self.lblDate = [[UILabel alloc] initWithFrame:CGRectMake(self.tableView.frame.size.width - 75, [self.imvThumb top] + 2, 150, 22)];
        [self.mainView addSubview:self.lblDate];
    
        self.lblName = [[UILabel alloc] initWithFrame:CGRectMake([self.imvThumb right] + 10, 10, [self.lblDate left] - ([self.imvThumb right] + 10), 25)];
        [self.mainView addSubview:self.lblName];
        self.lblName.lineBreakMode = NSLineBreakByTruncatingMiddle;
        
        self.tagListView = [[TagListView alloc] init];
        [self.mainView addSubview:self.tagListView];
        
        self.btnInfo = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [self.btnInfo setFrame:CGRectMake([self.lblDate left] + 10, [self.lblDate bottom], 44, 44)];
        [self.mainView addSubview:self.btnInfo];
        [self.btnInfo addTarget:self action:@selector(handleButtonInfo:) forControlEvents:UIControlEventTouchUpInside];
        self.btnInfo.hidden = YES;
//        self.btnInfo.backgroundColor = [UIColor yellowColor];
        
        self.documentInfoView = [[DocumentInfoView alloc] initWithFrame:CGRectMake(0, [self.tagListView bottom] + 10, self.tableView.frame.size.width, 350)];
        self.documentInfoView.backgroundColor = [UIColor clearColor];
        [self.contentView addSubview:self.documentInfoView];
        self.documentInfoView.delegate = self;
    }
    return self;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    [super setEditing:editing animated:animated];
    if (editing) {
        [self.mainView removeGestureRecognizer:self.tapGestureRecognizer];
        self.mainView.userInteractionEnabled = NO;
    } else {
        [self.mainView addGestureRecognizer:self.tapGestureRecognizer];
        self.mainView.userInteractionEnabled = YES;
    }
}

- (void)updateCellWithObject:(NSObject *)obj {
    [self updateCellWithObject:obj isSelected:YES];
}

- (void)updateCellWithObject:(NSObject *)obj isSelected:(BOOL)isSelected {
    [super updateCellWithObject:obj];
    
    DocumentObject *documentObj = (DocumentObject *)obj;
    if (documentObj.docThumbImage) {
        self.imvThumb.image = documentObj.docThumbImage;
    } else if ([[documentObj.kind lowercaseString] isEqualToString:[kPDF lowercaseString]]) {
        self.imvThumb.image = [UIImage imageNamed:@"pdf_icon.png"];
    } else {
        self.imvThumb.image = [UIImage imageNamed:@"other_type_icon.png"];
    }
    
    NSString *documentName = documentObj.docname?documentObj.docname:documentObj.filename;
    NSString *ext = [documentName pathExtension];
    if ([ext caseInsensitiveCompare:@"pdf"] == NSOrderedSame) {
        documentName = [documentName stringByDeletingPathExtension];
    }
    
    [self.lblName setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kCabColorAll backgroundColor:nil text:documentName numberOfLines:0 textAlignment:NSTextAlignmentLeft];
    [self.lblDate setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeSmall] textColor:kGrayColor backgroundColor:nil text:[CommonFunc dateStringFromInt:[documentObj.added intValue] format:@"MMM dd, yyyy"] numberOfLines:0 textAlignment:NSTextAlignmentLeft];
    
    [self.tagListView removeAllSubViews];
    [self.tagListView setFrame:CGRectMake([self.lblName left], [self.lblName bottom] + 5, self.tableView.frame.size.width - [self.lblName left] - 40, 25)];
    [self.tagListView setStyle:TagViewStyleNone documentObj:documentObj];
    self.mainView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, [self.tagListView bottom]+15);
    
    //NSLog(@"self.tagListView = %@", self.tagListView);
    self.btnInfo.hidden = NO;
    
    [self.documentInfoView loadViewWithDocument:documentObj];
    if (isSelected) {
        [self.documentInfoView setBackgroundColor:kWhiteLightGrayColor];
        [self.documentInfoView setTop:[self.tagListView bottom] + 15];
        [self.documentInfoView setWidth:self.tableView.frame.size.width];
    }
}

- (void)showDocumentInfo:(BOOL)documentInfoVisible {
    if (documentInfoVisible) {
        [self.documentInfoView loadViewWithDocument:(DocumentObject*)self.m_obj];
        [self.documentInfoView setBackgroundColor:kWhiteLightGrayColor];
        [self.documentInfoView setTop:[self.tagListView bottom] + 15];
        [self.documentInfoView setWidth:self.tableView.frame.size.width];
    } else {
        [self.documentInfoView.txtDocumentName resignFirstResponder];
        [self.documentInfoView.txtRelevantDate resignFirstResponder];
    }
}

- (void)refreshThumbnail {
    DocumentObject *doc = (DocumentObject*)self.m_obj;
    if ([doc isKindOfClass:[DocumentObject class]]) {
        if (doc.docThumbImage) {
            self.imvThumb.image = doc.docThumbImage;
        }
    }
}

- (void)handleButtonInfo:(id)sender {
    [self.documentInfoView resetView];
    if ([self.delegate respondsToSelector:@selector(didButtonInfoTouched:for:)]) {
        [self.delegate didButtonInfoTouched:self for:(DocumentObject *)self.m_obj];
    }
}

- (void)handleTapGesture:(id)sender {
    if (!self.tableView.isEditing)
        self.mainView.backgroundColor = [UIColor colorWithRedInt:205 greenInt:235 blueInt:247];
    
    [self performSelector:@selector(sendTouchEvent) withObject:nil afterDelay:0.1]; //to see selection style
}

- (void)sendTouchEvent {
    if ([self.delegate respondsToSelector:@selector(didTouchCell:documentObject:)]) {
        [self.delegate didTouchCell:self documentObject:(DocumentObject *)self.m_obj];
    }
    if (!self.tableView.isEditing)
        [self performSelector:@selector(clearMainBackground) withObject:nil afterDelay:1.0]; //to see selection style
}

- (void)clearMainBackground {
    self.mainView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.lblDate.frame = CGRectMake(self.tableView.frame.size.width - 75, [self.imvThumb top] + 2, 150, 22);
    self.lblName.frame = CGRectMake([self.imvThumb right] + 10, 10, [self.lblDate left] - ([self.imvThumb right] + 12), 25);
    [self.btnInfo setFrame:CGRectMake([self.lblDate left] - 4, [self.lblDate bottom], 80, 44)];
    
    CGRect rect = self.tagListView.frame;
    rect.size.width = [self.btnInfo left] - rect.origin.x + 25;
    rect.size.height = self.frame.size.height - rect.origin.y - 5;
    
    int row = [TagListView getRowCountForDocument:self.documentInfoView.documentObj byWidth:rect.size.width];
    if (row <= 0)
        row = 1;
    rect.size.height = row * TAG_VIEW_HEIGHT+5;
    self.tagListView.frame = rect;
    
    self.mainView.frame = CGRectMake(0, 0, self.tableView.frame.size.width, [self.tagListView bottom]+15);
    if (self.tagListView.frame.size.height > 0) {
        [self.documentInfoView setTop:[self.tagListView bottom] + 15];
    } else {
        [self.documentInfoView setTop:[self.imvThumb bottom] + 15];
    }
    
    [self.documentInfoView setWidth:self.tableView.frame.size.width];
}

#pragma mark - DocumentInfoViewDelegate
- (void)didCloseButtonTouched:(id)sender {
    [self.documentInfoView.txtDocumentName resignFirstResponder];
    [self.documentInfoView.txtRelevantDate resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(didCloseButtonTouched:for:)]) {
        [self.delegate didCloseButtonTouched:self for:(DocumentObject *)self.m_obj];
    }
}

- (void)willUpdateDocumentValue:(DocumentObject*)newDoc withProperties:(NSArray*)properties {
    [self.documentInfoView.txtDocumentName resignFirstResponder];
    [self.documentInfoView.txtRelevantDate resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(documentCell:willUpdateDocumentValue:withProperties:)]) {
        [self.delegate documentCell:self willUpdateDocumentValue:newDoc withProperties:properties];
    }
}

@end
