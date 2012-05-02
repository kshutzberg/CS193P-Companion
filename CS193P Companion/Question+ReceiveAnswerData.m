//
//  Question+ReceiveAnswerData.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/8/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Question+ReceiveAnswerData.h"
#import "DataMessage.h"

@implementation Question (ReceiveAnswerData)

+ (void)updateQuestion:(Question *)question voteForAnswerIndex:(int)voteIndex nullifyingVoteForAnswerIndex:(int)nullifyIndex
{
    if(voteIndex < question.answers.count){
        Answer *answer = [question.answers objectAtIndex:voteIndex];
        answer.numPeople++;
    }
    else NSLog(@"Invalid answer chosen.");
    
    if(nullifyIndex < question.answers.count && nullifyIndex >= 0){
        Answer *answer = [question.answers objectAtIndex:nullifyIndex];
        answer.numPeople--;
    }
    else if(nullifyIndex != NSNotFound) NSLog(@"Invalid answer to nullify.");
    
    [question.managedObjectContext save:NULL];
    
}

@end
