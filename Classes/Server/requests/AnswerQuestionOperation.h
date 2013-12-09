//
//  AnswerQuestionOperation.h
//  FileThis
//
//  Created by Drew Wilson on 9/24/12.
//
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import "FTConnection.h"
#import "FTQuestion.h"

@interface AnswerQuestionOperation : AFJSONRequestOperation

- (id) initWithAnsweredQuestions:(NSArray *)answeredQuestions;

@end
