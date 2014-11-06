//
//  MyDetailViewController.m
//  FileThis
//
//  Created by Cuong Le on 12/10/13.
//
//

#import "MyDetailViewController.h"

#define kMyDetailViewController_BarButtonHeight     36.0
#define kMyDetailViewController_BarButtonSmallFont      [CommonLayout getFont:FontSizeXXSmall isBold:NO]

@interface MyDetailViewController ()
//@property (nonatomic, strong) UIPopoverController *popCon;
@property (assign) BOOL isTopBarLocked;
@property (nonatomic, strong) UIView *topBarLockView;
@end

@implementation MyDetailViewController
@synthesize selectedBottomCenterBarButtonIndex;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)initializeScreen {
    [super initializeScreen];
    self.selectedBottomCenterBarButtonIndex = -1;
    
    self.titleLabelMarginLeft = self.titleLabelMarginRight = 0;
    self.view.backgroundColor = kBackgroundLightGrayColor;
    self.leftBarButtons = [[NSMutableArray alloc] init];
    self.rightBarButtons = [[NSMutableArray alloc] init];
    self.bottomLeftBarButtons = [[NSMutableArray alloc] init];
    self.bottomRightBarButtons = [[NSMutableArray alloc] init];
    self.bottomCenterBarButtons = [[NSMutableArray alloc] init];
    
    float topBarHeight = 0, bottomBarHeight = 0;
    topBarHeight = [self heightForTopBar];
    bottomBarHeight = [self heightForBottomBar];
    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, topBarHeight, self.view.frame.size.width, self.view.frame.size.height - topBarHeight - bottomBarHeight)];
    
    [self.view addSubview:self.contentView];
    [self.view sendSubviewToBack:self.contentView];
    [self initTopBar];
    [self initBottomBar];
}

- (void)initializeVariables {
    [super initializeVariables];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    self.topBarView.hidden = [self shouldHideNavigationBar];
    self.bottomBarView.hidden = [self shouldHideToolBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.view bringSubviewToFront:self.topBarView];
    [self.view bringSubviewToFront:self.bottomBarView];
    if (self.loadingView) {
        if (![LoadingView currentLoadingView] || ![LoadingView currentLoadingViewContainer]) {
            [LoadingView setCurrentLoadingView:self.loadingView];
            [LoadingView setCurrentLoadingViewContainer:self.view];
        }
    }
//    [self relayout];
}

- (void)viewWillDisappear:(BOOL)animated {
    if ([LoadingView currentLoadingView] == self.loadingView) {
        [LoadingView setCurrentLoadingView:nil];
        [LoadingView setCurrentLoadingViewContainer:nil];
    }
    [super viewWillDisappear:animated];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated. 
}

//- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
//    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
//    [self relayout];
//}

#pragma mark - Overriden
- (BOOL)shouldUseBackButton {
    return self.useBackButton;
}

- (float)heightForTopBar {
    if ([self shouldHideNavigationBar])
        return 0;
    
    return kIOS7ToolbarHeight;
}

- (float)heightForBottomBar {
    if ([self shouldHideToolBar])
        return 0;
    
    return kIOS7ToolbarHeight;
}

- (BOOL)shouldRelayoutBeforeViewAppear {
    return YES;
}

- (UIFont*)smallFontForBottomBarButton {
    return [CommonLayout getFont:FontSizeXSmall isBold:NO];
}

- (float)horizontalSpacingBetweenTopRightBarButtons {
    return 6.0;
}

- (float)horizontalSpacingBetweenBottomCenterBarButtons {
    return 6.0;
}

- (float)horizontalSpacingBetweenTopLeftBarButtons {
    if(IS_IPHONE)
        return 4;
    
    return 20;
}

- (float)rightMarginTopBarButton {
    return 10;
}

- (UIFont*)fontForBarButton {
    if(IS_IPHONE)
        return [CommonLayout getFont:FontSizeSmall isBold:NO];
    
    return [CommonLayout getFont:FontSizeMedium isBold:NO];
}

- (void)setTitleLabelMarginLeft:(float)titleLabelMarginLeft marginRight:(float)marginRight {
    
}

