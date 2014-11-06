//
//  DocumentGroupCollectionEditView.m
//  FileThis
//
//  Created by Manh nguyen on 1/14/14.
//
//

#import "DocumentGroupCollectionEditView.h"
#import "DocumentProfileObject.h"
#import "DocumentCabinetObject.h"
#import "CommonLayout.h"

#define HEIGHT_FOR_HEADER  40

@implementation DocumentGroupCollectionEditView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = kDocumentGroupHeaderColor;
        self.lblHeaderInSection = [[UILabel alloc] initWithFrame:CGRectMake(kGroupHeaderMargin, 0, self.frame.size.width - kGroupHeaderMargin*2, HEIGHT_FOR_HEADER)];
        [self addSubview:self.lblHeaderInSection];
        
        [self.lblHeaderInSection setFont:[UIFont fontWithName:@"Merriweather-Italic" size:kFontSizeNormal] textColor:kGrayColor backgroundColor:kDocumentGroupHeaderColor text:@"" numberOfLines:0 textAlignment:NSTextAlignmentCenter];
        [self.lblHeaderInSection setUserInteractionEnabled:YES];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.lblHeaderInSection.textAlignment = NSTextAlignmentRight;
        }
        
        self.btnSelect = [CommonLayout createTextButton:CGRectMake(0, 0, 100, 40) fontSize:kFontSizeXLarge isBold:YES text:NSLocalizedString(@"ID_SELECT", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleSelectButton:) superView:self.lblHeaderInSection];
        
        self.btnCancel = [CommonLayout createTextButton:self.btnSelect.frame fontSize:kFontSizeXLarge isBold:YES text:NSLocalizedString(@"ID_CANCEL", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleCancelButton:) superView:self.lblHeaderInSection];
        
        self.btnSelectAll = [CommonLayout createTextButton:CGRectMake(self.lblHeaderInSection.frame.size.width - 100, 0, 100, 40) fontSize:kFontSizeXLarge isBold:YES text:NSLocalizedString(@"ID_SELECT_ALL", @"") textColor:kCabColorAll touchTarget:self touchSelector:@selector(handleSelectAllButton:) superView:self.lblHeaderInSection];
        
        if (self.editingMode) {
            [self.btnCancel setHidden:NO];
            [self.btnSelect setHidden:YES];
            [self.btnSelectAll setHidden:NO];
        } else {
            [self.btnCancel setHidden:YES];
            [self.btnSelect setHidden:NO];
            [self.btnSelectAll setHidden:YES];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [self.lblHeaderInSection setFrame:CGRectMake(kGroupHeaderMargin, 0, self.frame.size.width - 2*kGroupHeaderMargin, HEIGHT_FOR_HEADER - 2)];
    self.btnSelectAll.frame = CGRectMake(self.lblHeaderInSection.frame.size.width - 100, 0, 100, 40);
}


- (void)setDocumentGroupData:(id)group {
    self.documentGroup = group;
    [self.lblHeaderInSection setText:[self getHeaderString]];
}

- (NSString *)getHeaderString {
    NSString *headerTitle = @"";
    if ([self.documentGroup isKindOfClass:[DocumentProfileObject class]]) {
        DocumentProfileObject *docProfileObj = self.documentGroup;
        headerTitle = [NSString stringWithFormat:NSLocalizedString(@"ID_I_DOCUMENTS_IN_ACC", @""), [docProfileObj.arrDocuments count]];
    } else {
        DocumentCabinetObject *docCabObj = self.documentGroup;
        if (docCabObj.cabinetObj == nil) {
            if (docCabObj.arrDocuments.count > 1) {
                headerTitle = [NSString stringWithFormat:NSLocalizedString(@"ID_I_DOCUMENTS_IN_SEARCH_RESULT", @""), [docCabObj.arrDocuments count]];
            } else {
                headerTitle = [NSString stringWithFormat:NSLocalizedString(@"ID_I_DOCUMENT_IN_SEARCH_RESULT", @""), [docCabObj.arrDocuments count]];
            }
            
        } else {
            if (docCabObj.arrDocuments.count > 1) {
                headerTitle = [NSString stringWithFormat:NSLocalizedString(@"ID_I_DOCUMENTS_IN_CAB", @""), [docCabObj.arrDocuments count]];
            } else {
                headerTitle = [NSString stringWithFormat:NSLocalizedString(@"ID_I_DOCUMENT_IN_CAB", @""), [docCabObj.arrDocuments count]];
            }
        }
    }
    
    return headerTitle;
}

- (void)refreshHeaderButtons:(BOOL)selectMode
{
    self.btnSelect.hidden = selectMode;
    self.btnCancel.hidden = !selectMode;
    self.btnSelectAll.hidden = !selectMode;
}

#pragma mark - Button events
- (void)handleSelectButton:(id)sender {
    [self refreshHeaderButtons:YES];
    
    if ([self.delegate respondsToSelector:@selector(didShowEditingMode:)]) {
        [self.delegate didShowEditingMode:self];
    }
}

- (void)handleSelectAllButton:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectAllEditingMode:)]) {
        [self.delegate didSelectAllEditingMode:self];
    }
}

- (void)handleCancelButton:(id)sender {
    [self refreshHeaderButtons:NO];
    
    if ([self.delegate respondsToSelector:@selector(didCancelEditingMode:)]) {
        [self.delegate didCancelEditingMode:self];
    }
}

@end
