//
// Copyright 2011-2012 Kosher Penguin LLC
// Created by Adar Porat (https://github.com/aporat) on 1/16/2012.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//		http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "KKPasscodeViewController.h"
#import "KKKeychain.h"
#import "KKPasscodeSettingsViewController.h"
#import "KKPasscodeLock.h"
#import "Constants.h"

#import <QuartzCore/QuartzCore.h>
#import <AudioToolbox/AudioToolbox.h>

@interface KKPasscodeViewController ()

@property(nonatomic,assign) BOOL isSmallLandscape;
@property(nonatomic,strong) UIView *dimView;

@end

@interface KKPasscodeViewController (Private)

- (UITextField*)passcodeTextField;
- (NSArray*)boxes;
- (UIView*)headerViewForTextField:(UITextField*)textField;
- (void)moveToNextTableView;
- (void)moveToPreviousTableView;
- (void)incrementFailedAttemptsLabel;

@end


@implementation KKPasscodeViewController

@synthesize delegate = _delegate;
@synthesize mode = _mode;
@synthesize isSmallLandscape;

#pragma mark -
#pragma mark UIViewController

- (id)init
{
    if (self = [super init]) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        _hideToolbar = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        _hideToolbar = NO;
    }
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil hideToolbar:(BOOL)hideToolbar
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        _hideToolbar = hideToolbar;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        self.modalPresentationStyle = UIModalPresentationFormSheet;
        _hideToolbar = NO;
    }
    return self;
}

- (void)loadView
{
	[super loadView];
	
	self.view.backgroundColor = [UIColor whiteColor];
    
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) //Cuong
        self.automaticallyAdjustsScrollViewInsets = NO;
    
    CGRect tableViewFrame = self.view.bounds;
