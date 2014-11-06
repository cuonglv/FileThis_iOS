//
//  Onboarding1ViewController_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/19/14.
//
//

#import "Onboarding1ViewController_iphone.h"

@interface Onboarding1ViewController_iphone ()

@end

@implementation Onboarding1ViewController_iphone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString *s = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"ID_ONBOARD1_TEXT1", @""), NSLocalizedString(@"ID_ONBOARD1_TEXT2", @"")];
        self.lblBanner.text = s;
        self.imgvwContent.image = [UIImage imageNamed:@"Onboarding_phone_logo_1.png"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
