//
//  QuestionsController.h
//  playground
//
//  Created by Drew Wilson on 10/9/12.
//  Copyright (c) 2012 Drew Wilson. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FTConnection.h"

@interface QuestionsController : UIViewController<UIPopoverControllerDelegate>

@property (strong,nonatomic, readonly) NSArray *questions;

+ (void) askQuestions:(NSArray *)questions
    fromViewController:(UIViewController *) vc
             fromRect:(CGRect)rect
        forConnection: (FTConnection *) connection
           withAction:(SEL) doneAction
     withCancelAction:(SEL) cancelAction;

@end