//    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPad && [[UIScreen mainScreen] bounds].size.height > 480) {
//        // is running on device with 4" screen so add background tableView
////        UITableView *backgroundTableView = [[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
////        [self.view addSubview:backgroundTableView];
//        
//        //and move other tableViews down so boxes are vertically centered
//        tableViewFrame.origin.y += 44.0;
//    }
	
	_enterPasscodeTableView = [[UITableView alloc] initWithFrame:tableViewFrame]; //[[UITableView alloc] initWithFrame:tableViewFrame style:UITableViewStyleGrouped];
	_enterPasscodeTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_enterPasscodeTableView.delegate = self;
	_enterPasscodeTableView.dataSource = self;
	_enterPasscodeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_enterPasscodeTableView.backgroundColor = [UIColor whiteColor]; //[UIColor groupTableViewBackgroundColor];
	[self.view addSubview:_enterPasscodeTableView];
	
	_setPasscodeTableView = [[UITableView alloc] initWithFrame:tableViewFrame];
	_setPasscodeTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_setPasscodeTableView.delegate = self;
	_setPasscodeTableView.dataSource = self;
	_setPasscodeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_setPasscodeTableView.backgroundColor = [UIColor whiteColor]; //[UIColor groupTableViewBackgroundColor];
	[self.view addSubview:_setPasscodeTableView];
	
	_confirmPasscodeTableView = [[UITableView alloc] initWithFrame:tableViewFrame];
	_confirmPasscodeTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	_confirmPasscodeTableView.delegate = self;
	_confirmPasscodeTableView.dataSource = self;
	_confirmPasscodeTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
	_confirmPasscodeTableView.backgroundColor = [UIColor whiteColor]; //[UIColor groupTableViewBackgroundColor];
	[self.view addSubview:_confirmPasscodeTableView];
    
    _shouldReleaseFirstResponser = NO;
    
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
    _passcodeLockOn = [[KKKeychain getStringForKey:@"passcode_on"] isEqualToString:@"YES"];
	_eraseData = [[KKPasscodeLock sharedLock] eraseOption] && [[KKKeychain getStringForKey:@"erase_data_on"] isEqualToString:@"YES"];
    
	_enterPasscodeTextField = [[UITextField alloc] init];
    _enterPasscodeTextField.delegate = self;
    _enterPasscodeTextField.keyboardType = UIKeyboardTypeNumberPad;
	_enterPasscodeTextField.hidden = YES;
    
    _setPasscodeTextField = [[UITextField alloc] init];
    _setPasscodeTextField.delegate = self;
    _setPasscodeTextField.keyboardType = UIKeyboardTypeNumberPad;
	_setPasscodeTextField.hidden = YES;
    
	_confirmPasscodeTextField = [[UITextField alloc] init];
    _confirmPasscodeTextField.delegate = self;
    _confirmPasscodeTextField.keyboardType = UIKeyboardTypeNumberPad;
	_confirmPasscodeTextField.hidden = YES;
	
	_tableViews = [[NSMutableArray alloc] init];
	_textFields = [[NSMutableArray alloc] init];
	_boxes = [[NSMutableArray alloc] init];
	
    // Need to make sure everything is visible in landscape mode on small devices.
    self.isSmallLandscape = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && UIInterfaceOrientationIsLandscape(self.interfaceOrientation));
    
    if (_mode == KKPasscodeModeSet) {
        self.navigationItem.title = KKPasscodeLockLocalizedString(@"Set Passcode", @"");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancelButtonPressed:)];
    } else if (_mode == KKPasscodeModeChange) {
        self.navigationItem.title = KKPasscodeLockLocalizedString(@"Change Passcode", @"");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancelButtonPressed:)];
        
    } else if (_mode == KKPasscodeModeDisabled) {
        self.navigationItem.title = KKPasscodeLockLocalizedString(@"Turn off Passcode", @"");
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                                                                                              target:self
                                                                                              action:@selector(cancelButtonPressed:)];
        
    } else {
        self.navigationItem.title = KKPasscodeLockLocalizedString(@"Enter Passcode", @"");
    }
    
	if (_mode == KKPasscodeModeSet || _mode == KKPasscodeModeChange) {
		if (_passcodeLockOn) {
			_enterPasscodeTableView.tableHeaderView = [self headerViewForTextField:_enterPasscodeTextField];
			[_tableViews addObject:_enterPasscodeTableView];
			[_textFields addObject:_enterPasscodeTextField];
			[_boxes addObject:[self boxes]];
			UIView *boxesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPasscodeBoxHeight)];
			boxesView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
			for (int i = 0; i < [[_boxes lastObject] count]; i++) {
				[boxesView addSubview:[[_boxes lastObject] objectAtIndex:i]];
			}
			[_enterPasscodeTableView.tableHeaderView addSubview:boxesView];
		}
		
		_setPasscodeTableView.tableHeaderView = [self headerViewForTextField:_setPasscodeTextField];
        
		[_tableViews addObject:_setPasscodeTableView];
		[_textFields addObject:_setPasscodeTextField];
		[_boxes addObject:[self boxes]];
        UIView *boxesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPasscodeBoxHeight)];
		boxesView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		for (int i = 0; i < [[_boxes lastObject] count]; i++) {
			[boxesView addSubview:[[_boxes lastObject] objectAtIndex:i]];
		}
		[_setPasscodeTableView.tableHeaderView addSubview:boxesView];
		
		_confirmPasscodeTableView.tableHeaderView = [self headerViewForTextField:_confirmPasscodeTextField];
		[_tableViews addObject:_confirmPasscodeTableView];
		[_textFields addObject:_confirmPasscodeTextField];
		[_boxes addObject:[self boxes]];
		UIView *boxesConfirmView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPasscodeBoxHeight)];
		boxesConfirmView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		for (int i = 0; i < [[_boxes lastObject] count]; i++) {
			[boxesConfirmView addSubview:[[_boxes lastObject] objectAtIndex:i]];
		}
		[_confirmPasscodeTableView.tableHeaderView addSubview:boxesConfirmView];
	} else {
		_enterPasscodeTableView.tableHeaderView = [self headerViewForTextField:_enterPasscodeTextField];
		[_tableViews addObject:_enterPasscodeTableView];
		[_textFields addObject:_enterPasscodeTextField];
		[_boxes addObject:[self boxes]];
		UIView *boxesView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kPasscodeBoxHeight)];
		boxesView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
		for (int i = 0; i < [[_boxes lastObject] count]; i++) {
			[boxesView addSubview:[[_boxes lastObject] objectAtIndex:i]];
		}
		[_enterPasscodeTableView.tableHeaderView addSubview:boxesView];
	}
	
	[self.view addSubview:[_tableViews objectAtIndex:0]];
	
	for (int i = 1; i < [_tableViews count]; i++) {
		UITableView *tableView = [_tableViews objectAtIndex:i];
		tableView.frame = CGRectMake(tableView.frame.origin.x + self.view.bounds.size.width,
                                     tableView.frame.origin.y,
                                     tableView.frame.size.width,
                                     tableView.frame.size.height);
		[self.view addSubview:tableView];
	}
	
	[[_textFields objectAtIndex:0] becomeFirstResponder];
	[[_tableViews objectAtIndex:0] reloadData];
	[[_textFields objectAtIndex:[_tableViews count] - 1] setReturnKeyType:UIReturnKeyDone];
	
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
		if ([_tableViews count] > 1) {
			[self moveToNextTableView];
			[self moveToPreviousTableView];
		} else {
			UITableView *tableView = [_tableViews objectAtIndex:0];
			tableView.frame = CGRectMake(tableView.frame.origin.x,
                                         tableView.frame.origin.y,
                                         self.view.bounds.size.width,
                                         self.view.bounds.size.height);
		}
        
        if (!self.dimView) {
            id<UIApplicationDelegate> appDelegate = [[UIApplication sharedApplication] delegate];
            self.dimView = [[UIView alloc] initWithFrame:appDelegate.window.rootViewController.view.bounds];
            self.dimView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            self.dimView.backgroundColor = [UIColor scrollViewTexturedBackgroundColor];
            self.dimView.alpha = 0.0f;
            [appDelegate.window.rootViewController.view addSubview:self.dimView];
            [UIView animateWithDuration:0.3f animations:^{
                self.dimView.alpha = 1.0f;
            }];
        }
	}
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    _shouldReleaseFirstResponser = YES;
    [_enterPasscodeTextField resignFirstResponder];
    [_setPasscodeTextField resignFirstResponder];
    [_confirmPasscodeTextField resignFirstResponder];
    
    if (self.dimView) {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             self.dimView.alpha = 0.0f;
                         }
                         completion:^(BOOL finished) {
                             [self.dimView removeFromSuperview];
                             self.dimView = nil;
                         }];
    }
}

