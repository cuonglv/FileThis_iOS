//
//  DocumentInfoView.m
//  FileThis
//
//  Created by Manh nguyen on 12/24/13.
//
//

#import "DocumentInfoView.h"
#import "Utils.h"
#import "DateHandler.h"
#import "NetworkReachability.h"

#define ROW_HEIGHT 40

@implementation DocumentInfoView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.isEditing = NO;
        
        ///////////////////////////////
        //Top view (header title)
        ///////////////////////////////
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, ROW_HEIGHT)];
        v.clipsToBounds = YES;
        self.topView = v;
        [self addSubview:v];
        v.backgroundColor = kWhiteLightGrayColor;
        
        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, ROW_HEIGHT)];
        [title setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_DOCUMENT_INFO", @"") numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        self.lblTitle = title;
        self.lblTitle.backgroundColor = [UIColor clearColor];
        [self.topView addSubview:title];
        
        self.btnClose = [[UIButton alloc] initWithFrame:CGRectMake(frame.size.width - 60, [title top], 60, ROW_HEIGHT)];
        [self.btnClose setTitle:NSLocalizedString(@"ID_CLOSE", @"") forState:UIControlStateNormal];
        [self.btnClose setTitleColor:kCabColorAll forState:UIControlStateNormal];
        [self.btnClose addTarget:self action:@selector(handleCloseButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnClose.titleLabel setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
        [self.topView addSubview:self.btnClose];
        
        self.btnSave = [[UIButton alloc] initWithFrame:CGRectMake([self.btnClose right], [self.btnClose top], 60, ROW_HEIGHT)];
        [self.btnSave setTitle:NSLocalizedString(@"ID_SAVE", @"") forState:UIControlStateNormal];
        [self.btnSave setTitleColor:kCabColorAll forState:UIControlStateNormal];
        [self.btnSave.titleLabel setFont:[UIFont fontWithName:@"Merriweather-Bold" size:kFontSizeNormal]];
        [self.btnSave addTarget:self action:@selector(handleSaveButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:self.btnSave];
        
        ///////////////////////////////
        //Center view
        ///////////////////////////////
        v = [[UIView alloc] initWithFrame:CGRectMake(0, ROW_HEIGHT, frame.size.width, frame.size.height - ROW_HEIGHT)];
        self.centerView = v;
        [self addSubview:v];
        
        self.txtDocumentName = [[CHLTextField alloc] initWithFrame:CGRectMake(20, 0, frame.size.width - 20, ROW_HEIGHT)];
        [self.txtDocumentName setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
        [self.txtDocumentName setEnabled:NO];
        [self.txtDocumentName setTextColor:kCabColorAll];
        [self.centerView addSubview:self.txtDocumentName];
        
        self.btnEditFileName = [[UIButton alloc] initWithFrame:CGRectMake(0, [self.txtDocumentName top] + 6, 42, 30)];
        [self.btnEditFileName addTarget:self action:@selector(handleEditFileName:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnEditFileName setImage:[UIImage imageNamed:@"edit_icon.png"] forState:UIControlStateNormal];
        self.btnEditFileName.imageEdgeInsets = UIEdgeInsetsMake(4, 10, 4, 10);
        [self.centerView addSubview:self.btnEditFileName];
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake([self.txtDocumentName left], [self.txtDocumentName bottom], frame.size.width - 40, 1)];
        [line setBackgroundColor:kLightGrayColor];
        [self.centerView addSubview:line];
        self.line1 = line;
        
        UILabel *tags = [[UILabel alloc] initWithFrame:CGRectMake([self.txtDocumentName left], [self.txtDocumentName bottom], 60, ROW_HEIGHT)];
        [tags setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_TAGS", @"") numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        [self.centerView addSubview:tags];
        
        self.tagListView = [[TagListView alloc] initWithFrame:CGRectMake([tags right] + 5, [tags top] + 10, frame.size.width - [tags right] - 10, 30)];
        [self.centerView addSubview:self.tagListView];
        
        line = [[UIView alloc] initWithFrame:CGRectMake([tags left], [self.tagListView bottom], frame.size.width - 40, 1)];
        [line setBackgroundColor:kLightGrayColor];
        [self.centerView addSubview:line];
        self.line2 = line;
        
        UILabel *numberPages = [[UILabel alloc] initWithFrame:CGRectMake([tags left], [self.tagListView bottom], 150, ROW_HEIGHT)];
        [self.centerView addSubview:numberPages];
        [numberPages setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_NUMBER_PAGES", @"") numberOfLines:1 textAlignment:NSTextAlignmentLeft];
        
        self.lblNumberPages = [[UILabel alloc] initWithFrame:CGRectMake([numberPages right] + 5, [numberPages top], frame.size.width - [tags right], ROW_HEIGHT)];
        [self.lblNumberPages setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal] textColor:kCabColorAll backgroundColor:nil text:@"" numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        [self.centerView addSubview:self.lblNumberPages];
        
        line = [[UIView alloc] initWithFrame:CGRectMake([numberPages left], [self.lblNumberPages bottom], frame.size.width - 40, 1)];
        [line setBackgroundColor:kLightGrayColor];
        [self.centerView addSubview:line];
        self.line3 = line;
        
        UILabel *fileSize = [[UILabel alloc] initWithFrame:CGRectMake([numberPages left], [self.lblNumberPages bottom], 100, ROW_HEIGHT)];
        [self.centerView addSubview:fileSize];
        [fileSize setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_FILE_SIZE", @"") numberOfLines:1 textAlignment:NSTextAlignmentLeft];
        
        self.lblFileSize = [[UILabel alloc] initWithFrame:CGRectMake([fileSize right] + 5, [fileSize top], frame.size.width - [fileSize right], ROW_HEIGHT)];
        [self.lblFileSize setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal] textColor:kCabColorAll backgroundColor:nil text:@"" numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        [self.centerView addSubview:self.lblFileSize];
        
        line = [[UIView alloc] initWithFrame:CGRectMake([fileSize left], [self.lblFileSize bottom], frame.size.width - 40, 1)];
        [line setBackgroundColor:kLightGrayColor];
        [self.centerView addSubview:line];
        self.line4 = line;
        
        UILabel *addedDate = [[UILabel alloc] initWithFrame:CGRectMake([fileSize left], [self.lblFileSize bottom], 100, ROW_HEIGHT)];
        [self.centerView addSubview:addedDate];
        [addedDate setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_ADDED_DATE", @"") numberOfLines:1 textAlignment:NSTextAlignmentLeft];
        
        self.lblAddedDate = [[UILabel alloc] initWithFrame:CGRectMake([addedDate right] + 5, [addedDate top], frame.size.width - [addedDate right], ROW_HEIGHT)];
        [self.lblAddedDate setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal] textColor:kCabColorAll backgroundColor:nil text:@"" numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        [self.centerView addSubview:self.lblAddedDate];
        
        line = [[UIView alloc] initWithFrame:CGRectMake([addedDate left], [self.lblAddedDate bottom], frame.size.width - 40, 1)];
        [line setBackgroundColor:kLightGrayColor];
        [self.centerView addSubview:line];
        self.line5 = line;
        
        UILabel *createdDate = [[UILabel alloc] initWithFrame:CGRectMake([addedDate left], [self.lblAddedDate bottom], 150, ROW_HEIGHT)];
        [self.centerView addSubview:createdDate];
        [createdDate setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_CREATED_DATE", @"") numberOfLines:1 textAlignment:NSTextAlignmentLeft];
        
        self.lblCreatedDate = [[UILabel alloc] initWithFrame:CGRectMake([addedDate right] + 5, [createdDate top], frame.size.width - [createdDate right], ROW_HEIGHT)];
        [self.lblCreatedDate setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal] textColor:kCabColorAll backgroundColor:nil text:@"" numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        [self.centerView addSubview:self.lblCreatedDate];
        
        line = [[UIView alloc] initWithFrame:CGRectMake([createdDate left], [self.lblCreatedDate bottom], frame.size.width - 40, 1)];
        [line setBackgroundColor:kLightGrayColor];
        [self.centerView addSubview:line];
        self.line6 = line;
        
        UILabel *relevant = [[UILabel alloc] initWithFrame:CGRectMake([createdDate left], [self.lblCreatedDate bottom], 100, ROW_HEIGHT)];
        [self.centerView addSubview:relevant];
        [relevant setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kDarkGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_RELEVANT", @"") numberOfLines:1 textAlignment:NSTextAlignmentLeft];
        
        self.txtRelevantDate = [[CHLTextField alloc] initWithFrame:CGRectMake([relevant right] + 5, [relevant top], frame.size.width - [relevant right], ROW_HEIGHT)];
        [self.txtRelevantDate setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal]];
        [self.txtRelevantDate setTextColor:kCabColorAll];
        [self.centerView addSubview:self.txtRelevantDate];
        [self.txtRelevantDate setEnabled:NO];
        
        self.btnEditRelevant = [[UIButton alloc] initWithFrame:CGRectMake(0, [self.txtRelevantDate top] + 6, 42, 30)];
        [self.btnEditRelevant addTarget:self action:@selector(handleEditRelevantDate:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnEditRelevant setImage:[UIImage imageNamed:@"edit_icon.png"] forState:UIControlStateNormal];
        self.btnEditRelevant.imageEdgeInsets = UIEdgeInsetsMake(4, 10, 4, 10);
        [self.centerView addSubview:self.btnEditRelevant];
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

- (void)loadViewWithDocument:(DocumentObject *)documentObj {
    self.documentObj = documentObj;
    [self.tagListView removeAllSubViews];
    
    NSString *documentName = documentObj.docname?documentObj.docname:documentObj.filename;
    
    [self.txtDocumentName setText:documentName];
    [self.tagListView setStyle:TagViewStyleNoneOrange documentObj:documentObj];
    [self.lblNumberPages setText:[(NSNumber *)documentObj.pages stringValue]];
    [self.lblFileSize setText:[NSString stringWithFormat:@"%d KB", [documentObj.size intValue]/1024]];
    
    [self.lblAddedDate setText:[DateHandler getDateStringFrom:[NSDate dateWithTimeIntervalSince1970:[documentObj.added longLongValue]] withFormat:@"MMMM, yyyy"]];
    [self.lblCreatedDate setText:[DateHandler getDateStringFrom:[NSDate dateWithTimeIntervalSince1970:[documentObj.created longLongValue]] withFormat:@"MMMM, yyyy"]];
    [self.txtRelevantDate setText:[DateHandler getDateStringFrom:[NSDate dateWithTimeIntervalSince1970:[documentObj.relevantDate longLongValue]] withFormat:@"MMMM, yyyy"]];
    self.relevantDate = [NSDate dateWithTimeIntervalSince1970:[documentObj.relevantDate longLongValue]];
}

- (void)resetView {
    [self setEditStatus:NO];
    [self loadViewWithDocument:self.documentObj];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.btnClose setLeft:self.frame.size.width - 60];
        [self.btnSave setLeft:[self.btnClose right]];
    }];
}

- (void)setEditStatus:(BOOL)status {
    self.isEditing = status;
    
    [self.btnEditFileName setHidden:status];
    [self.btnEditRelevant setHidden:status];
    [self.txtDocumentName setEnabled:status];
    
    if (!status) {
        [self.txtDocumentName resignFirstResponder];
        [self.txtRelevantDate resignFirstResponder];
    }
}

- (void)showPickerView:(UIButton *)buttonTouched {
    if (self.popoverController == nil) {
        UIViewController* popoverContent = [[UIViewController alloc] init]; //ViewController
        
        SelectDateView *selectDateView = [[SelectDateView alloc] initWithFrame:CGRectMake(0, 0, 300, 250)];
        selectDateView.backgroundColor = [UIColor whiteColor];
        [selectDateView setDate:self.relevantDate];
        popoverContent.view = selectDateView;
        selectDateView.delegate = self;
        
        self.popoverController = [[MyPopoverWrapper alloc] initWithContentViewController:popoverContent];
        self.popoverController.delegate=self;
    }
    
    //Set current date on GUI to picker
    SelectDateView *v = (SelectDateView*)[self.popoverController getContentView];
    [v setDate:self.relevantDate];
    
    [self.popoverController setPopoverContentSize:CGSizeMake(320, 264) animated:NO];
    CGRect selectedButtonFrame = [self convertRect:buttonTouched.frame toView:self];
    [self.popoverController presentPopoverFromRect:selectedButtonFrame inView:self permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
}

- (void)dateChanged:(id)sender {
    
}

- (BOOL)shouldShowTitleHeader {
    return YES;
}

- (void)layoutSubviews {
    CGRect rect = self.topView.frame;
    rect.size.width = self.frame.size.width;
    if ([self shouldShowTitleHeader]) {
        rect.size.height = ROW_HEIGHT;
    } else {
        rect.size.height = 0;
    }
    self.topView.frame = rect;
    
    rect = self.lblTitle.frame;
    rect.size.width = self.topView.frame.size.width - rect.origin.x;
    [self.lblTitle setFrame:rect];
    
    self.centerView.frame = CGRectMake(0, ROW_HEIGHT, self.frame.size.width, self.frame.size.height - ROW_HEIGHT);
    
    rect = self.txtDocumentName.frame;
    rect.size.width = self.frame.size.width - rect.origin.x - 44;
    self.txtDocumentName.frame = rect;
    
    [self.btnEditFileName setRight:self.frame.size.width - 10];
    [self.btnEditRelevant setRight:self.frame.size.width - 10];
    
    if (self.isEditing) {
        [self.btnClose setLeft:self.frame.size.width - 120];
        [self.btnSave setLeft:[self.btnClose right]];
    } else {
        [self.btnClose setLeft:self.frame.size.width - 60];
        [self.btnSave setFrame:CGRectMake([self.btnClose right], [self.btnClose top], 60, ROW_HEIGHT)];
    }
    
    rect = self.tagListView.frame;
    rect.size.width = self.frame.size.width - rect.origin.x - 20;
    self.tagListView.frame = rect;
    
    [self.line1 setWidth:self.frame.size.width - 40];
    [self.line2 setWidth:self.frame.size.width - 40];
    [self.line3 setWidth:self.frame.size.width - 40];
    [self.line4 setWidth:self.frame.size.width - 40];
    [self.line5 setWidth:self.frame.size.width - 40];
    [self.line6 setWidth:self.frame.size.width - 40];
}

#pragma mark - Button events
- (void)handleEditRelevantDate:(id)sender {
    [self showPickerView:self.btnEditRelevant];
}

- (void)handleEditFileName:(id)sender {
    [self setEditStatus:YES];
    
    [UIView animateWithDuration:0.3 animations:^{
        [self.btnClose setLeft:self.frame.size.width - 120];
        [self.btnSave setLeft:[self.btnClose right]];
    }];
    
    [self.txtDocumentName becomeFirstResponder];
    
    if ([self.delegate respondsToSelector:@selector(didEditFilenameButtonTouched:)]) {
        [self.delegate didEditFilenameButtonTouched:self];
    }
}

- (void)handleCloseButton:(id)sender {
    [self resetView];
    
    if ([self.delegate respondsToSelector:@selector(didCloseButtonTouched:)]) {
        [self.delegate didCloseButtonTouched:self];
    }
}

- (void)handleSaveButton:(id)sender {
    if (![[NetworkReachability getInstance] checkInternetActiveManually]) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_NO_INTERNET_CONNECTION2", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    NSString *docName = [self.txtDocumentName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([docName length] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_INVALID_FILE_NAME", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    NSString *relevantDate = [NSString stringWithFormat:@"%lf", [self.relevantDate timeIntervalSince1970]];
    if ([relevantDate length] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_INVALID_RELEVANT", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    NSString *oldDocname = self.documentObj.docname?self.documentObj.docname:self.documentObj.filename;
    if ([oldDocname isEqualToString:docName] && [self.relevantDate compare:[NSDate dateWithTimeIntervalSince1970:[self.documentObj.relevantDate longLongValue]]] == NSOrderedSame) {
        [self handleCloseButton:nil]; //Just close the GUI
        return;
    }
    
    //self.documentObj.docname = docName;
    //self.documentObj.relevantDate = [NSNumber numberWithInt:[relevantDate intValue]];
    NSArray *properties = [[NSArray alloc] initWithObjects:@"docname", @"filename", @"relevantDate", nil];
    DocumentObject *newDoc = [[DocumentObject alloc] init];
    newDoc.id = self.documentObj.id;
    newDoc.docname = docName;
    newDoc.relevantDate = [NSNumber numberWithInt:[relevantDate intValue]];
    newDoc.filename = self.documentObj.filename;
    
    if ([self.delegate respondsToSelector:@selector(willUpdateDocumentValue:withProperties:)]) {
        [self.delegate willUpdateDocumentValue:newDoc withProperties:properties];
    }
}

#pragma mark - SelectDateViewDelegate
- (void)didSelectDate:(id)sender date:(NSDate *)date {
    NSString *oldDocname = self.documentObj.docname?self.documentObj.docname:self.documentObj.filename;
    NSString *newDocName = [self.txtDocumentName.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([oldDocname isEqualToString:newDocName] && [self.relevantDate compare:date] == NSOrderedSame) {
        [self.popoverController dismissPopoverAnimated:YES];
        return;
    }
    
    self.relevantDate = date;
    NSString *dateString = [DateHandler getDateStringFrom:date withFormat:@"MMMM, yyyy"];
    [self.txtRelevantDate setText:dateString];
    [self.popoverController dismissPopoverAnimated:YES];
    [self handleSaveButton:nil];
}

- (void)didCloseDate:(id)sender {
    [self.popoverController dismissPopoverAnimated:YES];
}

@end
