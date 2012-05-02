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
    
    NSNumber *testResultsNum = [[NSUserDefaults standardUserDefaults] objectForKey:@"test_results"];
    if(!testResultsNum){
        testResultsNum = [NSNumber numberWithBool:YES];  // Default choice
    }
    BOOL testResults = [testResultsNum boolValue];
    answer.numPeople = testResults ? arc4random()%10 : 0;

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

- (NSNumber *)order
{
    return [NSNumber numberWithInt:[self.question.answers indexOfObject:self]];
}
@end
