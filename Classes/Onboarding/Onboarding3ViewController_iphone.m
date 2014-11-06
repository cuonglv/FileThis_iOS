//
//  Onboarding3ViewController_iphone.m
//  FileThis
//
//  Created by Cao Huu Loc on 2/19/14.
//
//

#import "Onboarding3ViewController_iphone.h"

@interface Onboarding3ViewController_iphone ()

@end

@implementation Onboarding3ViewController_iphone

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        NSString *s = [[NSString alloc] initWithFormat:@"%@ %@", NSLocalizedString(@"ID_ONBOARD3_TEXT1", @""), NSLocalizedString(@"ID_ONBOARD3_TEXT2", @"")];
        self.lblBanner.text = s;
        self.imgvwContent.image = [UIImage imageNamed:@"Onboarding_phone_logo_3.png"];
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