#pragma mark - Layout
- (void)relayout {
    [super relayout];
    
    float titleLeft = 80;
    float titleRight = self.view.frame.size.width;
    
    float x = self.view.frame.size.width;
    float topBarHeight = 0, bottomBarHeight = 0;
    
    if (self.topBarView) {
        if (!self.topBarView.hidden) {
            topBarHeight = [self heightForTopBar];
            [self.topBarView setWidth:x height:topBarHeight];
            [self.view bringSubviewToFront:self.topBarView];
            
            if ([self shouldUseBackButton])
                x = [self.backButton right];// + [self horizontalSpacingBetweenTopLeftBarButtons];
            else if (self.menuButton.hidden)
                x = 0;
            else
                x = [self.menuButton right];
            
            for (UIView *vw in self.leftBarButtons) {
                x += [self horizontalSpacingBetweenTopLeftBarButtons];
                [vw setLeft:x];
                x = [vw right];
            }
            
            if ([self.leftBarButtons count] > 0)
                titleLeft = [[self.leftBarButtons lastObject] right];
            
            if ([self.rightBarButtons count] > 0)
                titleRight = [[self.rightBarButtons lastObject] left];
        }
    }
    if (self.bottomBarView) {
        if (!self.bottomBarView.hidden) {
            bottomBarHeight = [self heightForBottomBar];
            self.bottomBarView.frame = CGRectMake(0, self.view.frame.size.height - bottomBarHeight, self.view.frame.size.width, bottomBarHeight);
            [self.view bringSubviewToFront:self.bottomBarView];
        }
    }
    
    x = self.view.frame.size.width;
    float right = x - [self rightMarginTopBarButton];
    for (UIButton *button in self.rightBarButtons) {
        [button setRight:right];
        right -= [self horizontalSpacingBetweenTopRightBarButtons] + button.frame.size.width;
    }
    
    x = self.view.frame.size.width;
    for (UIButton *button in self.bottomRightBarButtons) {
        [button setRight:x-10];
        x -= 10 + button.frame.size.width;
    }
    [CommonLayout moveViewsToHorizontalCenterOfSuperView:self.bottomCenterBarButtons];
    
    float spacing = (IS_IPHONE ? 0.0 : 10.0);
    
    if (titleLeft < self.view.frame.size.width - titleRight)
        titleLeft = self.view.frame.size.width - titleRight;
    else
        titleRight = self.view.frame.size.width - titleLeft;
    
    [self.titleLabel setLeft:titleLeft+spacing right:titleRight-spacing];
    
    self.contentView.frame = CGRectMake(0, topBarHeight, self.view.frame.size.width, self.view.frame.size.height - topBarHeight - bottomBarHeight);
    
    if (self.loadingView.superview == self.view)
        self.loadingView.frame = self.contentView.frame;
    
    if (self.isTopBarLocked)
        [self.view bringSubviewToFront:self.topBarLockView];
    
    [self.loadingView.superview bringSubviewToFront:self.loadingView];
}

#pragma mark - MyFunc
- (void)initTopBar {
    BOOL isiPhone = IS_IPHONE;
    self.topBarView = [[BorderView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, [self heightForTopBar]) borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0, 0, 0, 1) superView:self.view];
    self.topBarView.backgroundColor = kTextOrangeColor;
    
    float iconHeight = self.topBarView.frame.size.height - kIOS7CarrierbarHeight - 4;
    
    float x;
    if ([self shouldUseBackButton]) {
        float buttonWidth, iconLeftOffset;
        if (isiPhone) {
            buttonWidth = 30;
            iconLeftOffset = 0;
            iconHeight -= 8;
        } else {
            buttonWidth = 80;
            iconLeftOffset = 10;
        }
        
        UIImage *imgBack;
        NSString *backTitle = nil;
        if (isiPhone) {
            //imgBack = [UIImage imageNamed:@"btn_back.png"];
            imgBack = [UIImage imageNamed:@"back_arrow_white.png"];
        } else {
            imgBack = [UIImage imageNamed:@"back_arrow_white.png"];
            backTitle = NSLocalizedString(@"Back",@"");
        }
        self.backButton = [CommonLayout createTextImageButton:CGRectMake(0, kIOS7CarrierbarHeight + 8, buttonWidth, iconHeight) text:backTitle font:[self fontForBarButton] textColor:kMyDetailViewController_BarTextColor icon:imgBack iconSize:CGSizeMake(iconHeight-4,iconHeight-4) offsetBetweenTextAndIcon:-4 iconLeftOffset:iconLeftOffset backgroundImage:nil touchTarget:self touchSelector:@selector(handleBackButton) superView:self.topBarView];
        x = 0;
    } else {
        self.menuButton = [CommonLayout createImageButton:CGRectMake(0, kIOS7CarrierbarHeight + 2, iconHeight * 0.8, iconHeight) image:[UIImage imageNamed:@"FTiOS_logo.png"] contentMode:UIViewContentModeScaleAspectFit touchTarget:self touchSelector:@selector(menuButtonTouched) superView:self.topBarView];
        x = [self.menuButton right] - 16;
    }
    
    float spacing;
    float y;
    FontSize titleFontSize;
    if (isiPhone) {
        spacing = 0.0;
        titleFontSize = FontSizeSmall;
        y = kIOS7CarrierbarHeight + 10;
    } else {
        spacing = 10.0;
        y = kIOS7CarrierbarHeight;
        titleFontSize = FontSizexLarge;
    }
    
    self.titleLabel = [CommonLayout createLabel:CGRectMake(x + spacing, y, self.view.frame.size.width - x - spacing*2, self.topBarView.frame.size.height - y) fontSize:titleFontSize isBold:YES textColor:kMyDetailViewController_BarTextColor backgroundColor:nil text:@"" superView:self.topBarView];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.titleLabel.minimumScaleFactor = 0.9;
    self.titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    
    if ([self shouldUseBackButton])
        self.backButton.center = CGPointMake(self.backButton.center.x, self.titleLabel.center.y + [self barButtonDeltaY] - 1);
}

