//
//  GKMatchHandler.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/5/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "UserMode.h"
#import "Question.h"

@interface GKMatchHandler : NSObject <GKMatchDelegate>
@property (nonatomic, strong) GKMatch *match;
@property (nonatomic) BOOL matchStarted;
@property (nonatomic, strong) Question *currentQuestion; //Must set this when asking a question so that everyone in the match is on the same page about what the current Question is (i.e. when answer messages come in they can be added to the right question).

@property (readonly) UserMode userMode;

+ (GKMatchHandler*)sharedHandler;

@end