#pragma mark -
#pragma mark Private methods


- (void)cancelButtonPressed:(id)sender
{
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
    [self dismissModalViewControllerAnimated:YES];
#else
    [self dismissViewControllerAnimated:YES completion:nil];
#endif
}


- (void)incrementFailedAttemptsLabel
{
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    
	_enterPasscodeTextField.text = @"";
	for (int i = 0; i < kPasscodeBoxesCount; i++) {
		[[[_boxes objectAtIndex:_currentPanel] objectAtIndex:i] setImage:[UIImage imageNamed:@"box_empty.png"]];
	}
	
    NSInteger _failedAttemptsCount = [[KKKeychain getStringForKey:@"failedAttemptsCount"] integerValue];
    
    _failedAttemptsCount++;
    
    [KKKeychain setString:[NSString stringWithFormat:@"%d", _failedAttemptsCount] forKey:@"failedAttemptsCount"];

	if (_failedAttemptsCount == 1) {
		_failedAttemptsLabel.text = KKPasscodeLockLocalizedString(@"1 Failed Passcode Attempt", @"");
	} else {
		_failedAttemptsLabel.text = [NSString stringWithFormat:KKPasscodeLockLocalizedString(@"%i Failed Passcode Attempts", @""), _failedAttemptsCount];
	}
    float y;
    if (_hideToolbar) {
        y = 195;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) //Cuong
            y += kIOS7CarrierbarHeight;
    } else {
        if (self.view.frame.size.height >= 500)
            y = 190;
        else
            y = 152;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) //Cuong
            y += kIOS7ToolbarHeight;
    }
	CGSize size = [_failedAttemptsLabel.text sizeWithFont:[UIFont boldSystemFontOfSize:self.isSmallLandscape ? 10.0f : 14.0f]];
	_failedAttemptsLabel.frame = _failedAttemptsView.frame = CGRectMake((self.view.bounds.size.width - (size.width + (self.isSmallLandscape ? 20.0f : 40.0f))) / 2, self.isSmallLandscape ? y - 70 : y, size.width + (self.isSmallLandscape ? 20.0f : 40.0f), size.height + (self.isSmallLandscape ? 5.0f : 10.0f));
	
	CAGradientLayer *gradient = [CAGradientLayer layer];
	gradient.frame = _failedAttemptsView.bounds;
	gradient.colors = [NSArray arrayWithObjects:
                       (id)[[UIColor colorWithRed:0.7 green:0.05 blue:0.05 alpha:1.0] CGColor],
                       (id)[[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0] CGColor], nil];
	[_failedAttemptsView.layer insertSublayer:gradient atIndex:0];
	_failedAttemptsView.layer.masksToBounds = YES;
	
	_failedAttemptsLabel.hidden = NO;
	_failedAttemptsView.hidden = NO;
	
	if (_failedAttemptsCount == [[KKPasscodeLock sharedLock] attemptsAllowed]) {
		
		_enterPasscodeTextField.delegate = nil;
		
		if (_eraseData) {
			if ([_delegate respondsToSelector:@selector(shouldEraseApplicationData:)]) {
				[_delegate shouldEraseApplicationData:self];
			}
		} else {
			if ([_delegate respondsToSelector:@selector(didPasscodeEnteredIncorrectly:)]) {
				[_delegate didPasscodeEnteredIncorrectly:self];
			}
            
            [KKKeychain setString:[[KKPasscodeLock sharedLock].dateFormatter stringFromDate:[NSDate date]] forKey:@"incorrect_passcode_datetime"];
            
            if ([_delegate respondsToSelector:@selector(shouldLockApplication:)]) {
				[_delegate shouldLockApplication:self];
			}
		}
        
        [KKKeychain setString:@"0" forKey:@"failedAttemptsCount"];
	}
	
}