- (void)initBottomBar {
    self.bottomBarView = [[BorderView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - [self heightForBottomBar], self.view.frame.size.width, [self heightForBottomBar]) borderColor:kBorderLightGrayColor borderWidths:OffsetMake(0, 0, 1, 0) superView:self.view];
    self.bottomBarView.backgroundColor = kBackgroundOrange;
}

#pragma mark - AddTopLeftBarButton

- (UIButton*)addTopLeftTextBarButton:(NSString*)text width:(float)width target:(id)target selector:(SEL)selector {
    UIView *vw;
    if ([self.leftBarButtons count] > 0)
        vw = [self.leftBarButtons lastObject];
    else if ([self shouldUseBackButton])
        vw = self.backButton;
    else
        vw = self.menuButton;
        
    UIButton *button = [CommonLayout createTextButton:[vw rectAtRight:2 width:width height:kMyDetailViewController_BarButtonHeight] font:[self fontForBarButton] text:text textColor:kMyDetailViewController_BarTextColor touchTarget:target touchSelector:selector superView:self.topBarView];

    button.center = CGPointMake(button.center.x, self.titleLabel.center.y + [self barButtonDeltaY]);
    
    [self.leftBarButtons addObject:button];
    
    return button;
}

- (UIButton*)addTopLeftTextBarButton:(NSString*)text target:(id)target selector:(SEL)selector {
    return [self addTopLeftTextBarButton:text width:[self getWidthOfBarButtonText:text] target:target selector:selector];
}

- (UIButton*)addTopLeftImageBarButton:(UIImage*)image width:(float)width target:(id)target selector:(SEL)selector {
    UIButton *button = [CommonLayout createImageButton:CGRectMake(0, 0, width, kMyDetailViewController_BarButtonHeight) image:image contentMode:UIViewContentModeScaleAspectFit touchTarget:target touchSelector:selector superView:self.topBarView];
    
    if ([self.leftBarButtons count] > 0)
        button.center = CGPointMake([(UIView*)[self.leftBarButtons lastObject] left] - [self horizontalSpacingBetweenTopLeftBarButtons] - width/2, self.titleLabel.center.y + [self barButtonDeltaY]);
    else
        button.center = CGPointMake(self.topBarView.frame.size.width - [self horizontalSpacingBetweenTopLeftBarButtons] - width/2, self.titleLabel.center.y + [self barButtonDeltaY]);
    
    [self.leftBarButtons addObject:button];
    return button;
}

- (void)addTopLeftBarButton:(UIButton*)button {
    [button setHeight:kMyDetailViewController_BarButtonHeight];
    if ([self.leftBarButtons count] > 0)
        button.center = CGPointMake([(UIView*)[self.leftBarButtons lastObject] left] - [self horizontalSpacingBetweenTopLeftBarButtons] - button.frame.size.width/2, self.titleLabel.center.y + [self barButtonDeltaY]);
    else
        button.center = CGPointMake(self.topBarView.frame.size.width - [self horizontalSpacingBetweenTopLeftBarButtons] - button.frame.size.width/2, self.titleLabel.center.y + [self barButtonDeltaY]);
    
    [self.topBarView addSubview:button];
    [self.leftBarButtons addObject:button];
}

