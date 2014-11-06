//
//  DocumentCabinetsView.m
//  FileThis
//
//  Created by Manh nguyen on 1/4/14.
//
//

#import "DocumentCabinetsView.h"
#import "CabinetDataManager.h"
#import "CabinetObject.h"
#import "ThreadManager.h"
#import "DocumentDataManager.h"
#import "EventManager.h"
#import "Utils.h"
#import "DocumentCabinetObject.h"
#import "LoadingView.h"
#import "CommonDataManager.h"
#import "CommonFunc.h"
#import "BorderTextField.h"
#import <QuartzCore/QuartzCore.h>

@implementation DocumentCabinetsView

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
        [self.lblTitle setFont:textFont textColor:kDarkGrayColor backgroundColor:kCabColorAll text:@"" numberOfLines:0 textAlignment:NSTextAlignmentLeft];
        [self.topView addSubview:self.lblTitle];
        
        self.editButton = [CommonLayout createTextButton:CGRectMake(frame.size.width - 80, 5, 70, 30) font:textFont text:NSLocalizedString(@"ID_EDIT", @"") textColor:[UIColor whiteColor] touchTarget:self touchSelector:@selector(handleEditButton) superView:self.topView];
        self.isEditting = NO;
        
        UILabel *lblTemp = [[UILabel alloc] initWithFrame:[self.editButton rectAtLeft:1 width:1]];
        [self.topView addSubview:lblTemp];
        [lblTemp setBackgroundColor:kWhiteColor];
        self.lblTemp = lblTemp;
        
        self.btnAddThisCabinet = [[UIButton alloc] initWithFrame:[lblTemp rectAtLeft:1 width:160]];
        [self.btnAddThisCabinet setTitle:NSLocalizedString(@"ID_ADD_THIS_CABINET", @"") forState:UIControlStateNormal];
        [self.btnAddThisCabinet setBackgroundColor:nil];
        [self.btnAddThisCabinet.titleLabel setFont:textFont];
        [self.btnAddThisCabinet addTarget:self action:@selector(handleAddThisCabinetButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:self.btnAddThisCabinet];
        
        self.txtSearchCabinets = [[BorderTextField alloc] initWithFrame:[self.btnAddThisCabinet rectAtLeft:10 width:200]];
        [self.txtSearchCabinets setPlaceholder:@"Search"];
        [self.txtSearchCabinets setBackgroundColor:kWhiteColor];
        [self.txtSearchCabinets setPlaceholder:NSLocalizedString(@"ID_SELECT_CABINETS", @"")];
        self.txtSearchCabinets.delegate = self;
        [self.txtSearchCabinets.layer setCornerRadius:2.0];
        self.txtSearchCabinets.clearButtonMode = UITextFieldViewModeAlways;
        self.txtSearchCabinets.returnKeyType = UIReturnKeyDone;
        [self.topView addSubview:self.txtSearchCabinets];
        
        self.btnDone = [[UIButton alloc] initWithFrame:CGRectMake(10, 5, 100, 30)];
        [self.btnDone setTitle:NSLocalizedString(@"ID_DONE", @"") forState:UIControlStateNormal];
        [self.btnDone setTitleColor:kWhiteColor forState:UIControlStateNormal];
        [self.btnDone addTarget:self action:@selector(handleDoneButton:) forControlEvents:UIControlEventTouchUpInside];
        [self.btnDone.titleLabel setFont:textFont];
        [self.topView addSubview:self.btnDone];
        [self.btnDone setContentHorizontalAlignment:UIControlContentHorizontalAlignmentLeft];
        [self.btnDone autoWidth];
        
        self.selectCabinetsView = [[SelectCabinetsView alloc] initWithFrame:CGRectMake(10, [self.topView bottom], frame.size.width - 20, frame.size.height - [self.topView bottom]) margin:10];
        self.selectCabinetsView.delegate = self;
        [self addSubview:self.selectCabinetsView];
        
        self.arrDocuments = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)resetView {
    [self.txtSearchCabinets resignFirstResponder];
    [self.txtSearchCabinets setText:@""];
    [self.selectCabinetsView filterItems];
}

- (void)loadViewWithDocumentList:(NSMutableArray *)documents {
    [self.arrDocuments removeAllObjects];
    [self.arrDocuments addObjectsFromArray:documents];
    [self.selectCabinetsView.selectedItems removeAllObjects];
    
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    for (DocumentObject *docObj in self.arrDocuments) {
        for (id cabId in docObj.cabs) {
            if ([dict objectForKey:cabId]) {
                NSNumber *num = [dict objectForKey:cabId];
                int newValue = [num intValue] + 1;
                num = [NSNumber numberWithInt:newValue];
                [dict setObject:num forKey:cabId];
            } else {
                NSNumber *num = [NSNumber numberWithInt:1];
                [dict setObject:num forKey:cabId];
            }
        }
    }
    
    for (id cabId in [dict allKeys]) {
        if ([dict objectForKey:cabId]) {
            NSNumber *num = [dict objectForKey:cabId];
            int value = [num intValue];
            if (value == [self.arrDocuments count]) {
                CabinetObject *cabObj = [[CabinetDataManager getInstance] getObjectByKey:cabId];
                if (cabObj) {
                    [self.selectCabinetsView.selectedItems addObject:cabObj];
                }
            }
        }
    }
    
    [self.selectCabinetsView filterItems];
}

