//
//  ServerPickerViewController.m
//  FileThis
//
//  Created by Drew Wilson on 5/14/13.
//
//

#import "FTSession.h"
#import <Crashlytics/Crashlytics.h>
#import "ServerPickerViewController.h"
#import "CommonLayout.h"
#import "CacheManager.h"

@interface ServerPickerViewController () <UIPickerViewDataSource,UIPickerViewDelegate, UIAlertViewDelegate>
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIPickerView *picker;
@end

@implementation ServerPickerViewController

+ (NSArray *)configurations {
    static NSArray *configurations;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSDictionary *infoPlist = [[NSBundle mainBundle] infoDictionary];
        configurations = [infoPlist objectForKey:@"HOST_NAMES"];
    });
    return configurations;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"ServerPickerViewController viewWillAppear:");
    [super viewWillAppear:animated];
    self.picker.center = CGPointMake(self.view.frame.size.width/2, self.view.frame.size.height/2);
    [self.titleLabel moveToTopOfView:self.picker offset:10];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"ServerPickerViewController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGRect frame = self.view.frame;
    frame.size.height = 80;
    self.titleLabel = [[UILabel alloc] initWithFrame:frame];
    self.titleLabel.text = [NSString stringWithFormat:@"Change server from %@ to ", [FTSession hostName]];
    self.titleLabel.font = [UIFont boldSystemFontOfSize:14.0];
    self.titleLabel.numberOfLines = 0;
    [self.view addSubview:self.titleLabel];

    frame.size.height = 200;
    frame.origin.y += 80;
    self.picker = [[UIPickerView alloc] initWithFrame:frame];
    self.picker.delegate = self;
    self.picker.showsSelectionIndicator = YES;
    NSInteger currentSelection = [[[self class] configurations] indexOfObject:[FTSession hostName]];
    [self.picker selectRow:currentSelection inComponent:0 animated:NO];
    [self.view addSubview:self.picker];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UIPickerViewDataSource methods
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [[[self class] configurations] count];
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [[[self class] configurations] objectAtIndex:row];
}

#pragma mark UIPickerViewDelegate methods

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *hostName = [[[self class] configurations] objectAtIndex:row];
    [FTSession setHostName:hostName];
    [[CacheManager getInstance] setServerUrl:[NSString stringWithFormat:@"https://%@/ftapi/ftapi?",hostName]];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
