//
//  DataMessage.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Question.h"
#import "Entities+Create.h"

@interface DataMessage : NSObject

//Message Type IdentificationKey
#define MESSAGE_TYPE @"message_type"

#define TYPE_QUESTION @"questionType"
#define TYPE_ANSWER @"answerType"
#define TYPE_INSTRUCTOR_ID @"instructoridType"

//Question message constants
#define QUESTION_NAME @"questionName"
#define PROMPT @"prompt"
#define TIME @"time"
#define ANSWERS @"answers"

//Answer message constants
#define ANSWER_INDEX @"answerIndex"

//Instructor ID message constants
#define INSTRUCTOR_ID @"instructor_id"


+ (NSData *)dataWithQuestion:(Question *)question;
+ (NSData *)dataWithAnswerIndex:(NSUInteger)index;
+ (NSData *)dataWithInstructorID:(NSString *)instructorID;

@end

