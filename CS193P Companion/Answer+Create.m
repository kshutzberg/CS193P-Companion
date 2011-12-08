//
//  Answer+Create.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Entities+Create.h"

@implementation Answer (Create)

+ (Answer *)nextAnswerForQuestion:(Question *)question
{
    NSManagedObjectContext *context = question.managedObjectContext;
    NSUInteger count = [question.answers count];
    NSString *answer = [NSString stringWithFormat:@"Answer (%c)",'A' + count % 26];
    return [Answer answerWithString:answer inContext:context];
    
}

+ (Answer *)answerWithString:(NSString *)text inContext:(NSManagedObjectContext *)context
{
    //Add the Answer to the context
    Answer * answer = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_ANSWER inManagedObjectContext:context];
    
    //Initialize Attributes
    answer.answerText = text;
    answer.numPeople = 0; //arc4random()%10;

    return answer;
}

+ (NSArray *)answersFromStrings:(NSArray *)answers inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *retVal = [[NSMutableArray alloc] init];
    for (NSString *answer in answers) {
        [retVal addObject:[self answerWithString:answer inContext:context]];
    }
    
    return retVal;
}

@end