- (void)moveToNextTableView
{
	_currentPanel += 1;
    
	UITableView *oldTableView = [_tableViews objectAtIndex:_currentPanel - 1];
	UITableView *newTableView = [_tableViews objectAtIndex:_currentPanel];
    
	newTableView.frame = CGRectMake(oldTableView.frame.origin.x + self.view.bounds.size.width,
                                    oldTableView.frame.origin.y,
                                    oldTableView.frame.size.width,
                                    oldTableView.frame.size.height);
	
	for (int i = 0; i < kPasscodeBoxesCount; i++) {
		[[[_boxes objectAtIndex:_currentPanel] objectAtIndex:i] setImage:[UIImage imageNamed:@"box_empty.png"]];
	}
	
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationDuration:0.25];
	oldTableView.frame = CGRectMake(oldTableView.frame.origin.x - self.view.bounds.size.width, oldTableView.frame.origin.y, oldTableView.frame.size.width, oldTableView.frame.size.height);
	newTableView.frame = self.view.bounds;
	[UIView commitAnimations];
	
	_shouldReleaseFirstResponser = YES;
	[[_textFields objectAtIndex:_currentPanel - 1] resignFirstResponder];
	_shouldReleaseFirstResponser = NO;
	[[_textFields objectAtIndex:_currentPanel] becomeFirstResponder];
}


- (void)moveToPreviousTableView
{
	_currentPanel -= 1;
    
	UITableView *oldTableView = [_tableViews objectAtIndex:_currentPanel + 1];
	UITableView *newTableView = [_tableViews objectAtIndex:_currentPanel];
	newTableView.frame = CGRectMake(oldTableView.frame.origin.x - self.view.bounds.size.width, oldTableView.frame.origin.y, oldTableView.frame.size.width, oldTableView.frame.size.height);
	
	for (int i = 0; i < kPasscodeBoxesCount; i++) {
		[[[_boxes objectAtIndex:_currentPanel] objectAtIndex:i] setImage:[UIImage imageNamed:@"box_empty.png"]];
	}
	
	[UIView beginAnimations:@"" context:nil];
	[UIView setAnimationDuration:0.25];
	oldTableView.frame = CGRectMake(oldTableView.frame.origin.x + self.view.bounds.size.width, oldTableView.frame.origin.y, oldTableView.frame.size.width, oldTableView.frame.size.height);
	newTableView.frame = self.view.bounds;
	[UIView commitAnimations];
	
    _shouldReleaseFirstResponser = YES;
	[[_textFields objectAtIndex:_currentPanel + 1] resignFirstResponder];
    _shouldReleaseFirstResponser = NO;
	[[_textFields objectAtIndex:_currentPanel] becomeFirstResponder];
}


