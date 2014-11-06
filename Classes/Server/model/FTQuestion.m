//
//  FTQuestion.m
//  FileThis
//
//  Created by Drew Wilson on 10/26/12.
//
//

#import "FTQuestion.h"
#import "CommonFunc.h"

@interface FTQuestion ()

@property (nonatomic,strong) NSString *title;
@property (nonatomic,strong) NSString *header;
@property (nonatomic,strong) NSArray *choices;
@property (readonly) NSString *state;

@end

/*
 
 {"questions": [
    {"id":405,"connectionId":230,"type":"user_action_required","state":"pending"},
    {"id":441,"connectionId":198,"type":"user_locked_out","state":"pending"},
    {"id":450,"connectionId":197,"type":"credentials","state":"pending"},{"id":503,"connectionId":791,"type":"credentials","state":"pending"},{"id":506,"connectionId":794,"type":"credentials","state":"pending"},{"id":509,"connectionId":1048,"type":"two_letter_state","state":"pending"}]}
 
 */

/*
 
 simple
 
 This type of question has a "data" property whose value is the text of a question to pose to the user. Use this as your prompt text.
 
 Provide a simple text field into which the user can type his answer.
 
 The answer string (sent by your subsequent "questionanswer" request) should be of the form:
 
 {"key": "pin", "value": "<answer>"}
 
 where <answer> is what the user entered.
 
 
 complex
 
 Let's leave this one for later. Ping me again, when you've got the other question types done.
 
 
 credentials
 
 This type of question has no "data" property.
 
 You can use the prompt text:
 
 Please enter your credentials
 
 You need to present the user with username and password fields.
 
 The answer string should be JSON of the form:
 
 {"key": "credentials", "value": "<encoded_credentials>"}
 
 where <encoded_credentials> is the base-64 encoding of the string:
 
 <username>:<password>
 
 where <username> and <password> are what the user entered in your dialog.
 
{"key": "credentials", "value": "ZHJld213aWxzb25Ac3RhbmZvcmRhbHVtbmkub3JnOmVsbGExOTk3"} 
{"key": "credentials", "value": "ZHJld213aWxzb25Ac3RhbmZvcmRhbHVtbmkub3JnOmVsbGExOTk3"} 
 
 two_letter_state
 
 This type of question has no "data" property.
 
 You can use the prompt text:
 
 Please select your state
 
 and present a popup/spinner that has all the US states (with full names).
 
 The answer string should be of the form:
 
 {"key": "state", "value": "<two_letter_state>"}
 
 where <two_letter_state> is the uppercase two-letter abbreviation for the chosen state.
 
 Note: If you'd like a page of text that has mappings from the abbreviations to the full names, let me know and I'll send it to you.
 
 
 branch_code
 
 This type of question has no "data" property.
 
 You can use the prompt text:
 
 Please enter your branch code
 
 and provide a simple text field into which the user can type his answer.
 
 The answer string should be of the form:
 
 {"key": "pin", "value": "<branch_code>"}
 
 where <branch_code> is what the user entered.
 
 
 pin
 
 This type of question has no "data" property.
 
 You can use the prompt text:
 
 Please enter your PIN
 
 and provide a simple text field into which the user can type his answer.
 
 The answer string should be of the form:
 
 {"key": "pin", "value": "<pin>"}
 
 where <pin> is what the user entered.
 
 
 not_supported
 
 Does not require an answer.
 
 Display the string:
 
 FileThis currently does not support this type of account for this institution.
 
 
 not_paperless
 
 Does not require an answer.
 
 Display the string:
 
 Before we can retrieve your documents, you need to log in to your account directly from your browser and sign up to "go paperless."
 
 
 user_locked_out
 
 Does not require an answer.
 
 Display the string:
 
 Your account is locked. Please log into your account directly to unlock it.
 
 
 user_must_set_up_account
 
 Does not require an answer.
 
 Display the string:
 
 You must set up your account profile. Please log into your account directly to do so.
 
 
 user_action_required
 
 Does not require an answer.
 
 Display the string:
 
 Please log into your account directly and respond to the question you are being asked there.
 
 
 general_security_problem
 
 Does not require an answer.
 
 Display the string:
 
 There is a general security problem in your account. Please log into your account directly to resolve it.
 
*/

