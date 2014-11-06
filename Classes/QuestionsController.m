//
//  QuestionsController.m
//  playground
//
//  Created by Drew Wilson on 10/9/12.
//  Copyright (c) 2012 Drew Wilson. All rights reserved.
//

#import <Crashlytics/Crashlytics.h>
#import "CommonFunc.h"
#import "MF_Base64Additions.h"
#import "AnswerQuestionOperation.h"
#import "UIView+ExtLayout.h"

#import "QuestionsController.h"
#import "FTQuestion.h"
#import "FTSession.h"
#import "Constants.h"   //Cuong
#import "CommonLayout.h" //Cuong
#import "FTMobileAppDelegate.h"

enum {
    kQCLabelRow,
    kQCInputRow,
    kNumberRows
};

@interface QuestionsController () <UIToolbarDelegate>

//@property (weak, nonatomic) IBOutlet QuestionPanel *panelView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (strong) NSString *doneButtonTitle;
@property (weak, nonatomic) IBOutlet UILabel *descriptionView;
@property (weak, nonatomic) IBOutlet UIView *infoBackgroundView;
@property (weak, nonatomic) IBOutlet UILabel *labelInfo;
@property (weak, nonatomic) IBOutlet UITextField *answerField;
@property (weak, nonatomic) IBOutlet UITextField *answerFieldA; //user id
@property (weak, nonatomic) IBOutlet UITextField *answerFieldB; //password
@property (weak, nonatomic) IBOutlet UIPickerView *answerPicker;
@property (weak, nonatomic) IBOutlet UIView *credentialsView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbarView;

@property (assign) NSInteger nextQuestionIndex;
@property (strong, nonatomic) FTQuestion *currentQuestion;
@property (weak, readonly) NSString *currentQuestionKey;
@property (readonly) NSInteger currentQuestionId;
@property (strong, nonatomic) UIViewController *presenter;
@property (strong) UIPopoverController *popover;
@property (strong) FTConnection *connection;
@property (strong) NSString *pickedValue;

@property (strong) NSMutableArray *answeredQuestions;
@property (strong, nonatomic) NSMutableArray *questionQueue;

@property (assign) SEL okAction;
@property (assign) SEL cancelAction;

@end

@implementation QuestionsController


+ (void)askQuestions:(NSArray *)questions
   fromViewController:(UIViewController *)presenter
             fromRect:(CGRect)rect
        forConnection: (FTConnection *)connection
           withAction:(SEL)doneAction
     withCancelAction:(SEL)cancelAction;
{
    QuestionsController *qc = [[QuestionsController alloc] initWithNibName:@"QuestionsController" bundle:nil];
    qc.okAction = doneAction;
    qc.cancelAction = cancelAction;
    qc.questionQueue = [questions mutableCopy];
    qc.connection = connection;
    qc.presenter = presenter;
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [presenter presentViewController:qc animated:YES
                             completion: ^ {
                                 NSLog(@"view appeared...");
                             }];
    } else {
        UIPopoverController *po = [[UIPopoverController alloc] initWithContentViewController:qc];
        qc.popover = po;
        qc.view.autoresizingMask = UIViewAutoresizingNone;
        qc.popover.popoverContentSize = CGSizeMake(320., 460);
        [qc.popover presentPopoverFromRect:rect inView:presenter.view permittedArrowDirections:UIPopoverArrowDirectionLeft animated:YES];
        po.delegate = qc;
    }
}

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.questionQueue = [NSMutableArray arrayWithCapacity:4];
    }
    return self;
}

- (void)awakeFromNib {
    NSLog(@"waking from nib! %@", self);
}

