//
//  QuestionMessage.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "QuestionMessage.h"
#import "Entities+Create.h"

@implementation QuestionMessage
@dynamic questionName;
@dynamic prompt;
@dynamic time;
@dynamic answers;

+ (QuestionMessage *)messageWithQuestion:(Question *)question
{
    QuestionMessage *message = [QuestionMessage message];
    [message setValue:question.questionName forKey:@"questionName"];
    NSLog(@"%@",message.questionName);
//    message.prompt = question.prompt;
//    message.time = [NSDate dateWithTimeIntervalSinceNow:question.time];
//    message.answers = [question numberAnswers]; 
    return message;
}


+ (NSData *)dataWithQuestion:(Question *)question
{
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:TYPE_QUESTION, OBJECT_TYPE, question.questionName, QUESTION_NAME, question.prompt, PROMPT, [NSDate dateWithTimeIntervalSinceNow: question.time], TIME, question.stringAnswers, ANSWERS, nil];
    
    NSError *err;
    NSData *data =  [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&err];
    if(err)NSLog(@"%@",err.debugDescription);
    return data;
}

+ (NSData *)dataWithAnswerIndex:(NSUInteger)index
{
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:TYPE_ANSWER,OBJECT_TYPE, [NSNumber numberWithInt:index], ANSWER_INDEX, nil];
    
    return [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:NULL];
}

+ (void)updateQuestion:(Question *)question withAnswerMessage:(NSDictionary *)message
{
    NSUInteger answerIndex = [[message valueForKey:ANSWER_INDEX] intValue];
    if(answerIndex < question.answers.count){
        Answer *answer = [question.answers objectAtIndex:answerIndex];
        answer.numPeople++;
        [question.managedObjectContext save:NULL];
    }
    else NSLog(@"Invalid answer chosen.");
}

@end