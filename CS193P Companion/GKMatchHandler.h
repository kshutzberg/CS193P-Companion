//
//  GKMatchHandler.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/5/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "Question.h"

@interface GKMatchHandler : NSObject <GKMatchDelegate>
@property (nonatomic, strong) GKMatch *match;
@property (nonatomic) BOOL matchStarted;

@property (nonatomic, copy) NSString *instructorID;


//Must set this when asking a question so that everyone in the match is on the same page about what the current Question is (i.e. when answer messages come in they can be added to the right question).  

@property (nonatomic, strong) Question *currentQuestion;
@property (nonatomic, strong) NSDate *questionExpirationDate;
//This works because there will at most be only one question asked at once, and it would be illogical to ask more than one question or ask a question any other way.


#import "UserMode.h"
//User Mode: STUDENT or INSTRUCTOR.
@property (readonly) UserMode userMode;

+ (GKMatchHandler*)sharedHandler;

@end