- (void)viewDidLoad {
    CLS_LOG(@"%@ viewDidLoad:", [[self class] description]);
    
    NSLog(@"qc's view=%@", self.view);
    self.doneButtonTitle = self.doneButton.title;
    
    //Cuong: set title font and color
    self.toolbarView.delegate = self;
    self.toolbarView.barTintColor = kTextOrangeColor;
    UIFont * font = [CommonLayout getFont:FontSizeSmall isBold:NO];
    NSDictionary * attributes = @{NSFontAttributeName: font};
    for (id barItem in self.toolbarView.items) {
        if ([barItem isKindOfClass:[UIBarButtonItem class]]) {
            [barItem setTitleTextAttributes:attributes forState:UIControlStateNormal];
        }
    }
    [CommonLayout setAppFontForSubviewsOfView:self.view];
    self.infoBackgroundView.layer.cornerRadius = 2;
    
    //    self.tableView = [[UITableView alloc] initWithFrame:self.view.frame style:UITableViewStyleGrouped];
    //    [self.view addSubview:self.tableView];
    
//    UIBarButtonItem *cancel = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
//    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
//    UIBarButtonItem *title = [[UIBarButtonItem alloc] initWithTitle:@"Verification" style:UIBarButtonItemStylePlain target:nil action:nil];
//    UIBarButtonItem *done = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done:)];
//    NSArray *items = @[cancel, flexSpace, title, flexSpace, done];
//    
//    UIToolbar *toolbar = [[UIToolbar alloc] init];
//    toolbar.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
//    [toolbar setItems:items animated:NO];
//    [self.view addSubview:toolbar];
//    
//    CGRect frame = self.view.frame;
//    frame.origin.y = toolbar.frame.origin.y + toolbar.frame.size.height;
//    frame.size.height -= toolbar.frame.size.height;
//    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
//    tableView.delegate = self;
//    tableView.dataSource = self;
//    [self.view addSubview:tableView];
    
    self.answeredQuestions = [NSMutableArray arrayWithCapacity:4];
    
//    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) { //Cuong
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.toolbarView setTop:20];
            [self.descriptionView setTop:[self.toolbarView bottom] + 20];
            [self.view setNeedsLayout];
        }
//    }
    self.labelInfo.frame = [self.descriptionView rectAtBottom:10 height:300];
    self.labelInfo.hidden = YES;
    
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    CLS_LOG(@"QuestionsController viewWillAppear:");
    [super viewWillAppear:animated];
    (void) [self setNextQuestion:animated];

    /*if (!self.currentQuestion.isMultipleChoice) {
        [[self.toolbarView.items lastObject] setEnabled:NO];
    }*/
    [self refreshButton];
}

- (void)viewWillDisappear:(BOOL)animated {
    CLS_LOG(@"QuestionsController viewWillDisappear:");
    [super viewWillDisappear:animated];
}

-(NSUInteger)supportedInterfaceOrientations {
    return  UIInterfaceOrientationMaskPortrait + UIInterfaceOrientationMaskPortraitUpsideDown;
}

- (void)dismissQuestionPanel {
    if (self.popover != NULL) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = NULL;
    } else {
        [self.presentingViewController dismissViewControllerAnimated:YES
                        completion:^{ NSLog(@"dismissing Question panel view controller"); } ];
    }
}

- (IBAction)handleCancel:(id)sender
{
    [self dismissQuestionPanel];
}

- (NSInteger)nextQuestionId {
    int nextId = 0;
    if (self.nextQuestionIndex < [self.questionQueue count]) {
        FTQuestion *nextQuestion = (self.questionQueue)[self.nextQuestionIndex];
        nextId = nextQuestion.uniqueId;
    }
    return nextId;
}

- (int) countQuestionsRemaining {
    return self.questionQueue.count - self.nextQuestionIndex;
}

- (BOOL)setNextQuestion:(BOOL)animated {
    int numRemaining = [self countQuestionsRemaining];
    BOOL stillGoing = numRemaining > 0;
    if (stillGoing) {
        self.currentQuestion = self.questionQueue[self.nextQuestionIndex];
        [UIView animateWithDuration:1.0 animations:^{
            if (numRemaining == 1) {
                if (self.currentQuestion.isActionRequired) {
                    self.doneButton.title = @"Try Again";
                } else {
                    self.doneButton.title = self.doneButtonTitle;
                }
            }
            [self takeValuesFromQuestion:self.currentQuestion];
        }];
        
        self.nextQuestionIndex += 1;    // increment
    }

    return stillGoing;
}

- (NSString *)currentQuestionKey {
    return self.currentQuestion.key;
}

- (NSInteger)currentQuestionId {
    return self.currentQuestion.uniqueId;
}

- (NSArray *)questions {
    return self.questionQueue;
}

- (void)setQuestionQueue:(NSMutableArray *)newQuestions {
    _questionQueue = newQuestions;
    self.nextQuestionIndex = 0;
}

- (NSString *)answerText {
    NSString *answer = nil;
    if (self.currentQuestion.isMultipleChoice) {
        answer = self.pickedValue;
    } else if (self.currentQuestion.isCredentials) {
        /*
         where <encoded_credentials> is the base-64 encoding of the string:
         <username>:<password>
         */
        NSString *a = self.answerFieldA.text != nil ? self.answerFieldA.text : @"";
        NSString *b = self.answerFieldB.text != nil ? self.answerFieldB.text : @"";
        NSString *rawAnswer = [[a stringByAppendingString:@":"] stringByAppendingString:b];
        answer = [rawAnswer base64String];
    } else {
        answer = stringNotNil(self.answerField.text);
    }
    self.currentQuestion.answer = answer;
    
    return answer;
}

