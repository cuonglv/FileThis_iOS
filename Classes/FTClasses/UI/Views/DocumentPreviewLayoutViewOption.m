//
//  DocumentPreviewLayoutViewOption.m
//  FileThis
//
//  Created by Manh nguyen on 1/16/14.
//
//

#import "DocumentPreviewLayoutViewOption.h"

#define HEIGHT_FOR_ROW  30
#define PADDING 10

@implementation DocumentPreviewLayoutViewOption

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.selectedLayout = PageViewLayoutSinglePage;
        self.backgroundColor = [UIColor whiteColor];
        self.clipsToBounds = YES;
        
        // Initialization code
        UILabel *sortLabel = [[UILabel alloc] initWithFrame:CGRectMake(PADDING, PADDING, frame.size.width, 30)];
        [self addSubview:sortLabel];
        [sortLabel setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeSmall] textColor:kGrayColor backgroundColor:nil text:NSLocalizedString(@"ID_DOCUMENT_VIEW_OPTIONS", @"") numberOfLines:1 textAlignment:NSTextAlignmentLeft];
        
        self.tbView = [[UITableView alloc] initWithFrame:CGRectMake(0, [sortLabel bottom], frame.size.width, frame.size.height - sortLabel.frame.size.height - PADDING)];
        self.tbView.delegate = self;
        self.tbView.dataSource = self;
        [self addSubview:self.tbView];
        [self.tbView setSeparatorColor:kWhiteLightGrayColor];
        [self.tbView setTintColor:kCabColorAll];
        self.tbView.allowsMultipleSelection = NO;
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

- (void)initializeView {
    [super initializeView];
    self.layouts = [[NSMutableArray alloc] initWithArray:[NSArray arrayWithObjects:NSLocalizedString(@"ID_SINGLE_PAGE", @""), NSLocalizedString(@"ID_DOUBLE_PAGES", @""), NSLocalizedString(@"ID_THUMBS", @""), nil]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.layouts count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedLayout = indexPath.row;
    if ([self.delegate respondsToSelector:@selector(didSelectPageLayout:pageViewLayout:)]) {
        [self.delegate didSelectPageLayout:self pageViewLayout:self.selectedLayout];
    }
    
    [self.tbView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
            return 0;
    }
    return HEIGHT_FOR_ROW;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    static NSString *cellFollowingIdentifier = @"SortCell";
	cell = [self.tbView dequeueReusableCellWithIdentifier:cellFollowingIdentifier];
    
    NSString *layout = [self.layouts objectAtIndex:indexPath.row];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellFollowingIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
    
    if (indexPath.row == self.selectedLayout) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        UIImage *img;
        if (indexPath.row == PageViewLayoutSinglePage) {
            img = [UIImage imageNamed:@"icon_single_view.png"];
        } else if (indexPath.row == PageViewLayoutThumbPage) {
            img = [UIImage imageNamed:@"icon_thumb_view.png"];
        }
        cell.imageView.image = img;
    }
    
    [cell.textLabel setText:layout];
    [cell.textLabel setTextColor:kCabColorAll];
    [cell.textLabel setFont:[UIFont fontWithName:@"Merriweather" size:kFontSizeSmall]];
	return cell;
}

@end
