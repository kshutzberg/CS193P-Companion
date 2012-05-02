//
//  GKMatchHandler.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/5/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "GKMatchHandler.h"
#import "DataMessage.h"
#import "CS193PAppDelegate.h"
#import "Question+ReceiveAnswerData.h"


@interface GKMatchHandler()
@property (nonatomic, strong) NSMutableDictionary *playerAnswers;
@end

@implementation GKMatchHandler
@synthesize match = _match;
@synthesize matchStarted = _matchStarted;

@synthesize instructorID = _instructorID;
@synthesize currentQuestion = _currentQuestion;
@synthesize questionExpirationDate = _questionExpirationDate;

@synthesize playerAnswers = _playerAnswers;

static GKMatchHandler *sharedGKHandler = nil;

+ (GKMatchHandler*)sharedHandler
{
    if (sharedGKHandler == nil) {
        sharedGKHandler = [[super allocWithZone:NULL] init];
    }
    return sharedGKHandler;
}

+ (id)allocWithZone:(NSZone *)zone { return [self sharedHandler]; }
- (id)copyWithZone:(NSZone *)zone { return self; }

- (UserMode)userMode
{
    return (UserMode)[[[NSUserDefaults standardUserDefaults] objectForKey:USER_MODE] intValue];
}

- (void)broadcastInstructorID{
    if (!self.match || self.instructorID) {
        NSLog(@"Match: %@ | Instructor: %@", self.match, self.instructorID);
    }
    
    NSData *instructorData = [DataMessage dataWithInstructorID:self.instructorID];

    NSError *error;
    [self.match sendDataToAllPlayers:instructorData withDataMode:GKSendDataReliable error:&error];
    if(error)NSLog(@"Instructor ID could not be sent with error: {%@ : %@}",error.localizedFailureReason, error.localizedDescription);
}

- (void)setCurrentQuestion:(Question *)currentQuestion
{
    _currentQuestion = currentQuestion;
    self.playerAnswers = [NSMutableDictionary dictionary];
}
- (void)setMatch:(GKMatch *)match
{
    _match = match;
    if(self.userMode == UserModeInstructor && match){
        self.instructorID = [GKLocalPlayer localPlayer].playerID;
        [self broadcastInstructorID];
    }
}

- (void)addPlayersToMatch
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error)
        {
            // Process the error.
        }
        else if (match != nil)
        {
            self.match = match; // Use a retaining property to retain the match.
            match.delegate = self;
            if (!self.matchStarted && match.expectedPlayerCount == 0)
            {
                self.matchStarted = YES;
                // Insert application-specific code to begin the match.
                //[[[UIAlertView alloc] initWithTitle:@"Connection Regained" message:@"We found another player.  Game on!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }
    }];
}

#pragma mark - Match delegate

-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSDictionary *message = [NSPropertyListSerialization propertyListFromData:data
                                                                mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                          format:NULL
                                                                errorDescription:NULL];
    NSString *messageType = [message valueForKey:MESSAGE_TYPE];
    
    if([messageType isEqualToString:TYPE_QUESTION] && self.userMode == UserModeStudent)
    {
        
        [(CS193PAppDelegate *)[UIApplication sharedApplication].delegate displayQuestionWithInfo:message];
        //[(CS193PAppDelegate *)[UIApplication sharedApplication].delegate displayQuestionWithQuestion:question];
    }
    
    else if([messageType isEqualToString:TYPE_ANSWER] && self.userMode == UserModeInstructor)
    {
        NSNumber *previousAnswer = [self.playerAnswers objectForKey:playerID];
        int nullifyIndex = previousAnswer ? [previousAnswer intValue] : NSNotFound;
        int voteAnswer = [[message objectForKey:ANSWER_INDEX] intValue];
        
        [Question updateQuestion:self.currentQuestion voteForAnswerIndex:voteAnswer nullifyingVoteForAnswerIndex:nullifyIndex];
        BOOL multipleAnswers = [[[NSUserDefaults standardUserDefaults] objectForKey:@"multiple_answers"] boolValue];
        if(!multipleAnswers)[self.playerAnswers setObject:[NSNumber numberWithInt:voteAnswer] forKey:playerID];
        
    }
    else if([messageType isEqualToString:TYPE_INSTRUCTOR_ID]){
        self.instructorID = [message objectForKey:INSTRUCTOR_ID];
    }
}



- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    switch (state)
    {
        case GKPlayerStateConnected:
            // handle a new player connection.
            if(self.userMode == UserModeInstructor)[self broadcastInstructorID];
            
            break;
        case GKPlayerStateDisconnected:
            if (playerID == [GKLocalPlayer localPlayer].playerID) {
                if(self.matchStarted){
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:@"Connection with the class was lost." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                    [alert show];
                }
                self.matchStarted = NO;
                self.match = nil;
                [(CS193PAppDelegate *)[UIApplication sharedApplication].delegate returnHome];
                NSLog(@"Lost connection to GKMatch");
            }
            if([playerID isEqualToString:self.instructorID]){
                self.matchStarted = NO;
                [self.match disconnect];
                self.match = nil;
                [(CS193PAppDelegate *)[UIApplication sharedApplication].delegate returnHome];
                NSLog(@"Disconnecting because the instructor was lost.");
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:@"Connection with the instructor was lost." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
                [alert show];
            }
            break;
    }
    if (!self.matchStarted && match.expectedPlayerCount == 0)
    {
        self.matchStarted = YES;
        // handle initial match negotiation.
        //[[[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Welcome to CS193P." delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles: nil] show];
    }
}

-(void)match:(GKMatch *)match didFailWithError:(NSError *)error
{
    NSLog(@"Match failed with error: {%@ : %@}",error.localizedFailureReason, error.localizedDescription);
    [self.match disconnect];
}

-(BOOL)match:(GKMatch *)match shouldReinvitePlayer:(NSString *)playerID
{
    NSLog(@"Reinviting player: %@",playerID);
    return YES;
}



@end