- (void)takeValuesFromQuestion:(FTQuestion *)question {
    self.currentQuestion = question;
    
    self.answerField.text = nil;
    self.answerFieldA.text = nil;
    self.answerFieldB.text = nil;
    
//#ifdef DEBUG_SET_USER_ACTION_REQUIRED_FOR_1ST_CREDENTIALS_QUESTION
//    NSString *questionString = @"One-Time Identification Code Needed\nFirst Tech Federal Credit Union needs a one-time Identification Code to confirm that you own the accounts before FileThis can access them. Please re-run this connection and follow the instructions.";
//#else
    NSString *questionString = question.label;
//#endif
    
    if ([questionString length] > 0) {
        NSMutableParagraphStyle *style  = [[NSMutableParagraphStyle alloc] init];
        style.paragraphSpacing = 8.f;
        style.lineSpacing = 2.f;
        style.alignment = NSTextAlignmentCenter;
        NSDictionary *attributtes = @{NSParagraphStyleAttributeName : style,};
        self.descriptionView.attributedText = [[NSAttributedString alloc] initWithString:questionString  attributes:attributtes];
        [self.descriptionView autoHeight];
        
        float y = [self.descriptionView bottom] + 20;
        [self.answerField setTop:y];
        [self.answerPicker setTop:y];
        [self.credentialsView setTop:y];
    }
    
    self.labelInfo.hidden = YES;
    self.infoBackgroundView.hidden = YES;
    
    if ([question isActionRequired]) {
#ifdef DEBUG_SET_USER_ACTION_REQUIRED_FOR_1ST_CREDENTIALS_QUESTION
        NSString *connectionInfo = @"Before FileThis can fetch your documents you must first login directly to your Nationstar Mortgage account and accept the new Terms of Use.";
#else
        NSString *connectionInfo = [self.connection getInfoDescription];
#endif
        if (connectionInfo.length > 0) {
            self.labelInfo.frame = CGRectMake([self.descriptionView left] + 10, [self.descriptionView bottom] + 30, self.view.frame.size.width - 2 * [self.descriptionView left] - 20, 300);
            self.labelInfo.text = connectionInfo;
            [self.labelInfo autoHeight];
            self.labelInfo.hidden = NO;
            
            self.infoBackgroundView.frame = CGRectMake([self.descriptionView left], [self.descriptionView bottom] + 20, self.view.frame.size.width - 2 * [self.descriptionView left], self.labelInfo.frame.size.height + 20);
            self.infoBackgroundView.hidden = NO;
        }
    }
    
    BOOL isReadOnly = [question isReadOnly];
    BOOL isMultipleChoice = [question isMultipleChoice];
    
    UITextField *toBeFirstResponder = nil;
    
    if (question.isCredentials) {
        self.answerField.hidden = YES;
        self.credentialsView.hidden = NO;
    } else {
        self.answerField.hidden = NO;
        self.credentialsView.hidden = YES;
        self.answerField.text = question.answer;
    }
    
    if (isReadOnly) {
        self.answerField.hidden = YES;
        self.answerPicker.hidden = YES;
    } else if (isMultipleChoice) {
        self.answerField.hidden = YES;
        self.answerPicker.hidden = NO;
    } else {
        if (question.isCredentials)
            toBeFirstResponder = self.answerFieldA;
        else
            toBeFirstResponder = self.answerField;
        
        self.answerPicker.hidden = YES;
    }
    
    if (toBeFirstResponder != nil) {
        [toBeFirstResponder becomeFirstResponder];
    } else {
        [self.answerField resignFirstResponder];
        [self.answerFieldA resignFirstResponder];
        [self.answerFieldB resignFirstResponder];
    }
}

- (void)textFieldDone:(id)sender
{
    NSLog(@"TODO: implement textfielddone:%@", sender);
}

#pragma mark - Check input data
- (BOOL)checkDataToAnwser {
    if (self.currentQuestion.isMultipleChoice)
        return YES;
    
    if (self.currentQuestion.isActionRequired)
        return YES;
    
    if (self.currentQuestion.isNoticeMessage)
        return YES;
    
    if (self.currentQuestion.isCredentials) {
        /*
         where <encoded_credentials> is the base-64 encoding of the string:
         <username>:<password>
         */
        NSString *a = self.answerFieldA.text != nil ? self.answerFieldA.text : @"";
        NSString *b = self.answerFieldB.text != nil ? self.answerFieldB.text : @"";
        if ( (a.length > 0) && (b.length > 0) )
            return YES;
        return NO;
    }
    
    if (self.answerField.text.length > 0)
        return YES;
    
    return NO;
}

- (void)refreshButton {
    BOOL ok = [self checkDataToAnwser];
    [[self.toolbarView.items lastObject] setEnabled:ok];
}