#pragma mark - AddTopRightBarButton
- (UIButton*)addTopRightBarButton:(NSString*)text width:(float)width target:(id)target selector:(SEL)selector {
    UIButton *button = [CommonLayout createTextButton:CGRectMake(0, 0, width, kMyDetailViewController_BarButtonHeight) fontSize:FontSizeSmall isBold:NO text:text textColor:kMyDetailViewController_BarTextColor touchTarget:target touchSelector:selector superView:self.topBarView];
    if ([self.rightBarButtons count] > 0)
        button.center = CGPointMake([(UIView*)[self.rightBarButtons lastObject] left] - [self horizontalSpacingBetweenTopRightBarButtons] - width/2, self.titleLabel.center.y + [self barButtonDeltaY]);
    else
        button.center = CGPointMake(self.topBarView.frame.size.width - [self horizontalSpacingBetweenTopRightBarButtons] - width/2, self.titleLabel.center.y + [self barButtonDeltaY]);
    
    [self.rightBarButtons addObject:button];
    return button;
}

- (UIButton*)addTopRightBarButton:(NSString*)text target:(id)target selector:(SEL)selector {
    return [self addTopRightBarButton:text width:[self getWidthOfBarButtonText:text] target:target selector:selector];
}

- (UIButton*)addTopRightImageBarButton:(UIImage*)image width:(float)width target:(id)target selector:(SEL)selector {
    UIButton *button = [CommonLayout createImageButton:CGRectMake(0, 0, width, kMyDetailViewController_BarButtonHeight) image:image contentMode:UIViewContentModeScaleAspectFit touchTarget:target touchSelector:selector superView:self.topBarView];
    
    if ([self.rightBarButtons count] > 0)
        button.center = CGPointMake([(UIView*)[self.rightBarButtons lastObject] left] - [self horizontalSpacingBetweenTopRightBarButtons] - width/2, self.titleLabel.center.y + [self barButtonDeltaY]);
    else
        button.center = CGPointMake(self.topBarView.frame.size.width - [self horizontalSpacingBetweenTopRightBarButtons] - width/2, self.titleLabel.center.y + [self barButtonDeltaY]);
    
    [self.rightBarButtons addObject:button];
    return button;
}

- (UIButton*)addTopRightImageBarButton:(UIImage*)image target:(id)target selector:(SEL)selector {
    float width = image.size.width / image.size.height * kMyDetailViewController_BarButtonHeight;
    return [self addTopRightImageBarButton:image width:width target:target selector:selector];
}

#pragma mark - AddBottomLeftBarButton
- (UIButton*)addBottomLeftBarButton:(NSString*)text width:(float)width target:(id)target selector:(SEL)selector {
    float x;
    if ([self.bottomLeftBarButtons count] > 0)
        x = [(UIView*)[self.bottomLeftBarButtons lastObject] right];
    else
        x =  0;
    
    UIButton *button = [CommonLayout createTextButton:CGRectMake(x+6, 0, width, self.bottomBarView.frame.size.height) fontSize:FontSizeSmall isBold:NO text:text textColor:kMyDetailViewController_BarTextColor touchTarget:target touchSelector:selector superView:self.bottomBarView];
    [self.bottomLeftBarButtons addObject:button];
    return button;
}

- (UIButton *)addBottomLeftBarButton:(NSString *)text image:(UIImage *)image target:(id)target selector:(SEL)selector {
    float x;
    if ([self.bottomLeftBarButtons count] > 0)
        x = [(UIView*)[self.bottomLeftBarButtons lastObject] right];
    else
        x =  10;
    
    UIButton *button = [self createBottomButtonAtX:x text:text image:image target:target selector:selector];
    [self.bottomLeftBarButtons addObject:button];
    return button;
}

#pragma mark - AddBottomRightBarButton
- (UIButton*)addBottomRightBarButton:(NSString*)text width:(float)width target:(id)target selector:(SEL)selector {
    float x;
    if ([self.bottomRightBarButtons count] > 0)
        x = [(UIView*)[self.bottomRightBarButtons lastObject] left];
    else
        x = self.bottomBarView.frame.size.width;
    
    UIButton *button = [CommonLayout createTextButton:CGRectMake(x -  6 - width, 0, width, self.bottomBarView.frame.size.height) fontSize:FontSizeSmall isBold:NO text:text textColor:kMyDetailViewController_BarTextColor touchTarget:target touchSelector:selector superView:self.bottomBarView];
    [self.bottomRightBarButtons addObject:button];
    return button;
}

#pragma mark - AddBottomCenterBarButton
- (UIButton*)addBottomCenterBarButton:(NSString*)text image:(UIImage*)image target:(id)target selector:(SEL)selector {
    UIButton *button = [self addBottomCenterBarButton:text image:image target:target selector:selector width:0];
    return button;
}

