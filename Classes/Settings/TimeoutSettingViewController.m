//
//  TimeoutSettingViewController.m
//  FileThis
//
//  Created by Drew Wilson on 1/7/13.
//
//

#import "TimeoutSettingViewController.h"

@interface TimeoutSettingViewController () <UITableViewDelegate,UITableViewDataSource>

@property NSInteger checkedRow;

@end

@implementation TimeoutSettingViewController

+ (NSArray *)timeouts {
    NSArray *_timeouts = nil;
    if (_timeouts == nil) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"Timeouts" ofType:@"plist"];
        _timeouts = [NSArray arrayWithContentsOfFile:path];
    }
    return _timeouts;
}

+ (NSDictionary *)timeoutTitles {
    static NSDictionary *_titles = nil;
    if (_titles == nil)
    {
        NSMutableDictionary *d = [NSMutableDictionary dictionaryWithCapacity:[[self timeouts] count]];
        for (NSDictionary *timeout in [self timeouts]) {
            d[timeout[@"minutes"]] = timeout;
        }
        _titles = [NSDictionary dictionaryWithDictionary:d];
    }
    return _titles;
}

+ (NSString *)titleForTimeout:(NSInteger)timeoutInMinutes
{
    NSNumber *key = [NSNumber numberWithInteger:timeoutInMinutes];
    return [self timeoutTitles][key][@"title"];
}

+ (NSString *)titleForIndex:(NSInteger)index
{
    return [self timeouts][index][@"title"];
}

+ (NSInteger)timeoutForIndex:(NSInteger)index
{
    return [[self timeouts][index][@"minutes"] integerValue];
}

+ (NSInteger)indexForTimeout:(NSInteger)timeout
{
     __block NSInteger index = NSNotFound;
    [[self timeouts] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if ([obj[@"minutes"] integerValue] == timeout) {
            index = idx;
            *stop = YES;
        }
    }];
    return index;
}

/*
 
 The list of timeout values is stored as static tableview cells, where
 each cell has a tag value indicating the timeout value in minutes.
 Unfortunately, a tag value cannot be 0, so we use -1 to represent no
 timeout, or never.
 
 */

-(void)viewWillAppear:(BOOL)animated
{
    // check cell for current timeout
    self.checkedRow = [[self class] indexForTimeout:self.settings.logoutAfterMinutes];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.checkedRow inSection:0];
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    [super viewWillAppear:animated];
}

- (void)updateCheckmark:(UITableView *)tableView withIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *previousIndex = [NSIndexPath indexPathForRow:self.checkedRow inSection:0];
    UITableViewCell *previousCell = [self.tableView cellForRowAtIndexPath:previousIndex];
    
    self.checkedRow = indexPath.row;
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    int timeout = [[self class] timeoutForIndex:self.checkedRow];
    self.settings.logoutAfterMinutes = timeout;

    [UIView animateWithDuration:1.0 animations:^{
        previousCell.accessoryType = UITableViewCellAccessoryNone;
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self class] timeouts] count];
}

// Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
// Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"timeoutCell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"timeoutCell"];
    }
    cell.textLabel.text = [[self class] titleForIndex:indexPath.row ];
    if (indexPath.row == self.checkedRow)
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    else
        cell.accessoryType = UITableViewCellAccessoryNone;
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self updateCheckmark:tableView withIndexPath:indexPath];
    return NO;
}

- (NSString *)humanFormForTimeoutInMinutes:(NSInteger)timeoutInMinutes
{
    int minutes = timeoutInMinutes % 60;
    int hours = timeoutInMinutes / 60 % 24;
    int days = timeoutInMinutes / (60*24);
    
    int value = -1;
    NSString *label;
    if (minutes) {
        value = minutes;
        label = value == 1 ? NSLocalizedString(@"Minute", @"minute label") :
        NSLocalizedString(@"Minutes", @"minutes label");
    }
    else if (hours)
    {
        value = hours;
        label = value == 1 ? NSLocalizedString(@"Hour", @"hour label") : NSLocalizedString(@"Hours", @"hours label");
    }
    else if (days)
    {
        value = days;
        label = value == 1 ? NSLocalizedString(@"Day", @"day label") : NSLocalizedString(@"Days", @"days label");
    }
    
    return [NSString stringWithFormat:@"%d %@", value, label];
}

@end
