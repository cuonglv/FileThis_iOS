//
//  DocumentSearchCriteriaView.m
//  FileThis
//
//  Created by Cuong Le on 1/9/14.
//
//

#import "DocumentSearchCriteriaView.h"
#import "BorderView.h"
#import "TagDataManager.h"
#import "MyCollectionFlowLayout.h"
#import "TagCollectionCell.h"
#import "SearchByDateView.h"
#import "DocumentSearchCriteriaCell.h"
#import "DateHandler.h"
#import "SelectedTagsDocumentViewController.h"
#import "FTMobileAppDelegate.h"

#define kCellId @"cellId"

@interface DocumentSearchCriteriaView() <UITableViewDelegate, UITableViewDataSource, DocumentSearchCriteriaCellDelegate> //<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) BorderView *headerView; //, *footerView;
@property (nonatomic, strong) UILabel *headerLabel;
@property (nonatomic, strong) UIButton *clearButton, *searchNowButton;
@property (nonatomic, strong) UIImageView *arrowImageView;
//@property (nonatomic, strong) UICollectionView *myCollectionView;
@property (nonatomic, strong) UITableView *myTable;

@end

@implementation DocumentSearchCriteriaView

- (id)initWithFrame:(CGRect)frame superView:(UIView*)superView delegate:(id<DocumentSearchCriteriaViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        self.delegate = delegate;
        
        self.documentSearchCriteria = [[DocumentSearchCriteria alloc] init];
        
        self.headerView = [[BorderView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, kDocumentSearchView_SearchByHeaderViewHeight) borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0, 0, 0, 1) superView:self];
        self.headerView.backgroundColor = kDocumentSearchView_SearchByDateViewBackColor;
        
        self.headerLabel = [CommonLayout createLabel:CGRectMake(kDocumentSearchView_MarginLeft, 0, 300, self.headerView.frame.size.height) fontSize:FontSizeSmall isBold:NO isItalic:YES textColor:kDocumentSearchView_TextColor backgroundColor:nil text:NSLocalizedString(@"ID_YOU_ARE_SEARCHING_FOR", @"") superView:self.headerView];
        [self.headerLabel autoWidth];
        
        self.arrowImageView = [CommonLayout createImageView:CGRectMake(self.headerView.frame.size.width - 40, self.headerView.frame.size.height/2-15, 22, 30) image:[UIImage imageNamed:@"arrow_icon_small.png"] contentMode:UIViewContentModeCenter superView:self.headerView];
        
        self.searchNowButton = [CommonLayout createTextButton:CGRectMake([self.arrowImageView left] - 104, 2, 100, self.headerView.frame.size.height-4) font:[CommonLayout getFont:FontSizeMedium isBold:YES] text:NSLocalizedString(@"ID_SEARCH_NOW", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleSearchNowButton) superView:self.headerView];
        [self.searchNowButton autoWidth];
        
        self.clearButton = [CommonLayout createTextButton:[self.searchNowButton rectAtLeft:20 width:70] font:[CommonLayout getFont:FontSizeMedium isBold:NO] text:NSLocalizedString(@"ID_CLEAR", @"") textColor:kTextOrangeColor touchTarget:self touchSelector:@selector(handleClearButton) superView:self.headerView];
        [self.clearButton autoWidth];
        
        float y;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.clearButton setLeft:kDocumentSearchView_MarginLeft];
            [self.clearButton autoWidth];
            [self.headerLabel sizeToFit];
            [self.headerLabel setTop:[self.headerView bottom] + 8];
            y = [self.headerLabel bottom] + 6;
        } else {
            y = [self.headerView bottom]+10;
        }
        
        self.myTable = [[UITableView alloc] initWithFrame:CGRectMake(0, y, self.frame.size.width-4, self.frame.size.height-y)];
        self.myTable.backgroundColor = [UIColor whiteColor];
        self.myTable.rowHeight = kDocumentSearchCriteriaCellHeight;
        self.myTable.separatorColor = [UIColor clearColor]; //kBorderLightGrayColor;
        self.myTable.delegate = self;
        self.myTable.dataSource = self;
        self.myTable.scrollEnabled = YES;
        self.myTable.allowsSelection = NO;
        [self addSubview:self.myTable];
        
        [superView addSubview:self];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    float width = self.frame.size.width;
    float height = self.frame.size.height;
    [self.headerView setRightWithoutChangingLeft:width];
    [self.arrowImageView setRight:width-4];
    [self.searchNowButton setRight:[self.arrowImageView left]];
    [self.myTable setRightWithoutChangingLeft:width bottomWithoutChangingTop:height];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.clearButton moveToLeftOfView:self.searchNowButton offset:15];
    }
}