- (UIButton*)addBottomCenterBarButton:(NSString*)text image:(UIImage*)image target:(id)target selector:(SEL)selector width:(float)width {
    float x;
    if ([self.bottomCenterBarButtons count] > 0)
        x = [(UIView*)[self.bottomCenterBarButtons lastObject] right];
    else
        x =  0;
    
    UIButton *button = [self createBottomButtonAtX:x text:text image:image target:target selector:selector width:width];
    [self.bottomCenterBarButtons addObject:button];
    [CommonLayout moveViewsToHorizontalCenterOfSuperView:self.bottomCenterBarButtons];
    return button;
}

- (UIButton*)createBottomButtonAtX:(float)x text:(NSString*)text image:(UIImage*)image target:(id)target selector:(SEL)selector {
    UIButton *button = [self createBottomButtonAtX:x text:text image:image target:target selector:selector width:0];
    return button;
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (UIButton*)createBottomButtonAtX:(float)x text:(NSString*)text image:(UIImage*)image target:(id)target selector:(SEL)selector width:(float)width {
    
    if (width == 0) { //auto calculate width
        width = roundf([text sizeWithFont:[self smallFontForBottomBarButton] constrainedToSize:CGSizeMake(200, 1000)].width);
    }
    
    float height = floorf([self heightForBottomBar] * 0.95);
    float top = floorf([self heightForBottomBar] * 0.02);
    float iconWidth = roundf([self heightForBottomBar] * 0.5);
    if (width < iconWidth) width = iconWidth;
    
    UIButton *button;
    if ([text length] == 0) {
        width = roundf([self heightForBottomBar] * 0.9);
        button = [CommonLayout createImageButton:CGRectMake(x + [self horizontalSpacingBetweenBottomCenterBarButtons], top, width, height) image:image contentMode:UIViewContentModeScaleAspectFit touchTarget:target touchSelector:selector superView:self.bottomBarView];
    } else
        button = [CommonLayout createVerticalTextImageButton:CGRectMake(x + [self horizontalSpacingBetweenBottomCenterBarButtons], top, width, height) text:text font:[self smallFontForBottomBarButton] textColor:kMyDetailViewController_BarTextColor icon:image iconSize:CGSizeMake(width, iconWidth) offsetBetweenTextAndIcon:0.0 backgroundImage:nil touchTarget:target touchSelector:selector superView:self.bottomBarView];
    
    return button;
}
#pragma GCC diagnostic pop

#pragma mark - SetHighlightBottomCenterBarButton
- (void)setSelectedBottomCenterBarButton:(UIButton*)aButton {
    _selectedBottomCenterBarButton = aButton;
    aButton.alpha = 0.5;
    aButton.userInteractionEnabled = NO;
    for (UIButton *button in self.bottomCenterBarButtons) {
        if (button != aButton) {
            button.alpha = 1.0;
            button.userInteractionEnabled = YES;
        }
    }
}

- (void)setSelectedBottomCenterBarButtonIndex:(int)aButtonIndex {
    selectedBottomCenterBarButtonIndex = aButtonIndex;
    if (aButtonIndex >= 0 && aButtonIndex < [self.bottomCenterBarButtons count]) {
        [self setSelectedBottomCenterBarButton:[self.bottomCenterBarButtons objectAtIndex:aButtonIndex]];
    }
}

#pragma mark - Button

- (void)menuButtonTouched {
    if ([self.myDetailViewControllerDelegate respondsToSelector:@selector(menu_ShouldOpen:)]) {
        self.menuButton.hidden = YES;
        [self.myDetailViewControllerDelegate menu_ShouldOpen:self];
    }
}

- (void)handleBackButton {
    [self stopAllTaskBeforeQuit];
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
- (float)getWidthOfBarButtonText:(NSString*)text {
    float width = [text sizeWithFont:[self fontForBarButton] constrainedToSize:CGSizeMake(300, 1000)].width + 8;
    return width;
}
#pragma GCC diagnostic pop

- (float)barButtonDeltaY { //compare to titleLabel 
    return (IS_IPHONE ? -1.0 : 2.0);
}

- (BOOL)shouldHideNavigationBar {
    return NO;
}

- (BOOL)shouldHideToolBar {
    return YES;
}

- (void)setTopBarLocked:(BOOL)locked {
    if ((self.isTopBarLocked = locked)) {
        self.topBarLockView = [[UIView alloc] initWithFrame:self.topBarView.frame];
        self.topBarLockView.layer.opacity = 0.5;
        self.topBarLockView.backgroundColor = [UIColor blackColor];
        [self.view addSubview:self.topBarLockView];
    } else {
        [self.topBarLockView removeFromSuperview];
        self.topBarLockView = nil;
    }
}

@end
