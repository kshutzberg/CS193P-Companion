//
//  DataMessage.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "DataMessage.h"

@interface DataMessage()
@end

@implementation DataMessage

+ (void)serializeDataMoreEfficiently:(NSData *)data
{
    //f
}

+ (NSData *)dataWithQuestion:(Question *)question
{
    //NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:TYPE_QUESTION, OBJECT_TYPE, question.questionName, QUESTION_NAME, question.prompt, PROMPT, [NSDate dateWithTimeIntervalSinceNow: question.time], TIME, question.stringAnswers, ANSWERS, nil];
    
    NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
    
    //Set the type
    [dictionary setValue:TYPE_QUESTION forKey:MESSAGE_TYPE];
    
    //Add the questions attributes
    [dictionary addEntriesFromDictionary:[question dictionaryWithValuesForKeys:[[question.entity attributesByName] allKeys]]];
    //Set the expiration time
    //[dictionary setValue:[NSDate dateWithTimeIntervalSinceNow:question.time] forKey:TIME];
    
    //Add the answers:
    [dictionary setValue:question.stringAnswers forKey:ANSWERS];
    
    
    NSError *err;
    NSData *data =  [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:&err];
    if(err)NSLog(@"%@",err.debugDescription);
    
    return data;
}

+ (NSData *)dataWithAnswerIndex:(NSUInteger)index
{
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:TYPE_ANSWER,MESSAGE_TYPE, [NSNumber numberWithInt:index], ANSWER_INDEX, nil];
    
    return [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:NULL];
}

+ (NSData *)dataWithInstructorID:(NSString *)instructorID
{
    NSDictionary *dictionary = [[NSDictionary alloc] initWithObjectsAndKeys:TYPE_INSTRUCTOR_ID,MESSAGE_TYPE, instructorID , INSTRUCTOR_ID, nil];
    
    return [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:0 error:NULL];
}


@end