#pragma mark - Table
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            if (self.documentSearchCriteria.date1)
                return 1;
            
            break;
            
        case 1:
            return [self.documentSearchCriteria.texts count];
            
        case 2:
            if (self.documentSearchCriteria.cabinet || self.documentSearchCriteria.profile)
                return 1;
            
            break;
            
        case 3:
            return [self.documentSearchCriteria.tags count];
            break;
            
        case 4:
            return [self.documentSearchCriteria.relatedUnselectedTags count];
            break;
            
        default:
            break;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"DocumentSearchCriteriaCell";
    
    DocumentSearchCriteriaCell *cell = (DocumentSearchCriteriaCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[DocumentSearchCriteriaCell alloc] initWithReuseIdentifier:cellIdentifier tableView:tableView delegate:self];
    }
    int indentLevel = 0;
    NSString *text = nil;
    NSString *rightText = nil;
    TagCollectionCellBackgroundType backgroundType = TagCollectionCellBackgroundTypeClear;
    
    switch (indexPath.section) {
        case 0:
            if (self.documentSearchCriteria.date1) {
                text = [DateHandler displayedMonthYearStringFromDateComps:self.documentSearchCriteria.date1 toDateComps:self.documentSearchCriteria.date2];
                backgroundType = TagCollectionCellBackgroundTypeDateX;
            }
            break;
            
        case 1:
            if (indexPath.row < [self.documentSearchCriteria.texts count]) {
                text = [self.documentSearchCriteria.texts objectAtIndex:indexPath.row];
                backgroundType = TagCollectionCellBackgroundTypeTextX;
            }
            break;
            
        case 2:
            if (self.documentSearchCriteria.cabinet) {
                text = self.documentSearchCriteria.cabinet.name;
                backgroundType = TagCollectionCellBackgroundTypeCabinetX;
            } else {
                text = self.documentSearchCriteria.profile.name;
                backgroundType = TagCollectionCellBackgroundTypeProfileX;
            }
            break;
            
        case 3:
            if (indexPath.row < [self.documentSearchCriteria.tags count]) {
                text = ((TagObject*)[self.documentSearchCriteria.tags objectAtIndex:indexPath.row]).name;
                indentLevel = indexPath.row;
                if (indexPath.row == [self.documentSearchCriteria.tags count]-1) {
                    rightText = [NSString stringWithFormat:@"%i",[self.documentSearchCriteria.relatedDocuments count]];
                    backgroundType = TagCollectionCellBackgroundTypeTagOrangeWithTail;
                } else {
                    backgroundType = TagCollectionCellBackgroundTypeTagOrange;
                }
            }
            break;
            
        default:
            if (indexPath.row < [self.documentSearchCriteria.relatedUnselectedTags count]) {
                TagObject *tagObj = [self.documentSearchCriteria.relatedUnselectedTags objectAtIndex:indexPath.row];
                text = tagObj.name;
                backgroundType = TagCollectionCellBackgroundTypeTagWhiteWithTail;
                indentLevel = [self.documentSearchCriteria.tags count] - 1;
                rightText = [NSString stringWithFormat:@"%i",tagObj.relatedDocCount];
            }
            break;
    }

    [cell setText:text rightText:rightText backgroundType:backgroundType indentLevel:indentLevel];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    if (indexPath.row < [self.items count])
//        [self.delegate documentRecentSearchView:self touchItem:[self.items objectAtIndex:indexPath.row]];
}