- (void)nextDigitPressed
{
	UITextField* textField = [_textFields objectAtIndex:_currentPanel];
	
	if (![textField.text isEqualToString:@""]) {
		
		if (_mode == KKPasscodeModeSet) {
			if ([textField isEqual:_setPasscodeTextField]) {
				[self moveToNextTableView];
			} else if ([textField isEqual:_confirmPasscodeTextField]) {
				if (![_confirmPasscodeTextField.text isEqualToString:_setPasscodeTextField.text]) {
					_confirmPasscodeTextField.text = @"";
					_setPasscodeTextField.text = @"";
					_passcodeConfirmationWarningLabel.text = KKPasscodeLockLocalizedString(@"Passcodes did not match. Try again.", @"");
					[self moveToPreviousTableView];
				} else {
					if ([KKKeychain setString:_setPasscodeTextField.text forKey:@"passcode"]) {
						[KKKeychain setString:@"YES" forKey:@"passcode_on"];
					}
					
					if ([_delegate respondsToSelector:@selector(didSettingsChanged:)]) {
						[_delegate performSelector:@selector(didSettingsChanged:) withObject:self];
					}
					
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
                    [self dismissModalViewControllerAnimated:YES];
#else
                    [self dismissViewControllerAnimated:YES completion:nil];
#endif
				}
			}
		} else if (_mode == KKPasscodeModeChange) {
			NSString* passcode = [KKKeychain getStringForKey:@"passcode"];
			if ([textField isEqual:_enterPasscodeTextField]) {
				if ([passcode isEqualToString:_enterPasscodeTextField.text]) {
					[self moveToNextTableView];
				} else {
					[self incrementFailedAttemptsLabel];
				}
			} else if ([textField isEqual:_setPasscodeTextField]) {
				if ([passcode isEqualToString:_setPasscodeTextField.text]) {
					_setPasscodeTextField.text = @"";
					_passcodeConfirmationWarningLabel.text = KKPasscodeLockLocalizedString(@"Enter a different passcode. You cannot re-use the same passcode.", @"");
//					[_passcodeConfirmationWarningLabel setHeight:55];
				} else {
					_passcodeConfirmationWarningLabel.text = @"";
//					[_passcodeConfirmationWarningLabel setHeight:30];
					[self moveToNextTableView];
				}
			} else if ([textField isEqual:_confirmPasscodeTextField]) {
				if (![_confirmPasscodeTextField.text isEqualToString:_setPasscodeTextField.text]) {
					_confirmPasscodeTextField.text = @"";
					_setPasscodeTextField.text = @"";
					_passcodeConfirmationWarningLabel.text = KKPasscodeLockLocalizedString(@"Passcodes did not match. Try again.", "");
					[self moveToPreviousTableView];
				} else {
					if ([KKKeychain setString:_setPasscodeTextField.text forKey:@"passcode"]) {
						[KKKeychain setString:@"YES" forKey:@"passcode_on"];
					}
					
					if ([_delegate respondsToSelector:@selector(didSettingsChanged:)]) {
						[_delegate performSelector:@selector(didSettingsChanged:) withObject:self];
					}
                    
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
                    [self dismissModalViewControllerAnimated:YES];
#else
                    [self dismissViewControllerAnimated:YES completion:nil];
#endif
				}
			}
		}
	}
}