@implementation FTQuestion

- (id)initWithDictionary:(NSDictionary *)dictionary {
#ifdef ENABLE_NSLOG_REQUEST
    NSLog(@"init question with %@", dictionary);
#endif
    if (self = [super init]) {
        self.isNoticeMessage = NO;
        
        if ([dictionary isKindOfClass:[NSDictionary class]]) {
            //NSAssert1(dictionary[@"data"] == nil, @"questions dictionary should not contain data key", dictionary);
            _type = dictionary[@"type"];
            _state = dictionary[@"state"];
            _title = dictionary[@"title"];
            _header = dictionary[@"header"];
            _uniqueId = [dictionary[@"id"] integerValue];
            _connectionId = [dictionary[@"connectionId"] integerValue];
            
            NSDictionary *defaultValues = [self defaultValuesForQuestionType:self.type];
            self.key = dictionary[@"key"];
            if (self.key == nil)
                self.key = defaultValues[@"key"];
            if (self.key.length == 0)
                self.key = nil;
            
            self.label = dictionary[@"label"];
            if (self.label == nil)
                self.label = defaultValues[@"prompt"];
            if (self.label.length == 0)
                self.label = nil;
            // This is really just useful for Chase account verification where
            // we get sent back a title, header, and label. For now we just munge
            // them all together.
            if (self.header != nil)
                self.label = [NSString stringWithFormat:@"%@\n%@\n%@",
                              stringNotNil(self.title), stringNotNil(self.header), stringNotNil(self.label)];
            
            self.choices = dictionary[@"choices"];
            if (self.choices == nil)
                self.choices = defaultValues[@"choices"];
        }
    }
    
    return self;
}

- (void)addInformationWithDictionary:(NSDictionary*)dictionary { //Loc Cao
    _type = dictionary[@"type"];
    _state = dictionary[@"state"];
    _uniqueId = [dictionary[@"id"] integerValue];
    _connectionId = [dictionary[@"connectionId"] integerValue];
    
    NSDictionary *defaultValues = [self defaultValuesForQuestionType:self.type];
    self.key = dictionary[@"key"];
    if (self.key == nil)
        self.key = defaultValues[@"key"];
    if (self.key.length == 0)
        self.key = nil;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"%@ #%ld %@/%@",
            [super description], (long)self.uniqueId, self.type, self.state];
}

- (NSDictionary *)defaultValuesForQuestionType:(NSString *)questionType {
    static NSDictionary *sDefaultValues = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *displayValuesFile = [[NSBundle mainBundle] pathForResource:@"FTQuestion" ofType:@"plist"];
        if (displayValuesFile == nil)
            displayValuesFile = [[NSBundle mainBundle] pathForResource:@"FTQuestion" ofType:@".plist"];
        sDefaultValues = [[NSDictionary alloc] initWithContentsOfFile:displayValuesFile];
    });

    if (!questionType) questionType = @"unknown";
    NSDictionary *values = sDefaultValues[questionType];
    if (!values) {
        // unknown question type...
        values = @{@"key" : questionType};
    }
    
    return values;
}

- (BOOL)isReadOnly {
    NSString *key = [self key];
    BOOL readOnly = key == nil || [key length] == 0;
    return readOnly;
}

- (BOOL)isCredentials {
    return [self.type isEqualToString:@"credentials"];
}

- (BOOL)isActionRequired {
    return [self.type isEqualToString:@"user_action_required"];
}

//- (NSString *)type {
//    return (self.keyValues)[@"type"];
//}

//- (NSString *)label {
//    
//    NSString *localLabel = (self.keyValues)[@"label"];
//    if (localLabel == nil) {
//        localLabel = [self displayValues][@"prompt"];
//    }
//    return localLabel;
//}
//
//- (NSString *)key {
//    NSString *k = (self.keyValues)[@"key"];
//    if (k == nil) {
//        k = [self displayValues][@"key"];
//        if ([k length] == 0)
//            k = nil;
//    }
//    return k;
//}
//


#pragma  mark Picker methods
- (BOOL)isMultipleChoice {
    return self.choices != nil;
}

