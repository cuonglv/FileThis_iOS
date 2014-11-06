//
//  DocumentTagsView.m
//  FileThis
//
//  Created by Manh nguyen on 12/25/13.
//
//

#import "DocumentTagsView.h"
#import "TagDataManager.h"
#import "TagObject.h"
#import "ThreadManager.h"
#import "DocumentDataManager.h"
#import "EventManager.h"
#import "Utils.h"
#import <QuartzCore/QuartzCore.h>

@interface DocumentTagsView()
@property (assign) BOOL isEditting;
@end

@implementation DocumentTagsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
        v.backgroundColor = [UIColor colorWithRed:213/255.0 green:214/255.0 blue:219/255.0 alpha:1];
        self.topView = v;
        [self addSubview:self.topView];
        
        UIFont *textFont = [CommonLayout getFont:FontSizeSmall isBold:NO];
        
        self.lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, 40)];
        [self.lblTitle setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal] textColor:kWhiteColor backgroundColor:kCabColorAll text:@"" numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        [self.topView addSubview:self.lblTitle];
        
        self.editButton = [CommonLayout createTextButton:CGRectMake(frame.size.width - 80, 5, 70, 30) font:textFont text:NSLocalizedString(@"ID_EDIT", @"") textColor:[UIColor whiteColor] touchTarget:self touchSelector:@selector(handleEditButton) superView:self.topView];
        self.isEditting = NO;
        
        UILabel *lblTemp = [[UILabel alloc] initWithFrame:[self.editButton rectAtLeft:1 width:1]];
        [self.topView addSubview:lblTemp];
        [lblTemp setBackgroundColor:kWhiteColor];
        self.lblTemp = lblTemp;
        
        self.btnAddThisTag = [[UIButton alloc] initWithFrame:[lblTemp rectAtLeft:1 width:140]];
        [self.btnAddThisTag setTitle:NSLocalizedString(@"ID_ADD_THIS_TAG", @"") forState:UIControlStateNormal];
        [self.btnAddThisTag setBackgroundColor:kCabColorAll];
        [self.btnAddThisTag.titleLabel setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeNormal]];
        [self.btnAddThisTag addTarget:self action:@selector(handleAddThisTagButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:self.btnAddThisTag];
        
        self.txtSearchTags = [[BorderTextField alloc] initWithFrame:[self.btnAddThisTag rectAtLeft:10 width:200]];
        [self.txtSearchTags setPlaceholder:@"Search"];
        [self.txtSearchTags setBackgroundColor:kWhiteColor];
        self.txtSearchTags.delegate = self;
        [self.txtSearchTags setPlaceholder:NSLocalizedString(@"ID_SELECT_TAGS", @"")];
        [self.txtSearchTags.layer setCornerRadius:2.0];
        self.txtSearchTags.clearButtonMode = UITextFieldViewModeAlways;
        self.txtSearchTags.returnKeyType = UIReturnKeyDone;
        [self.topView addSubview:self.txtSearchTags];
        
        self.btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 0, 70, 40)];
        [self.btnDone setTitle:NSLocalizedString(@"ID_DONE", @"") forState:UIControlStateNormal];
        [self.btnDone setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [self.btnDone addTarget:self action:@selector(handleDoneButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnDone.titleLabel setFont:[CommonLayout getFont:FontSizeSmall isBold:NO]];
        [self.btnDone setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        //[self.btnDone autoWidth];
        [self.topView addSubview:self.btnDone];
        
        self.selectTagsView = [[SelectTagsView alloc] initWithFrame:CGRectMake(10, [self.topView bottom], frame.size.width - 20, frame.size.height - [self.topView bottom]) margin:10];
        [self addSubview:self.selectTagsView];
        self.selectTagsView.delegate = self;
        
        self.arrDocuments = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)resetView {
    [self.txtSearchTags resignFirstResponder];
    [self.txtSearchTags setText:@""];
    [self.selectTagsView filterItems];
}

- (void)loadViewWithDocumentList:(NSMutableArray *)documents {
    //[self.lblTitle setHidden:NO];
    [self.arrDocuments removeAllObjects];
    [self.arrDocuments addObjectsFromArray:documents];
    [self.selectTagsView.selectedItems removeAllObjects];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (DocumentObject *docObj in self.arrDocuments) {
        for (id tagId in docObj.tags) {
            if ([dict objectForKey:tagId]) {
                NSNumber *num = [dict objectForKey:tagId];
                int newValue = [num intValue] + 1;
                num = [NSNumber numberWithInt:newValue];
                [dict setObject:num forKey:tagId];
            } else {
                NSNumber *num = [NSNumber numberWithInt:1];
                [dict setObject:num forKey:tagId];
            }
        }
    }
    
    for (id tagId in [dict allKeys]) {
        if ([dict objectForKey:tagId]) {
            NSNumber *num = [dict objectForKey:tagId];
            int value = [num intValue];
            if (value == [self.arrDocuments count]) {
                TagObject *tagObj = [[TagDataManager getInstance] getObjectByKey:tagId];
                if (tagObj) {
                    [self.selectTagsView.selectedItems addObject:tagObj];
                }
            }
        }
    }
    
    [self.selectTagsView filterItems];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [self layoutSubviews_topView];
    [self.selectTagsView setFrame:CGRectMake(10, [self.topView bottom], self.frame.size.width - 20, self.frame.size.height - [self.topView bottom])];
}

- (void)layoutSubviews_topView {
    [self.topView setFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    [self.lblTitle setFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    [self.editButton setFrame:CGRectMake(self.frame.size.width - 80, 5, 70, 30)];
    [self.lblTemp setFrame:[self.editButton rectAtLeft:1 width:1]];
    [self.btnAddThisTag setFrame:[self.lblTemp rectAtLeft:1 width:160]];
    [self.txtSearchTags setFrame:[self.btnAddThisTag rectAtLeft:10 width:200]];
}

#pragma mark - My Func
- (void)cancelEditing {
    self.selectTagsView.isEditting = NO;
    self.isEditting = NO;
    [self refreshTextStatus];
}

- (void)refreshTextStatus {
    if (self.selectTagsView.isEditting) {
        [self.editButton setTitle:NSLocalizedString(@"ID_CANCEL", @"") forState:UIControlStateNormal];
    } else {
        [self.editButton setTitle:NSLocalizedString(@"ID_EDIT", @"") forState:UIControlStateNormal];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.selectTagsView setFilteredString:newText];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.selectTagsView setFilteredString:@""];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtSearchTags) {
        [self.txtSearchTags resignFirstResponder];
        [self handleAddThisTagButton:self.btnAddThisTag];
    }
    return YES;
}

#pragma mark - SelectItemsViewDelegate
- (void)didSelectItem:(id)item {
    if ([self.delegate respondsToSelector:@selector(didSelectTag:)]) {
        [self.delegate didSelectTag:item];
    }
}

- (void)didDeselectItem:(id)item {
    if ([self.delegate respondsToSelector:@selector(didDeselectTag:)]) {
        [self.delegate didDeselectTag:item];
    }
}

#pragma mark - Button
- (void)handleEditButton {
    self.isEditting = !self.isEditting;
    self.selectTagsView.isEditting = self.isEditting;
    [self refreshTextStatus];
}

- (void)handleDoneButton:(id)sender {
    [self.txtSearchTags resignFirstResponder];
    [self.selectTagsView setFilteredString:@""];
    
    if ([self.delegate respondsToSelector:@selector(didTagsViewDoneButtonTouched:)]) {
        [self.delegate didTagsViewDoneButtonTouched:self];
    }
    [self cancelEditing];
}

- (void)handleAddThisTagButton:(id)sender {
    NSString *newTagName = [self.txtSearchTags.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([newTagName length] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_PLEASE_INPUT_A_TAG_NAME", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    if (![[TagDataManager getInstance] checkTagNameExisted:newTagName]) {
        TagObject *tagObj = [[TagDataManager getInstance] addTag:newTagName];
        if (tagObj) {
            [[TagDataManager getInstance] addObject:tagObj];
            [[TagDataManager getInstance] updateFindObjectByIdDictionary];
            [self.selectTagsView filterItems];
        }
    } else {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_TAG_EXISTED", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
    }
}

@end