- (void)vaildatePasscode:(UITextField*)textField
{
    if (_mode == KKPasscodeModeDisabled) {
        NSString *passcode = [KKKeychain getStringForKey:@"passcode"];
        if ([_enterPasscodeTextField.text isEqualToString:passcode]) {
            if ([KKKeychain setString:@"NO" forKey:@"passcode_on"]) {
                [KKKeychain setString:@"" forKey:@"passcode"];
            }
            
            if ([_delegate respondsToSelector:@selector(didSettingsChanged:)]) {
                [_delegate performSelector:@selector(didSettingsChanged:) withObject:self];
            }
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
            [self dismissModalViewControllerAnimated:YES];
#else
            [self dismissViewControllerAnimated:YES completion:nil];
#endif
        } else {
            [self incrementFailedAttemptsLabel];
        }
    } else if (_mode == KKPasscodeModeEnter) {
        NSString *passcode = [KKKeychain getStringForKey:@"passcode"];
        if ([_enterPasscodeTextField.text isEqualToString:passcode]) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [UIView beginAnimations:@"fadeIn" context:nil];
                [UIView setAnimationDelay:0.25];
                [UIView setAnimationDuration:0.5];
                
                [UIView commitAnimations];
            }
            if ([_delegate respondsToSelector:@selector(didPasscodeEnteredCorrectly:)]) {
                [_delegate performSelector:@selector(didPasscodeEnteredCorrectly:) withObject:self];
            }
            
            [KKKeychain setString:@"0" forKey:@"failedAttemptsCount"];

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
            [self dismissModalViewControllerAnimated:YES];
#else
            [self dismissViewControllerAnimated:YES completion:nil];
#endif
        } else {
            [self incrementFailedAttemptsLabel];
        }
    } else if (_mode == KKPasscodeModeChange) {
        NSString *passcode = [KKKeychain getStringForKey:@"passcode"];
        if ([textField isEqual:_enterPasscodeTextField]) {
            if ([passcode isEqualToString:_enterPasscodeTextField.text]) {
                [self moveToNextTableView];
            } else {
                [self incrementFailedAttemptsLabel];
            }
        } else if ([textField isEqual:_setPasscodeTextField]) {
            if ([passcode isEqualToString:_setPasscodeTextField.text]) {
                _setPasscodeTextField.text = @"";
                for (int i = 0; i < kPasscodeBoxesCount; i++) {
                    [[[_boxes objectAtIndex:_currentPanel] objectAtIndex:i] setImage:[UIImage imageNamed:@"box_empty.png"]];
                }
                _passcodeConfirmationWarningLabel.text = KKPasscodeLockLocalizedString(@"Enter a different passcode. You cannot re-use the same passcode.", @"");
//                [_passcodeConfirmationWarningLabel setHeight:55];
            } else {
                _passcodeConfirmationWarningLabel.text = @"";
//                [_passcodeConfirmationWarningLabel setHeight:30];
                [self moveToNextTableView];
            }
        } else if ([textField isEqual:_confirmPasscodeTextField]) {
            if (![_confirmPasscodeTextField.text isEqualToString:_setPasscodeTextField.text]) {
                _confirmPasscodeTextField.text = @"";
                _setPasscodeTextField.text = @"";
                _passcodeConfirmationWarningLabel.text = KKPasscodeLockLocalizedString(@"Passcodes did not match. Try again.", @"");
                [self moveToPreviousTableView];
            } else {
                if ([KKKeychain setString:_setPasscodeTextField.text forKey:@"passcode"]) {
                    [KKKeychain setString:@"YES" forKey:@"passcode_on"];
                }
                
                if ([_delegate respondsToSelector:@selector(didSettingsChanged:)]) {
                    [_delegate performSelector:@selector(didSettingsChanged:) withObject:self];
                }

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
                [self dismissModalViewControllerAnimated:YES];
#else
                [self dismissViewControllerAnimated:YES completion:nil];
#endif
            }
        }
    } else if ([textField isEqual:_setPasscodeTextField]) {
        [self moveToNextTableView];
    } else if ([textField isEqual:_confirmPasscodeTextField]) {
        if (![_confirmPasscodeTextField.text isEqualToString:_setPasscodeTextField.text]) {
            _confirmPasscodeTextField.text = @"";
            _setPasscodeTextField.text = @"";
            _passcodeConfirmationWarningLabel.text = KKPasscodeLockLocalizedString(@"Passcodes did not match. Try again.", @"");
            [self moveToPreviousTableView];
        } else {
            if ([KKKeychain setString:_setPasscodeTextField.text forKey:@"passcode"]) {
                [KKKeychain setString:@"YES" forKey:@"passcode_on"];
            }
            
            if ([_delegate respondsToSelector:@selector(didSettingsChanged:)]) {
                [_delegate performSelector:@selector(didSettingsChanged:) withObject:self];
            }
            
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
            [self dismissModalViewControllerAnimated:YES];
#else
            [self dismissViewControllerAnimated:YES completion:nil];
#endif
        }
    }
}


- (void)doneButtonPressed
{
	UITextField *textField = [_textFields objectAtIndex:_currentPanel];
	[self vaildatePasscode:textField];
}


- (UIView*)headerViewForTextField:(UITextField*)textField
{
    [self.view addSubview:textField];
    float width = self.view.frame.size.width;
	UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, width, 160.0)];
    
    float y;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        y = 45;
    else if (_hideToolbar) {
        y = 45;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) //Cuong
            y += kIOS7CarrierbarHeight;
    } else {
        if (self.view.frame.size.height >= 500)
            y = 35;
        else
            y = 8;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) //Cuong
            y += kIOS7ToolbarHeight;
    }
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * 0.05, y, width * 0.9, 50)];
    logoImageView.image = [UIImage imageNamed:@"FetchLogo_Text.png"];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    logoImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    [headerView addSubview:logoImageView];
    
	UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, y + 52, self.view.bounds.size.width, 30.0)];
	headerLabel.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.4 alpha:1.0];
	headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;