- (NSInteger)pickerRowCount {
    return [self.choices count];
}

- (NSString *)pickerTitleForRow:(NSInteger)row {
    NSDictionary *choice = self.choices[row];
    return choice[@"label"];
}

- (NSString *)pickerValueForRow:(NSInteger)row {
    NSDictionary *choice = self.choices[row];
    return choice[@"value"];
}

@end


/*
 
 Example data
 
 Chase question ("complex" type)
 {
 "questions": [{
 "id": 1317,
 "data": "{\"title\":\"Confirm Your Identity\",\"header\":\"Chase needs a one-time Identification Code to confirm that you own the accounts before FileThis can access them. Once you have the code we'll ask you to enter it on the next screen.\",\"questions\":[{\"type\":\"choice\",\"label\":\"How should Chase send you the Identification Code?\",\"key\":\"identificationCodeDeliveryMethod\",\"persistent\":false,\"choices\":[{\"value\":\"rdoSMSDelMethod0\",\"key\":\"usrCtrlOtp_rdoSMSDelMethod0\",\"label\":\"Text xxx-xxx-4328\"},{\"value\":\"rdoDelMethod0\",\"key\":\"usrCtrlOtp_rdoDelMethod0\",\"label\":\"Voice xxx-xxx-4328\"},{\"value\":\"rdoSMSDelMethod1\",\"key\":\"usrCtrlOtp_rdoSMSDelMethod1\",\"label\":\"Text xxx-xxx-7878\"},{\"value\":\"rdoDelMethod1\",\"key\":\"usrCtrlOtp_rdoDelMethod1\",\"label\":\"Voice xxx-xxx-7878\"},{\"value\":\"rdoSMSDelMethod2\",\"key\":\"usrCtrlOtp_rdoSMSDelMethod2\",\"label\":\"Text xxx-xxx-7059\"},{\"value\":\"rdoDelMethod2\",\"key\":\"usrCtrlOtp_rdoDelMethod2\",\"label\":\"Voice xxx-xxx-7059\"},{\"value\":\"rdoDelMethod3\",\"key\":\"usrCtrlOtp_rdoDelMethod3\",\"label\":\"Email b...n@pacbell.net\"}]}]}",
 "connectionId": 2986,
 "type": "complex",
 "state": "pending"
 }]
 }

*/

