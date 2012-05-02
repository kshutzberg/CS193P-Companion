//
//  Question+ReceiveAnswerData.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/8/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Question.h"

@interface Question (ReceiveAnswerData)

+ (void)updateQuestion:(Question *)question voteForAnswerIndex:(int)voteIndex nullifyingVoteForAnswerIndex:(int)nullifyIndex;

@end
