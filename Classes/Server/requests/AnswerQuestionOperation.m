//
//  AnswerQuestionOperation.m
//  FileThis
//
//  Created by Drew Wilson on 9/24/12.
//
//

#import <Crashlytics/Crashlytics.h>
#import "AnswerQuestionOperation.h"
#import "FTConnection.h"
#import "FTSession.h"

// POST /ftapi/ftapi?op=questionanswer&id=481&flex=true&ticket=Lv4jJZpf2yt0XP5jMg1mTiFRREn HTTP/1.1
// response: <result></result>
/*
 POST /ftapi/ftapi?op=questionanswer&id=481&flex=true&ticket=Lv4jJZpf2yt0XP5jMg1mTiFRREn HTTP/1.1
 Host: staging.filethis.com
 Connection: keep-alive
 Content-Length: 118
 Origin: https://staging.filethis.com
 User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/537.16 (KHTML, like Gecko) Chrome/24.0.1306.0 Safari/537.16
 Content-Type: application/json
 Accept: * / *
 Referer: https://staging.filethis.com/client/Main-0.5.swf
 Accept-Encoding: gzip,deflate,sdch
 Accept-Language: en-US,en;q=0.8
 Accept-Charset: ISO-8859-1,utf-8;q=0.7,*;q=0.3
 Cookie: __utma=68377350.83118826.1337242804.1346968713.1347053522.20; __utmc=68377350; __utmz=68377350.1337242804.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none); __utma=204825298.1201723894.1345771794.1348899320.1348938510.22; __utmc=204825298; __utmz=204825298.1345771794.1.1.utmcsr=(direct)|utmccn=(direct)|utmcmd=(none)
 
 [{"key": "In what city was your high school? (Enter only \"Charlotte\" for Charlotte High School)", "value": "Sitka"}]*/


/*
 
 
 POST /ftapi/ftapi?json=true&compact=false&ticket=IYdUaJNaRAbyxsE6U6fkVPEpQfm&op=questionanswer&id=143 HTTP/1.1
 Host	staging.filethis.com
 User-Agent	FileThis/1.2 CFNetwork/548.1.4 Darwin/12.2.0
 Content-Length	83
 Accept	* / *
Accept-Language	en-us
Accept-Encoding	gzip, deflate
Content-Type	application/x-www-form-urlencoded
Connection	keep-alive
Proxy-Connection	keep-alive
 
 */


/*
 https://staging.filethis.com/ftapi/ftapi?op=questionanswer&id=910&flex=true&ticket=32Nod3I0UD3R0PIio9Iw722j6ys
 
 [{"key": "What is your spouse's/significant other's father's first name?", "value": "Zohan"}, 
 {"key": "What was your first job?", "value": "Motorola"}]
 
*/


@implementation AnswerQuestionOperation

// take question Id, question key, question answer key pairs and encode as json and set as body data
- (id)initWithAnsweredQuestions:(NSArray *)answeredQuestions {
    
    NSMutableArray *answers = [NSMutableArray arrayWithCapacity:answeredQuestions.count];
    for (FTQuestion *question in answeredQuestions) {
        if (question.key != nil && question.answer != nil) {
            NSDictionary *params = @{ @"key" : question.key, @"value" : question.answer };
            [answers addObject:params];
        } else {
            //TFLog(@"answered question contains nil value? %@", answeredQuestions);
            CLS_LOG(@"AnswerQuestionOperation - answered question contains nil value? %@", answeredQuestions);
        }
    }
    id body = answers;
    if (answers.count == 1)
        body = answers[0];
    else if (answers.count == 0) {
        //TFLog(@"empty answers? %@", answeredQuestions);
        CLS_LOG(@"AnswerQuestionOperation - empty answers? %@", answeredQuestions);
    }
    NSError *error = NULL;
    NSAssert1([NSJSONSerialization isValidJSONObject:body], @"answers is valid JSON: %@", body);
    NSData *postData = [NSJSONSerialization dataWithJSONObject:body options:kNilOptions error:&error];
    CLS_LOG(@"Answered question with %@", [[NSString alloc] initWithData:postData encoding:NSUTF8StringEncoding]);

    NSInteger questionId = 0;
    if (answeredQuestions.count > 0) {
        FTQuestion *question = answeredQuestions[0];
        questionId = question.uniqueId;
    } else {
        //TFLog(@"empty answered questions? %@", answeredQuestions);
        CLS_LOG(@"AnswerQuestionOperation - empty answered questions? %@", answeredQuestions);
    }
    NSMutableURLRequest *req = [[FTSession sharedSession] requestForOperand:FTAnswerQuestionsForConnection withParams:@{ @"id" : @(questionId), @"flex" : @(YES) }];
    [req setHTTPBody:postData];
    [req setHTTPMethod:@"POST"];
    [req setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];

    self = [super initWithRequest:req];
    if (self != nil) {
        [self setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, NSDictionary *responseObject) {
            //NSAssert1([responseObject count] == 0, @"non-empty response:%@", responseObject);
            [[NSNotificationCenter defaultCenter] postNotificationName:FTAnsweredQuestion object:nil userInfo:nil];
        } failure:^(AFHTTPRequestOperation *operation, NSError *err) {
            [[FTSession sharedSession] handleError:err forOperation:operation withTitle:@"Cannot Save Verification"];
        }];
    }
     return self;
 }

@end