#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
	headerLabel.textAlignment = UITextAlignmentCenter;
#else
	headerLabel.textAlignment = NSTextAlignmentCenter;
#endif
    
	headerLabel.font = [UIFont boldSystemFontOfSize:self.isSmallLandscape ? 12.0f : 17.0f];
	headerLabel.shadowOffset = CGSizeMake(0, 1.0);
	headerLabel.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
	
	if ([textField isEqual:_setPasscodeTextField]) {
		_passcodeConfirmationWarningLabel = [[TopAlignedLabel alloc] initWithFrame:CGRectMake(0.0, self.isSmallLandscape ? 73.0f : y + 138, self.view.bounds.size.width, 60.0)];
        _passcodeConfirmationWarningLabel.numberOfLines = 2;
		_passcodeConfirmationWarningLabel.textColor = [UIColor colorWithRed:0.3 green:0.3 blue:0.4 alpha:1.0];
		_passcodeConfirmationWarningLabel.backgroundColor = [UIColor clearColor];
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
		_passcodeConfirmationWarningLabel.textAlignment = UITextAlignmentCenter;
#else
		_passcodeConfirmationWarningLabel.textAlignment = NSTextAlignmentCenter;
#endif

		_passcodeConfirmationWarningLabel.font = [UIFont systemFontOfSize:14.0];
		_passcodeConfirmationWarningLabel.shadowOffset = CGSizeMake(0, 1.0);
		_passcodeConfirmationWarningLabel.shadowColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
		_passcodeConfirmationWarningLabel.text = @"";
		_passcodeConfirmationWarningLabel.numberOfLines = 0;
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
		_passcodeConfirmationWarningLabel.lineBreakMode = UILineBreakModeWordWrap;
#else
		_passcodeConfirmationWarningLabel.lineBreakMode = NSLineBreakByWordWrapping;
#endif
        
		[headerView addSubview:_passcodeConfirmationWarningLabel];
	}
	
	if ([textField isEqual:_enterPasscodeTextField]) {
		_failedAttemptsView = [[UIView alloc] init];
		_failedAttemptsLabel = [[UILabel alloc] init];
		_failedAttemptsLabel.backgroundColor = [UIColor clearColor];
		_failedAttemptsLabel.textColor = [UIColor whiteColor];
		_failedAttemptsLabel.text = @"";
		_failedAttemptsLabel.font = [UIFont boldSystemFontOfSize:self.isSmallLandscape ? 10.0f : 14.0f];
        
#if __IPHONE_OS_VERSION_MIN_REQUIRED < 60000
		_failedAttemptsLabel.textAlignment = UITextAlignmentCenter;
#else
		_failedAttemptsLabel.textAlignment = NSTextAlignmentCenter;
#endif
        
		_failedAttemptsLabel.shadowOffset = CGSizeMake(0, -1.0);
		_failedAttemptsLabel.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0];
		_failedAttemptsView.layer.cornerRadius = self.isSmallLandscape ? 7.0f : 14.0f;
		_failedAttemptsView.layer.borderWidth = 1.0;
		_failedAttemptsView.layer.borderColor = [[UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.25] CGColor];
		
		_failedAttemptsLabel.hidden = YES;
		_failedAttemptsView.hidden = YES;
        
		_failedAttemptsView.layer.masksToBounds = YES;
		
		[headerView addSubview:_failedAttemptsView];
		[headerView addSubview:_failedAttemptsLabel];
	}
	
    if (_mode == KKPasscodeModeSet) {
        if ([textField isEqual:_enterPasscodeTextField]) {
            headerLabel.text = KKPasscodeLockLocalizedString(@"Enter your passcode", @"");
        } else if ([textField isEqual:_setPasscodeTextField]) {
            headerLabel.text = KKPasscodeLockLocalizedString(@"Enter a passcode", @"");
        } else if ([textField isEqual:_confirmPasscodeTextField]) {
            headerLabel.text = KKPasscodeLockLocalizedString(@"Re-enter your passcode", @"");
        }
        headerLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [headerView addSubview:headerLabel];
    } else if (_mode == KKPasscodeModeChange) {
        if ([textField isEqual:_enterPasscodeTextField]) {
            headerLabel.text = KKPasscodeLockLocalizedString(@"Enter your old passcode", @"");
        } else if ([textField isEqual:_setPasscodeTextField]) {
            headerLabel.text = KKPasscodeLockLocalizedString(@"Enter your new passcode", @"");
        } else {
            headerLabel.text = KKPasscodeLockLocalizedString(@"Re-enter your new passcode", @"");
        }
        headerLabel.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
        [headerView addSubview:headerLabel];
    } else {
        if (_hideToolbar)
            y += 60;
        else
            y += 55;
        
        UIImageView *textImageView = [[UIImageView alloc] initWithFrame:CGRectMake(width * 0.2, y, width * 0.6, 22)];
        textImageView.image = [UIImage imageNamed:@"Enter_passcode.png"];
        textImageView.contentMode = UIViewContentModeScaleAspectFit;
        textImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        [headerView addSubview:textImageView];
    }
	return headerView;
}