#pragma mark - DocumentSearchCriteriaCellDelegate
- (void)documentSearchCriteriaCellTouched:(id)sender {
    NSIndexPath *indexPath = [self.myTable indexPathForCell:sender];
    if (indexPath) {
        switch (indexPath.section) {
            case 0:
                self.documentSearchCriteria.date1 = nil;
                self.documentSearchCriteria.date2 = nil;
                [self.delegate documentSearchCriteriaView_removedDate:self];
                break;
                
            case 1:
                if (indexPath.row < [self.documentSearchCriteria.texts count]) {
                    [self.documentSearchCriteria.texts removeObjectAtIndex:indexPath.row];
                    [self.delegate documentSearchCriteriaView_removedSearchText:self];
                }
                break;
                
            case 2:
                self.documentSearchCriteria.cabinet = nil;
                self.documentSearchCriteria.profile = nil;
                [self.documentSearchCriteria updateRelatedDocumentsAndTags];
                [self.delegate documentSearchCriteriaView_removedCabinetOrProfile:self];
                break;
                
            case 3:
                if (indexPath.row < [self.documentSearchCriteria.tags count]) {
                    [self.documentSearchCriteria.tags removeObjectAtIndex:indexPath.row];
                    [self.documentSearchCriteria updateRelatedDocumentsAndTags];
                    [self.delegate documentSearchCriteriaView_removedTag:self newTags:self.documentSearchCriteria.tags];
                }
                break;
                
            default:
                if (indexPath.row < [self.documentSearchCriteria.relatedUnselectedTags count]) {
                    [self.documentSearchCriteria.tags addObject:[self.documentSearchCriteria.relatedUnselectedTags objectAtIndex:indexPath.row]];
                    [self.documentSearchCriteria updateRelatedDocumentsAndTags];
                    [self.delegate documentSearchCriteriaView_addedTag:self newTags:self.documentSearchCriteria.tags];
                }
                break;
        }
        if ([self.documentSearchCriteria isEmpty])
            [self.delegate documentSearchCriteriaView_didBecomeEmpty:self];
        
        [self.myTable reloadData];
    }
}

- (void)documentSearchCriteriaCell_ShouldGoNext:(id)sender {
    NSIndexPath *indexPath = [self.myTable indexPathForCell:sender];
    if (indexPath) {
        if (indexPath.section == 3 || indexPath.section == 4) {
            NSMutableArray *selectedTagIds = [BaseObject keysOfObjects:self.documentSearchCriteria.tags];
            if (indexPath.section == 4) { //Unselected tag
                if (indexPath.row < [self.documentSearchCriteria.relatedUnselectedTags count]) {
                    TagObject *tagObj = [self.documentSearchCriteria.relatedUnselectedTags objectAtIndex:indexPath.row];
                    [selectedTagIds addObject:tagObj.id];
                }
            }
            SelectedTagsDocumentViewController *target;
            target = [[SelectedTagsDocumentViewController alloc] initWithNibName:@"DocumentListViewController" bundle:[NSBundle mainBundle]];
            NSMutableArray *docs = [self.documentSearchCriteria getFilteredDocObjsByDateCabProf];
            target.filteredDocumentObjects = [[NSMutableArray alloc] init];
            for (DocumentObject *docObj in docs) {
                if ([docObj matchesTagIds:selectedTagIds])
                    [target.filteredDocumentObjects addObject:docObj];
            }
            [((FTMobileAppDelegate*)[UIApplication sharedApplication].delegate).navigationController pushViewController:target animated:YES];
        }
    }
}

#pragma mark - Button
- (void)handleClearButton {
    self.documentSearchCriteria.date1 = nil;
    self.documentSearchCriteria.date2 = nil;
    self.documentSearchCriteria.texts = [[NSMutableArray alloc] init];
    self.documentSearchCriteria.cabinet = nil;
    self.documentSearchCriteria.cabinetId = nil;
    self.documentSearchCriteria.profile = nil;
    self.documentSearchCriteria.profileId = nil;
    self.documentSearchCriteria.tags = [[NSMutableArray alloc] init];
    [self.delegate documentSearchCriteriaView_removedDate:self];
    [self.delegate documentSearchCriteriaView_removedSearchText:self];
    [self.delegate documentSearchCriteriaView_removedCabinetOrProfile:self];
    [self.delegate documentSearchCriteriaView_removedTag:self newTags:self.documentSearchCriteria.tags];
    [self.delegate documentSearchCriteriaView_didBecomeEmpty:self];
}

- (void)handleSearchNowButton {
    [self.delegate documentSearchCriteriaView_searchNow:self];
}

#pragma mark - MyFunc
- (void)updateUI {
    [self.documentSearchCriteria updateRelatedDocumentsAndTags];
    [self.myTable reloadData];
    if ([self.documentSearchCriteria isEmpty]) {
        [self.delegate documentSearchCriteriaView_didBecomeEmpty:self];
    }
}
@end
