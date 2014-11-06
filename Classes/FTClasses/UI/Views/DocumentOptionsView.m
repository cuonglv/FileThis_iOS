//
//  DocumentOptionsView.m
//  FileThis
//
//  Created by Manh nguyen on 1/10/14.
//
//

#import "DocumentOptionsView.h"
#import "SortCriteriaObject.h"
#import "CommonVar.h"
#import "UIImage+UISegmentIconAndText.h"

#define HEIGHT_FOR_ROW  30
#define PADDING 10

@implementation DocumentOptionsView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        UILabel *sortLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, frame.size.width, 30)];
        [self addSubview:sortLabel];
        [sortLabel setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeSmall] textColor:kGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_SORT_BY", @"") numberOfLines:1 textAlignment:NSTextAlignmentLeft];
        
        self.segmentControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:NSLocalizedString(@"ID_THUMBS", @""), NSLocalizedString(@"ID_SNIPPETS", @""), nil]];
        //[self.segmentControl setImage:[UIImage imageNamed:@"thumb_icon"] forSegmentAtIndex:0];
        //[self.segmentControl setImage:[UIImage imageNamed:@"snippet_icon"] forSegmentAtIndex:1];
        UIImage *img1 = [UIImage imageFromImage:[UIImage imageNamed:@"thumb_icon"] string:NSLocalizedString(@"ID_THUMBS", @"") color:kGrayColor];
        UIImage *img2 = [UIImage imageFromImage:[UIImage imageNamed:@"snippet_icon"] string:NSLocalizedString(@"ID_SNIPPETS", @"") color:kGrayColor];
        [self.segmentControl setImage:img1 forSegmentAtIndex:0];
        [self.segmentControl setImage:img2 forSegmentAtIndex:1];
        
        [self addSubview:self.segmentControl];
        [self.segmentControl setFrame:CGRectMake(PADDING, frame.size.height - 40, frame.size.width - 20, 30)];
        [self.segmentControl setTintColor:kCabColorAll];
        [self.segmentControl setSelectedSegmentIndex:1];
        [self.segmentControl addTarget:self action:@selector(handleSegmentSelectedChanged:) forControlEvents:UIControlEventValueChanged];
        
        UILabel *viewLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, [self.segmentControl top] - 30, frame.size.width, 30)];
        [self addSubview:viewLabel];
        [viewLabel setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeSmall] textColor:kGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_VIEW_OPTIONS_SEG", @"") numberOfLines:1 textAlignment:NSTextAlignmentLeft];
        
        self.tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, [sortLabel bottom], frame.size.width, frame.size.height - sortLabel.frame.size.height - self.segmentControl.frame.size.height - viewLabel.frame.size.height - 10)];
        self.tbView.delegate = self;
        self.tbView.dataSource = self;
        [self addSubview:self.tbView];
        [self.tbView setSeparatorColor:kWhiteLightGrayColor];
        [self.tbView setTintColor:kCabColorAll];
        self.tbView.allowsMultipleSelection = NO;
        
        self.backgroundColor = [UIColor whiteColor];
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

- (void)handleSegmentSelectedChanged:(id)sender {
    int selectedIndex = self.segmentControl.selectedSegmentIndex;
    if (selectedIndex == 0) {
        if ([self.delegate respondsToSelector:@selector(didSelectThumbsLayout:)]) {
            [self.delegate didSelectThumbsLayout:self];
        }
    } else {
        if ([self.delegate respondsToSelector:@selector(didSelectSnippetsLayout:)]) {
            [self.delegate didSelectSnippetsLayout:self];
        }
    }
}

- (void)initializeView {
    [super initializeView];
    
    self.selectedSortBy = [CommonVar getSortDocumentBy];
    self.sortCriterias = [[NSMutableArray alloc] init];
    
    SortCriteriaObject *sortByNameAZ = [[SortCriteriaObject alloc] initWithSortBy:Name_A_Z];
    [self.sortCriterias addObject:sortByNameAZ];
    
    SortCriteriaObject *sortByNameZA = [[SortCriteriaObject alloc] initWithSortBy:Name_Z_A];
    [self.sortCriterias addObject:sortByNameZA];
    
    SortCriteriaObject *sortByRelevantDate_NewestFirst = [[SortCriteriaObject alloc] initWithSortBy:RelevantDate_NewestFirst];
    [self.sortCriterias addObject:sortByRelevantDate_NewestFirst];
    
    SortCriteriaObject *sortByRelevantDate_OldestFirst = [[SortCriteriaObject alloc] initWithSortBy:RelevantDate_OldestFirst];
    [self.sortCriterias addObject:sortByRelevantDate_OldestFirst];
    
    SortCriteriaObject *sortByDateCreated_NewestFirst = [[SortCriteriaObject alloc] initWithSortBy:DateCreated_NewestFirst];
    [self.sortCriterias addObject:sortByDateCreated_NewestFirst];
    
    SortCriteriaObject *sortByDateCreated_OldestFirst = [[SortCriteriaObject alloc] initWithSortBy:DateCreated_OldestFirst];
    [self.sortCriterias addObject:sortByDateCreated_OldestFirst];
    
    SortCriteriaObject *sortByDateAdded_NewestFirst = [[SortCriteriaObject alloc] initWithSortBy:DateAdded_NewestFirst];
    [self.sortCriterias addObject:sortByDateAdded_NewestFirst];
    
    SortCriteriaObject *sortByDateAdded_OldestFirst = [[SortCriteriaObject alloc] initWithSortBy:DateAdded_OldestFirst];
    [self.sortCriterias addObject:sortByDateAdded_OldestFirst];
}

- (void)setSelectedSortBy:(SORTBY)selectedSortBy {
    if (_selectedSortBy == selectedSortBy) return;
    
    _selectedSortBy = selectedSortBy;
    [self.tbView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.sortCriterias count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedSortBy = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(didSelectSortBy:)]) {
        [self.delegate didSelectSortBy:self.selectedSortBy];
    }
    
    [self.tbView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return HEIGHT_FOR_ROW;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *cellFollowingIdentifier = @"SortCell";
	cell = [self.tbView dequeueReusableCellWithIdentifier:cellFollowingIdentifier];
    
    SortCriteriaObject *sortCriteriaObj = [self.sortCriterias objectAtIndex:indexPath.row];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFollowingIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    if (indexPath.row == self.selectedSortBy) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    [cell.textLabel setText:sortCriteriaObj.sortName];
    [cell.textLabel setTextColor:kCabColorAll];
    [cell.textLabel setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeSmall]];
	return cell;
}

@end