- (void)refreshButtonWithText:(NSString*)text {
    NSString *trim = [text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL enabled = (trim.length > 0);
    [[self.toolbarView.items lastObject] setEnabled:enabled];
}

- (void)refreshButtonWithText:(NSString*)text1 andText:(NSString*)text2 {
    NSString *trim1 = [text1 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *trim2 = [text2 stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    BOOL enabled = ( (trim1.length > 0) && (trim2.length > 0) );
    [[self.toolbarView.items lastObject] setEnabled:enabled];
}

#pragma mark - UIPickerViewDataSource
// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView { return 1; }

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.currentQuestion pickerRowCount];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return [self.currentQuestion pickerTitleForRow:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    self.pickedValue = [self.currentQuestion pickerValueForRow:row];
    self.currentQuestion.answer = self.pickedValue;
}

#pragma mark - UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSString *newText = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.currentQuestion.isCredentials) {
        NSString *text2 = nil;
        if (textField == self.answerFieldA) {
            text2 = self.answerFieldB.text;
        } else if (textField == self.answerFieldB) {
            text2 = self.answerFieldA.text;
        }
        [self refreshButtonWithText:newText andText:text2];
    } else {
        [self refreshButtonWithText:newText];
    }
    return YES;
}

// called when 'return' key pressed. return NO to ignore.
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    BOOL done = NO;
    if (textField == self.answerField) {
        done = YES;
    } else if (textField == self.answerFieldB) {
        done = YES;
    } else if (textField == self.answerFieldA) {
        [self.answerFieldB becomeFirstResponder];
    }
    if (done) {
        // TODO: clicking "Done" in keyboard should click "Done" button in toolbar.
        // but we need to merge QuestionPanel with QuestionsController.
        [textField resignFirstResponder];
        [self performSelectorOnMainThread:@selector(done:) withObject:textField waitUntilDone:NO];
    }
    return !done;
}

#pragma mark - Actions

- (IBAction)cancel:(id)sender {
    [self dismissQuestionPanel];
}

- (IBAction)done:(id)sender {
    if (![self checkDataToAnwser])
        return;
    
    if (self.currentQuestion.isActionRequired) {
        [self.connection refetch];
        [self dismissQuestionPanel];
        return;
    }
    
    if (!self.currentQuestion.isReadOnly || self.currentQuestion.isNoticeMessage) {
        self.currentQuestion.answer = self.answerText;
        [self.answeredQuestions addObject:self.currentQuestion ];
        NSInteger nextQuestionId = [self nextQuestionId];
        if (nextQuestionId != self.currentQuestion.uniqueId) {
            __block NSArray *answeredQuestions = self.answeredQuestions;
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                AnswerQuestionOperation *op = [[AnswerQuestionOperation alloc] initWithAnsweredQuestions:answeredQuestions];
                [[FTSession sharedSession] enqueueHTTPRequestOperation:op];
            });
            self.answeredQuestions = [NSMutableArray arrayWithCapacity:4];
            [self.connection answeredEverything];
        }
    }
    
    if (![self setNextQuestion:YES]) {
        [self dismissQuestionPanel];
    } else {
        [self refreshButton];
    }
}

#pragma mark - UIPopoverControllerDelegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self dismissQuestionPanel];
}

#define USE_TABLE_VIEW  0

#if USE_TABLE_VIEW
#pragma mark - UITableViewDataSource methods

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberRows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    switch (indexPath.row) {
        case kQCLabelRow: {
            NSString  *kCellIdentifier = @"QCLabelCell";
            cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kCellIdentifier];
                cell.textLabel.text = self.currentQuestion.label;
                //        cell.imageView.image = self.connection.iconURL
            }
        }
        break;
        case kQCInputRow: {
            NSString  *kCellIdentifier = @"QCInputCell";
            cell = [tableView dequeueReusableCellWithIdentifier:kCellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:8888 reuseIdentifier:kCellIdentifier];
//                cell.textLabel.text = self.currentQuestion.label;
//                if (cell.detailTextLabel) {
                CGRect frame = CGRectInset(cell.frame, 2, 2);
                UITextField *textField = [[UITextField alloc] initWithFrame:frame];
                [cell.contentView addSubview:textField];
                [cell.contentView bringSubviewToFront:textField];
                [textField becomeFirstResponder];
                //        cell.imageView.image = self.connection.iconURL
            }
        }
        break;
    }
    
    return cell;
}

// fixed font style. use custom view (UILabel) if you want something different
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.currentQuestion.header;
}

#endif

//Cuong
#pragma mark - Toolbar Adjustment
- (UIBarPosition)positionForBar:(id <UIBarPositioning>)bar {
    return UIBarPositionTopAttached;
}
@end