#pragma mark - Layout
- (void)layoutSubviews {
    [self layoutSubviews_topView];
    [self.selectCabinetsView setFrame:CGRectMake(10, [self.topView bottom], self.frame.size.width - 20, self.frame.size.height - [self.topView bottom])];
}

- (void)layoutSubviews_topView {
    [self.topView setWidth:self.frame.size.width];
    [self.lblTitle setFrame:CGRectMake(0, 0, self.frame.size.width, 40)];
    [self.editButton setFrame:CGRectMake(self.frame.size.width - 80, 5, 70, 30)];
    [self.lblTemp setFrame:[self.editButton rectAtLeft:1 width:1]];
    [self.btnAddThisCabinet setFrame:[self.lblTemp rectAtLeft:1 width:160]];
    [self.txtSearchCabinets setFrame:[self.btnAddThisCabinet rectAtLeft:10 width:200]];
}

#pragma mark - My Func
- (void)cancelEditing {
    self.selectCabinetsView.isEditting = NO;
    self.isEditting = NO;
    [self refreshTextStatus];
}

- (void)refreshTextStatus {
    if (self.selectCabinetsView.isEditting) {
        [self.editButton setTitle:NSLocalizedString(@"ID_CANCEL", @"") forState:UIControlStateNormal];
    } else {
        [self.editButton setTitle:NSLocalizedString(@"ID_EDIT", @"") forState:UIControlStateNormal];
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    [self.selectCabinetsView setFilteredString:newText];
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField {
    [self.selectCabinetsView setFilteredString:@""];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.txtSearchCabinets) {
        [textField resignFirstResponder];
        [self handleAddThisCabinetButton:self.btnAddThisCabinet];
    }
    return YES;
}

#pragma mark - SelectCabinetsViewDelegate
- (void)didCabinetsViewDoneButtonTouched:(id)sender {
    [self.txtSearchCabinets resignFirstResponder];
    if ([self.delegate respondsToSelector:@selector(didCabinetsViewDoneButtonTouched:)]) {
        [self.delegate didCabinetsViewDoneButtonTouched:self];
    }
}

#pragma mark - SelectItemsViewDelegate
- (void)didSelectItem:(id)item {
    if ([self.delegate respondsToSelector:@selector(didSelectCabinet:)]) {
        [self.delegate didSelectCabinet:item];
    }
}

- (void)didDeselectItem:(id)item {
    if ([self.delegate respondsToSelector:@selector(didDeselectCabinet:)]) {
        [self.delegate didDeselectCabinet:item];
    }
}

#pragma mark - Button
- (void)handleEditButton {
    self.isEditting = !self.isEditting;
    self.selectCabinetsView.isEditting = self.isEditting;
    [self refreshTextStatus];
}

- (void)handleAddThisCabinetButton:(id)sender {
    NSString *newCabinetName = [self.txtSearchCabinets.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([newCabinetName length] == 0) {
        [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_WARNING", @"") tag:0 content:NSLocalizedString(@"ID_PLEASE_INPUT_A_CABINET_NAME", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        return;
    }
    
    [NSThread detachNewThreadSelector:@selector(addThisCabinetThread:) toTarget:self withObject:newCabinetName];
}

- (void)handleDoneButton:(id)sender {
    [self.txtSearchCabinets resignFirstResponder];
    [self.selectCabinetsView setFilteredString:@""];
    if ([self.delegate respondsToSelector:@selector(didCabinetsViewDoneButtonTouched:)]) {
        [self.delegate didCabinetsViewDoneButtonTouched:self];
    }
    [self cancelEditing];
}

#pragma mark - Methods run in thread
- (void)addThisCabinetThread:(NSString*)newCabinetName {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        [LoadingView startCurrentLoadingView:@"Adding cabinet..."];
    });
    
    if (![[CabinetDataManager getInstance] checkCabinetNameExisted:newCabinetName]) {
        CabinetObject *cabObj = [[CabinetDataManager getInstance] addCabinet:newCabinetName];
        if (cabObj) {
            [[CabinetDataManager getInstance] addObject:cabObj];
            [[CabinetDataManager getInstance] updateFindObjectByIdDictionary];
            
            DocumentCabinetObject *documentCabObj = [[DocumentCabinetObject alloc] init];
            documentCabObj.cabinetObj = cabObj;
            
            [[CommonDataManager getInstance] addDocumentCabinet:documentCabObj];
            [[CommonDataManager getInstance] sortDocumentCabinets];
            
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                Event *event = [[Event alloc] initEventWithType:EVENT_TYPE_ADD_CABINET];
                [event setContent:documentCabObj];
                [[EventManager getInstance] callbackToChannelProtocolWithEvent:event channel:CHANNEL_DATA];
            });
        }
    } else {
        dispatch_async(dispatch_get_main_queue(), ^(void) {
            [Utils showAlertMessageWithTitle:NSLocalizedString(@"ID_INFO", @"") tag:0 content:NSLocalizedString(@"ID_CABINET_EXISTED", @"") delegate:nil cancelButtonTitle:NSLocalizedString(@"ID_CLOSE", @"") otherButtonTitles:nil];
        });
    }
    
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        [LoadingView stopCurrentLoadingView];
    });
}

@end
