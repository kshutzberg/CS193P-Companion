//
//  HomeViewController.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/2/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//
#import <GameKit/GameKit.h>
#import "HomeViewController.h"
#import "GKMatchHandler.h"
#import "QuestionMessage.h"
#import "UIButton+Toggle.h"

#define MyRole_Fighter 0xFFFFFFFF

@interface HomeViewController() <GKMatchmakerViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *instructorButton;
@property (nonatomic, strong) GKMatch *match;
@end


@implementation HomeViewController
@synthesize startButton = _startButton;
@synthesize disconnectButton = _disconnectButton;
@synthesize instructorButton = _instructorButton;
@synthesize match = _match;
- (IBAction)ping:(id)sender {
    
    NSError *error;
    
    //NSData *packet = [NSData dataWithBytes:(NSUInteger)object length:100];
    //[[GKMatchHandler sharedHandler].match sendDataToAllPlayers: packet withDataMode: GKMatchSendDataUnreliable error:&error];
    if (error != nil)
    {
        NSLog(@"%@",error.debugDescription);
    }
}
- (IBAction)disconnect:(UIButton *)sender {
    [GKMatchHandler sharedHandler].match.delegate = nil;
    [GKMatchHandler sharedHandler].match = nil;
    [self.disconnectButton toggleDisabled];
    [self.startButton toggleEnabled];
}

- (IBAction)findProgrammaticMatch: (UIButton *) sender
{
    [self.startButton toggleDisabled];
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error)
        {
            // Process the error.
            [[[UIAlertView alloc] initWithTitle:@"No classes." message:@"An open class could not be found." delegate:nil cancelButtonTitle:@"Awww man" otherButtonTitles: nil] show];
            [self.startButton toggleEnabled];
            
        }
        else if (match != nil)
        {
            
            [GKMatchHandler sharedHandler].match = match; // Use a retaining property to retain the match.
            match.delegate = [GKMatchHandler sharedHandler];
            [self.disconnectButton toggleEnabled];
            
            if (![GKMatchHandler sharedHandler].matchStarted && match.expectedPlayerCount == 0)
            {
                [GKMatchHandler sharedHandler].matchStarted = YES;
                // Insert application-specific code to begin the match.
                [[[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Welcome to CS193P." delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles: nil] show];
            }
        }
    }];
}

- (IBAction)hostMatch: (id) sender
{
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
    
    
    GKMatchmakerViewController *mmvc = [[GKMatchmakerViewController alloc] initWithMatchRequest:request];
    mmvc.matchmakerDelegate = self;
    
    [self presentModalViewController:mmvc animated:YES];
}
- (void)showInstructorUI
{
    [self performSegueWithIdentifier:@"showInstructor" sender:nil];
}

- (void)setUpGameWithMode:(UserMode)mode
{
    if(mode == UserModeInstructor)
    {
        self.startButton.titleLabel.text = @"Start CS193P";
        //[self.startButton addTarget:self action:@selector(showInstructorUI) forControlEvents:UIControlEventTouchUpInside];
    }
    else if(mode ==UserModeStudent)
    {
        self.startButton.titleLabel.text = @"Join CS193P";
        self.instructorButton.hidden = YES;
    }
    self.startButton.hidden = NO;

}

- (void) authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            // Perform additional tasks for the authenticated player.
            NSLog(@"Player {%@} Authenticated!",localPlayer.alias);
            [self.startButton toggleEnabled];
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Gamecenter Required" message:@"Please log in to game center to connect to the class." delegate:nil cancelButtonTitle:@"OK. Ya, I'm an idiot." otherButtonTitles: nil] show];
            NSLog(@"Could not authenticate local player");
            NSLog(@"%@",error);
        }
    }];
}

#pragma mark - Matchmaker view controller delegate

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFindMatch:(GKMatch *)match
{
    [self dismissModalViewControllerAnimated:YES];
    GKMatchHandler *handler = [GKMatchHandler sharedHandler];
    
    handler.match = match; // Use a retaining property to retain the match.
    self.match = match;
    match.delegate = handler;
    
    if (!handler.matchStarted && match.expectedPlayerCount == 0)
    {
        handler.matchStarted = YES;
        // Insert application-specific code to begin the match.
    }
}


- (void)matchmakerViewControllerWasCancelled:(GKMatchmakerViewController *)viewController
{
    [self dismissModalViewControllerAnimated:YES];
    // implement any specific code in your application here.
}

- (void)matchmakerViewController:(GKMatchmakerViewController *)viewController didFailWithError:(NSError *)error
{
    [self dismissModalViewControllerAnimated:YES];
    // Display the error to the user.
}



#pragma mark - Alert view delegate

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    UserMode mode;
    if (buttonIndex == 0) {
        mode = UserModeStudent;
    }
    else if(buttonIndex == 1){
        mode = UserModeInstructor;
    }
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:mode] forKey:USER_MODE];
    
    [[[UIAlertView alloc] initWithTitle:@"Congratulations!"
                                message:[NSString stringWithFormat:@"You are now logged in as a %@.  You can change this in the settings app at any time.",mode ? @"Instructor" : @"Student"]
                               delegate:nil
                      cancelButtonTitle:@"Ok. Cool."
                      otherButtonTitles: nil] show];
    
    [self setUpGameWithMode:mode];
    
}


#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    GKMatch *match = [GKMatchHandler sharedHandler].match;
    
    BOOL startButtonShouldBeEnabled = (!match || match.expectedPlayerCount)  && [GKLocalPlayer localPlayer].isAuthenticated;
    if(![GKLocalPlayer localPlayer].isAuthenticated)[self authenticateLocalPlayer];
    
    startButtonShouldBeEnabled ? [self.startButton toggleEnabled] : [self.startButton toggleDisabled];
    
    match ? [self.disconnectButton toggleEnabled] : [self.disconnectButton toggleDisabled];
    
    [self.navigationController setToolbarHidden:YES animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSNumber *mode = [defaults objectForKey:USER_MODE];
    
    if(!mode){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Welcome to CS193P" message:@"What type of user are you?" delegate:self cancelButtonTitle:nil otherButtonTitles:@"I am a student.", @"I am an instructor.", nil];
        [alert show];
    }
    else{
        UserMode userMode = [mode intValue];
        [self setUpGameWithMode:userMode];
    }
}


- (void)viewDidUnload {
    [self setStartButton:nil];
    [self setDisconnectButton:nil];
    [self setInstructorButton:nil];
    [super viewDidUnload];
}
@end
