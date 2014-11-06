//
//  DocumentRecentSearchCell.m
//  FileThis
//
//  Created by Cuong Le on 1/11/14.
//
//

#import "DocumentRecentSearchCell.h"
#import "TagCollectionCell.h"
#import "MyCollectionFlowLayout.h"
#import "DateHandler.h"

#define kDocumentRecentSearchCellMargin 20
#define kDocumentRecentSearchCell_CellId @"DocumentRecentSearchCell_CellId"

@interface DocumentRecentSearchCell() <UICollectionViewDelegate, UICollectionViewDataSource>
@property (nonatomic, weak) UITableView *myTable;
@property (nonatomic, strong) UICollectionView *myCollectionView;
@property (nonatomic, strong) UIImageView *arrowImageView;
@property (nonatomic, strong) DocumentSearchCriteria *documentSearchCriteria;
@end

@implementation DocumentRecentSearchCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier tableView:(UITableView*)tableview {
    if (self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        self.myTable = tableview;
        
        self.myCollectionView = [CommonLayout createCollectionView:CGRectMake(kDocumentRecentSearchCellMargin,kDocumentRecentSearchCellMargin, tableview.frame.size.width-kDocumentRecentSearchCellMargin-50, self.frame.size.height-2*kDocumentRecentSearchCellMargin) backgroundColor:kClearColor layout:[[MyCollectionFlowLayout alloc] initWithExtendedHeight:0.0] cellClass:[TagCollectionCell class] cellIdentifier:kDocumentRecentSearchCell_CellId superView:self delegateDataSource:self];
        self.myCollectionView.allowsSelection = NO;
        self.myCollectionView.scrollEnabled = NO;
        self.myCollectionView.userInteractionEnabled = NO;
        
        self.arrowImageView = [CommonLayout createImageView:CGRectMake(tableview.frame.size.width-40, 10, 15, 15) image:[UIImage imageNamed:@"arrow_icon.png"] contentMode:UIViewContentModeScaleAspectFit superView:self];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [self dataCount];
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDocumentRecentSearchCell_CellId forIndexPath:indexPath];
    NSArray *textAndBackgroundType = [self getTextAndBackgroundTypeForRowIndexPath:indexPath];
    if (textAndBackgroundType && [textAndBackgroundType count] > 0)
        [cell setText:[textAndBackgroundType objectAtIndex:0] rightText:[textAndBackgroundType objectAtIndex:2] backgroundType:[[textAndBackgroundType objectAtIndex:1] integerValue]];
    
    return cell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *textAndBackgroundType = [self getTextAndBackgroundTypeForRowIndexPath:indexPath];
    if (textAndBackgroundType)
        return [TagCollectionCell fitSizeForText:[textAndBackgroundType objectAtIndex:0] backgroundType:[[textAndBackgroundType objectAtIndex:1] integerValue] maxWidth:300];
    
    return CGSizeZero;
}

#pragma mark - MyFunc
- (int)dataCount {
    int count = [self.documentSearchCriteria.tags count] + [self.documentSearchCriteria.texts count];
    
    if (self.documentSearchCriteria.cabinet || self.documentSearchCriteria.profile)
        count++;
    
    if (self.documentSearchCriteria.date1) {
        count++;
    }
    
    return count;
}

- (NSArray*)getTextAndBackgroundTypeForRowIndexPath:(NSIndexPath*)indexPath {
    NSString *text = nil, *rightText = @"";
    TagCollectionCellBackgroundType backgroundType = TagCollectionCellBackgroundTypeClear;
    int padding = 0;
    
    if (padding != -1) {
        if (self.documentSearchCriteria.date1) {
            if (indexPath.row == padding) {
                text = [DateHandler displayedMonthYearStringFromDateComps:self.documentSearchCriteria.date1 toDateComps:self.documentSearchCriteria.date2];
                backgroundType = TagCollectionCellBackgroundTypeDate;
                padding = -1;   //found cell text for date
            } else {
                padding++;
            }
        }
    }
    
    if (padding != -1) {
        if (self.documentSearchCriteria.cabinet || self.documentSearchCriteria.profile) {
            if (indexPath.row == padding) {
                if (self.documentSearchCriteria.cabinet) {
                    text = self.documentSearchCriteria.cabinet.name;
                    backgroundType = TagCollectionCellBackgroundTypeCabinet;
                } else {
                    text = self.documentSearchCriteria.profile.name;
                    backgroundType = TagCollectionCellBackgroundTypeProfile;
                }
                padding = -1;   //found cell text for cabinet
            } else {
                padding++;
            }
        }
    }
    
    if (padding != -1) {
        if ([self.documentSearchCriteria.texts count] > 0) {
            if (indexPath.row - padding < [self.documentSearchCriteria.texts count]) {
                text = [self.documentSearchCriteria.texts objectAtIndex:indexPath.row - padding];
                backgroundType = TagCollectionCellBackgroundTypeClear;
                padding = -1;   //found cell text for text
            }
        }
    }
    
    if (padding != -1) {
        padding += [self.documentSearchCriteria.texts count];
        if (indexPath.row - padding < [self.documentSearchCriteria.tags count]) {
            TagObject *tagObj = [self.documentSearchCriteria.tags objectAtIndex:indexPath.row-padding];
            text = tagObj.name;
            backgroundType = TagCollectionCellBackgroundTypeTagOrange;
            //rightText = [NSString stringWithFormat:@"%i",tagObj.docCount];
        }
    }
    
    if (text)
        return [NSArray arrayWithObjects:text,[NSNumber numberWithInt:backgroundType],rightText,nil];
    
    return nil;
}

- (void)updateUI {
    [self.myCollectionView reloadData];
}

- (void)setDocumentSearchCriteria:(DocumentSearchCriteria*)criteria {
    _documentSearchCriteria = criteria;
    [self.myCollectionView reloadData];
    [self.myCollectionView setHeight:[self.myCollectionView.collectionViewLayout collectionViewContentSize].height];
    [self setHeight:[self.myCollectionView bottom] + kDocumentRecentSearchCellMargin];
    [self.arrowImageView setRight:self.myTable.frame.size.width-10 top:self.frame.size.height/2-self.arrowImageView.frame.size.height/2];
}

+ (float)heightForCellWithCriteria:(DocumentSearchCriteria*)criteria reuseId:(NSString*)cellId tableView:(UITableView*)tableview {
    DocumentRecentSearchCell *virtualCell = [[DocumentRecentSearchCell alloc] initWithReuseIdentifier:cellId tableView:tableview];
    [virtualCell setDocumentSearchCriteria:criteria];
    return virtualCell.frame.size.height;
}
@end
