//
//  DocumentSearchViewController_iPhone.m
//  FileThis
//
//  Created by Cuong Le on 3/6/14.
//
//

#import "DocumentSearchViewController_iPhone.h"

@interface DocumentSearchViewController_iPhone ()
@property (nonatomic, strong) NSArray *bottomButtons, *componentViews;
@end

@implementation DocumentSearchViewController_iPhone

- (void)initializeScreen {
    [super initializeScreen];
    self.searchTextField.leftView = [CommonLayout createImageView:CGRectMake(0, 5, 25, 28) image:[UIImage imageNamed:@"search_icon_small.png"] contentMode:UIViewContentModeScaleAspectFit superView:nil];
    self.searchTextField.font = [CommonLayout getFont:FontSizexXSmall isBold:NO];
    
    self.dateButton = [self addBottomCenterBarButton:NSLocalizedString(@"ID_SEARCH_BY_DATE", @"") image:[UIImage imageNamed:@"date_icon_white.png"] target:self selector:@selector(handleBottomButton:)];
    self.cabinetButton = [self addBottomCenterBarButton:NSLocalizedString(@"ID_BY_CABINET", @"") image:[UIImage imageNamed:@"cab_white_icon.png"] target:self selector:@selector(handleBottomButton:)];
    self.tagButton = [self addBottomCenterBarButton:NSLocalizedString(@"ID_WITH_TAGS", @"") image:[UIImage imageNamed:@"tags_white_icon.png"] target:self selector:@selector(handleBottomButton:)];
    
    [self.contentView addSubview:self.searchByDateView];
    self.searchByDateView.backgroundColor = [UIColor whiteColor];
    self.searchByDateView.hidden = YES;
    
    [self.contentView addSubview:self.searchCabinetAccountView];
    self.searchCabinetAccountView.backgroundColor = [UIColor whiteColor];
    self.searchCabinetAccountView.hidden = YES;
    
    [self.contentView addSubview:self.searchTagsView];
    self.searchTagsView.backgroundColor = [UIColor whiteColor];
    self.searchTagsView.hidden = YES;
    
    self.bottomButtons = @[ self.dateButton, self.cabinetButton, self.tagButton ];
    self.componentViews = @[ self.searchByDateView, self.searchCabinetAccountView, self.searchTagsView ];
}

- (BOOL)shouldHideToolBar {
    return NO;
}

- (UIFont*)smallFontForBottomBarButton {
    return [CommonLayout getFont:FontSizeXSmall isBold:NO];
}

- (UIFont *)fontForBarButton {
    return [CommonLayout getFont:FontSizeXSmall isBold:NO];
}

- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    return 26.0;
}

- (void)relayout {
    [super relayout];
    float searchTextFieldCenterY = [self heightForTopBar] / 2 + kIOS7CarrierbarHeight / 2 + 2;
    float searchTextFieldCenterX = [self.backButton right] + 8;
    
    self.searchTextField.frame = CGRectMake(searchTextFieldCenterX, searchTextFieldCenterY - 14, self.view.frame.size.width - 16 - searchTextFieldCenterX, 28);
    
    self.leftPanelView.hidden = YES;
    self.documentRecentSearchView.frame = self.searchCriteriaView.frame = self.contentView.bounds;
}

#pragma mark - Override

#pragma mark - Button
- (void)handleBottomButton:(id)sender {
    int index = [self.bottomButtons indexOfObject:sender];
    UIView *selectedComponentView = [self.componentViews objectAtIndex:index];

    if (selectedComponentView.hidden) {
        selectedComponentView.hidden = NO;
        [UIView animateWithDuration:0.3 animations:^{
            [selectedComponentView.superview bringSubviewToFront:selectedComponentView];
            selectedComponentView.frame = self.contentView.bounds;
            self.selectedBottomCenterBarButton = sender;
        } completion:^(BOOL finished) {
            for (UIView *componentView in self.componentViews) {
                if (componentView != selectedComponentView) {
                    [self hideControl:componentView];
                }
            }
        }];
    }
}

#pragma mark - SearchComponentViewDelegate
- (void)searchComponentView_shouldClose:(id)sender {
    [self hideControlWithAnimation:sender];
}

#pragma mark - MyFunc
- (void)hideControlWithAnimation:(UIView*)control {
    if (!control.hidden) {
        [UIView animateWithDuration:0.3 animations:^{
            [control setTop:self.contentView.frame.size.height - 10];
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.1 animations:^{
                [self hideControl:control];
                self.selectedBottomCenterBarButton = nil;
            }];
        }];
    }
}

- (void)hideControl:(UIView*)control {
    [control setTop:self.contentView.frame.size.height];
    control.hidden = YES;
}

@end
