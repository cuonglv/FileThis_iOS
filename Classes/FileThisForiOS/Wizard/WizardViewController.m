//
//  WizardViewController.m
//  FileThis
//
//  Created by Cuong Le on 3/8/14.
//
//

#import "WizardViewController.h"
#import "CommonLayout.h"
#import "CommonVar.h"
#import "Constants.h"

#define WIZARD_IMAGES   (IS_IPHONE ? [NSArray arrayWithObjects:@"wizard_iphone_menu.png", @"wizard_iphone_documents.png", @"wizard_iphone_search.png", @"wizard_iphone_tagging.png", @"wizard_iphone_document_cabinet.png", nil] : [NSArray arrayWithObjects:@"wizard_ipad_menu.png", @"wizard_ipad_documents.png", @"wizard_ipad_search.png", @"wizard_ipad_tagging.png", nil])
#define WIZARD_GOT_IT_BUTTON_TOPS   (IS_IPHONE ? [NSArray arrayWithObjects:@"0.89", @"0.4", @"0.42", @"0.87", @"0.87", nil] : [NSArray arrayWithObjects:@"0.6", @"0.7", @"0.8", @"0.25", nil])
#define GOT_IT_BUTTON_WIDTH     (IS_IPHONE ? 100 : 160)
#define GOT_IT_BUTTON_HEIGHT    (IS_IPHONE ? 36 : 54)

@interface WizardViewController ()
@property (nonatomic, strong) UIImageView *imageView;
@end

@implementation WizardViewController

- (id)initWithWizardIndex:(int)wizardIndex initialViewControllerBeforeWizard:(UIViewController*)initialViewControllerBeforeWizard {
    if (self = [super initWithNibName:nil bundle:nil]) {
        self.wizardIndex = wizardIndex;
        self.initialViewControllerBeforeWizard = initialViewControllerBeforeWizard;
        self.imageView = [CommonLayout createImageView:self.view.bounds image:[UIImage imageNamed:[WIZARD_IMAGES objectAtIndex:wizardIndex]] contentMode:UIViewContentModeScaleAspectFit superView:self.view];
        self.gotItButton = [CommonLayout createImageButton:CGRectMake(self.view.frame.size.width / 2 - GOT_IT_BUTTON_WIDTH / 2, [[WIZARD_GOT_IT_BUTTON_TOPS objectAtIndex:wizardIndex] floatValue] * self.view.frame.size.height, GOT_IT_BUTTON_WIDTH, GOT_IT_BUTTON_HEIGHT) image:[UIImage imageNamed:@"got_it_button.png"] contentMode:UIViewContentModeScaleAspectFit touchTarget:self touchSelector:@selector(handleGotItButton) superView:self.view];
        ;
    }
    return self;
}

- (void)relayout {
    [super relayout];
    self.imageView.frame = self.view.bounds;
    [self.gotItButton setTop:[[WIZARD_GOT_IT_BUTTON_TOPS objectAtIndex:self.wizardIndex] floatValue] * self.view.frame.size.height];
    [self.gotItButton moveToHorizontalCenterOfSuperView];
}

- (void)handleGotItButton {
    if (self.wizardIndex < [WIZARD_IMAGES count] - 1) { //go next
        WizardViewController *vc = [[WizardViewController alloc] initWithWizardIndex:self.wizardIndex + 1 initialViewControllerBeforeWizard:self.initialViewControllerBeforeWizard];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        [CommonVar setLockedOrientation:NO];
        [self.navigationController popToViewController:self.initialViewControllerBeforeWizard animated:YES];
    }
}
@end