- (NSArray*)boxes
{
	NSMutableArray* squareViews = [NSMutableArray array];
	
    CGFloat width = self.isSmallLandscape ? kPasscodeBoxWidth * 0.6f : kPasscodeBoxWidth;
    CGFloat height = self.isSmallLandscape ? kPasscodeBoxHeight * 0.6f : kPasscodeBoxHeight;
    CGFloat offset = width * 0.1;
	CGFloat squareX = (self.view.frame.size.width - kPasscodeBoxesCount * width - (kPasscodeBoxesCount - 1) * offset) / 2;
	
    float y;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
        y = 130;
    else if (_hideToolbar) {
        y = 136;
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) //Cuong
            y += kIOS7CarrierbarHeight;
    } else {
        if(self.view.frame.size.height >= 500)
            y = 126;
        else
            y = 98;
        
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) //Cuong
            y += kIOS7ToolbarHeight;
    }
    
	for (int i = 0; i < kPasscodeBoxesCount; i++) {
		UIImageView *square = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"box_empty.png"]];
		square.frame = CGRectMake(squareX, self.isSmallLandscape ? y - 40 : y, width, height);
		[squareViews addObject:square];
		squareX += width + offset;
	}
	return [NSArray arrayWithArray:squareViews];
}

#pragma mark - UITableViewDataSource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView*)tableView
{
	return 0;
}


- (NSInteger)tableView:(UITableView*)tableView numberOfRowsInSection:(NSInteger)section
{
	return 1;
}


- (UITableViewCell*)tableView:(UITableView*)aTableView cellForRowAtIndexPath:(NSIndexPath*)indexPath
{
	static NSString* CellIdentifier = @"KKPasscodeViewControllerCell";
	
	UITableViewCell* cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	if ([aTableView isEqual:_enterPasscodeTableView]) {
		cell.accessoryView = _enterPasscodeTextField;
	} else if ([aTableView isEqual:_setPasscodeTableView]) {
		cell.accessoryView = _setPasscodeTextField;
	} else if ([aTableView isEqual:_confirmPasscodeTableView]) {
		cell.accessoryView = _confirmPasscodeTextField;
	}
	
	return cell;
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//
//    
//    return headerView;
//}


#pragma mark -
#pragma mark UITextFieldDelegate methods

- (BOOL)textFieldShouldReturn:(UITextField*)textField
{
	if ([textField isEqual:[_textFields lastObject]]) {
		[self doneButtonPressed];
	} else {
		[self nextDigitPressed];
	}
	return NO;
}





- (BOOL)textField:(UITextField*)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString*)string
{
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    textField.text = result;
    
    for (int i = 0; i < kPasscodeBoxesCount; i++) {
        UIImageView *square = [[_boxes objectAtIndex:_currentPanel] objectAtIndex:i];
        if (i < [result length]) {
            square.image = [UIImage imageNamed:@"box_filled.png"];
        } else {
            square.image = [UIImage imageNamed:@"box_empty.png"];
        }
    }
    
    if ([result length] == kPasscodeBoxesCount) {
        [self vaildatePasscode:textField];
    }
    
    return NO;
}



- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
    return _shouldReleaseFirstResponser;
}

#pragma mark -
#pragma mark Memory management

@end