/*
 
 Ing. Direct security question
 
 (lldb) po questionsDictionary
 $30 = 0x0a3a5340 {
 connectionId = 2995;
 data = "{\"questions\":[{\"key\":\"What was the first live concert you attended?\",\"label\":\"What was the first live concert you attended?\",\"persistent\":true,\"type\":\"text\"}]}";
 id = 1332;
 state = pending;
 type = complex;
 }
 (lldb)
 
 (lldb) po json
 $29 = 0x0b8bca00 {
 questions =     (
 {
 key = "What was the first live concert you attended?";
 label = "What was the first live concert you attended?";
 persistent = 1;
 type = text;
 }
 );
 }
 
 
 
 (lldb) po questionsDictionary
 $2 = 0x1d1a76d0 {
 connectionId = 33271;
 data = "{\"title\":\"Confirm Your Identity\",\"header\":\"Chase needs a one-time Identification Code to confirm that you own the accounts before FileThis can access them. Once you have the code we'll ask you to enter it on the next screen.\",\"questions\":[{\"type\":\"choice\",\"label\":\"How should Chase send you the Identification Code?\",\"key\":\"identificationCodeDeliveryMethod\",\"persistent\":false,\"choices\":[{\"value\":\"rdoSMSDelMethod0\",\"key\":\"usrCtrlOtp_rdoSMSDelMethod0\",\"label\":\"Text xxx-xxx-4328\"},{\"value\":\"rdoDelMethod0\",\"key\":\"usrCtrlOtp_rdoDelMethod0\",\"label\":\"Voice xxx-xxx-4328\"},{\"value\":\"rdoSMSDelMethod1\",\"key\":\"usrCtrlOtp_rdoSMSDelMethod1\",\"label\":\"Text xxx-xxx-7878\"},{\"value\":\"rdoDelMethod1\",\"key\":\"usrCtrlOtp_rdoDelMethod1\",\"label\":\"Voice xxx-xxx-7878\"},{\"value\":\"rdoSMSDelMethod2\",\"key\":\"usrCtrlOtp_rdoSMSDelMethod2\",\"label\":\"Text xxx-xxx-7059\"},{\"value\":\"rdoDelMethod2\",\"key\":\"usrCtrlOtp_rdoDelMethod2\",\"label\":\"Voice xxx-xxx-7059\"},{\"value\":\"rdoDelMethod3\",\"key\":\"usrCtrlOtp_rdoDelMethod3\",\"label\":\"Email b...n@pacbell.net\"}]}]}";
 id = 52011;
 state = pending;
 type = complex;
 }
 
 
 (lldb) po JSON
 $6 = 0x1d182c60 {
 questions =     (
 {
 connectionId = 33271;
 data = "{\"title\":\"Confirm Your Identity\",\"header\":\"Chase needs a one-time Identification Code to confirm that you own the accounts before FileThis can access them. Once you have the code we'll ask you to enter it on the next screen.\",\"questions\":[{\"type\":\"choice\",\"label\":\"How should Chase send you the Identification Code?\",\"key\":\"identificationCodeDeliveryMethod\",\"persistent\":false,\"choices\":[{\"value\":\"rdoSMSDelMethod0\",\"key\":\"usrCtrlOtp_rdoSMSDelMethod0\",\"label\":\"Text xxx-xxx-4328\"},{\"value\":\"rdoDelMethod0\",\"key\":\"usrCtrlOtp_rdoDelMethod0\",\"label\":\"Voice xxx-xxx-4328\"},{\"value\":\"rdoSMSDelMethod1\",\"key\":\"usrCtrlOtp_rdoSMSDelMethod1\",\"label\":\"Text xxx-xxx-7878\"},{\"value\":\"rdoDelMethod1\",\"key\":\"usrCtrlOtp_rdoDelMethod1\",\"label\":\"Voice xxx-xxx-7878\"},{\"value\":\"rdoSMSDelMethod2\",\"key\":\"usrCtrlOtp_rdoSMSDelMethod2\",\"label\":\"Text xxx-xxx-7059\"},{\"value\":\"rdoDelMethod2\",\"key\":\"usrCtrlOtp_rdoDelMethod2\",\"label\":\"Voice xxx-xxx-7059\"},{\"value\":\"rdoDelMethod3\",\"key\":\"usrCtrlOtp_rdoDelMethod3\",\"label\":\"Email b...n@pacbell.net\"}]}]}";
 id = 52011;
 state = pending;
 type = complex;
 }
 );
 }
 (lldb)
 
 2013-07-17 13:41:35.957 FileThis Fetch[6295:907] init question with {
 choices = (
 {
 key = "usrCtrlOtp_rdoSMSDelMethod0";
 label = "Text xxx-xxx-4328";
 value = rdoSMSDelMethod0;
 },
 {
 key = "usrCtrlOtp_rdoDelMethod0";
 label = "Voice xxx-xxx-4328";
 value = rdoDelMethod0;
 },
 {
 key = "usrCtrlOtp_rdoSMSDelMethod1";
 label = "Text xxx-xxx-7878";
 value = rdoSMSDelMethod1;
 },
 {
 key = "usrCtrlOtp_rdoDelMethod1";
 label = "Voice xxx-xxx-7878";
 value = rdoDelMethod1;
 },
 {
 key = "usrCtrlOtp_rdoSMSDelMethod2";
 label = "Text xxx-xxx-7059";
 value = rdoSMSDelMethod2;
 },
 {
 key = "usrCtrlOtp_rdoDelMethod2";
 label = "Voice xxx-xxx-7059";
 value = rdoDelMethod2;
 },
 {
 key = "usrCtrlOtp_rdoDelMethod3";
 label = "Email b...n@pacbell.net";
 value = rdoDelMethod3;
 }
 );
 connectionId = 33271;
 id = 52011;
 key = identificationCodeDeliveryMethod;
 label = "How should Chase send you the Identification Code?";
 persistent = 0;
 state = pending;
 type = choice;
 }
 
 */

