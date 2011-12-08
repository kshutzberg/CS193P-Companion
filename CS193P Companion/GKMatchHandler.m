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
#import "QuestionMessage.h"

@implementation GKMatchHandler
@synthesize match = _match;
@synthesize matchStarted = _matchStarted;
@synthesize currentQuestion = _currentQuestion;

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

#pragma mark - Match delegate

-(void)match:(GKMatch *)match didReceiveData:(NSData *)data fromPlayer:(NSString *)playerID
{
    NSDictionary *message = [NSPropertyListSerialization propertyListFromData:data
                                                                mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                          format:NULL
                                                                errorDescription:NULL];
    NSString *messageType = [message valueForKey:OBJECT_TYPE];
    if([messageType isEqualToString:TYPE_QUESTION] && self.userMode == UserModeStudent)
    {
        [(CS193PAppDelegate *)[UIApplication sharedApplication].delegate displayQuestionWithInfo:message];
    }
    
    else if([messageType isEqualToString:TYPE_ANSWER] && self.userMode == UserModeInstructor)
    {
        [QuestionMessage updateQuestion:self.currentQuestion withAnswerMessage:message];
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
                [[[UIAlertView alloc] initWithTitle:@"Connection Regained" message:@"We found another player.  Game on!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            }
        }
    }];
}


- (void)match:(GKMatch *)match player:(NSString *)playerID didChangeState:(GKPlayerConnectionState)state
{
    switch (state)
    {
        case GKPlayerStateConnected:
            // handle a new player connection.
            
            break;
        case GKPlayerStateDisconnected:
            [[[UIAlertView alloc] initWithTitle:@"Connection Lost" message:@"Waiting for Players to connect to the session..." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil] show];
            
            [self addPlayersToMatch];
            break;
    }
    if (!self.matchStarted && match.expectedPlayerCount == 0)
    {
        self.matchStarted = YES;
        // handle initial match negotiation.
        [[[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Welcome to CS193P." delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles: nil] show];
    }
}



@end
