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
#import "UIButton+Toggle.h"
#import "AskerViewController.h"

#define MyRole_Fighter 0xFFFFFFFF

@interface HomeViewController() <GKMatchmakerViewControllerDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (weak, nonatomic) IBOutlet UIButton *askButton;
@property (weak, nonatomic) IBOutlet UIButton *disconnectButton;
@property (weak, nonatomic) IBOutlet UIButton *instructorButton;
@property (weak, nonatomic) IBOutlet UILabel *topLabel;

@property (nonatomic, strong) GKMatch *match;

@property (strong, nonatomic) IBOutlet UIBarButtonItem *cancelBarButtonItem;
@property(nonatomic, strong) UIActivityIndicatorView *spinner;
@end


@implementation HomeViewController
@synthesize startButton = _startButton;
@synthesize askButton = _askButton;
@synthesize disconnectButton = _disconnectButton;
@synthesize instructorButton = _instructorButton;
@synthesize topLabel = _topLabel;
@synthesize cancelBarButtonItem = _cancelBarButtonItem;
@synthesize match = _match;

@synthesize spinner = _spinner;

- (void)showInstructorUI { [self performSegueWithIdentifier:@"showInstructor" sender:nil]; }


- (void)setUpGameWithMode:(UserMode)mode
{
    if(mode == UserModeInstructor)
    {
        [self.startButton setTitle: @"Start CS193P" forState:UIControlStateNormal];
        self.instructorButton.hidden = NO;
        [self.instructorButton toggleEnabled];
    }
    else if(mode ==UserModeStudent)
    {
        [self.startButton setTitle:@"Join CS193P" forState:UIControlStateNormal];
        [self.startButton.titleLabel setNeedsDisplay];
        self.instructorButton.hidden = YES;
    }
    self.startButton.hidden = NO;
    
}
- (IBAction)testAsker:(id)sender {
    AskerViewController *asker = [self.storyboard instantiateViewControllerWithIdentifier:@"asker"];
    asker.answers = [NSArray arrayWithObjects:@"Answer 1", @"Answer 2", @"Answer 3", @"Answer 4", nil];
    asker.timeLeft = 30;
    asker.questionTitle = @"Test Question";
    asker.prompt = @"Choose an answer on this cool app.";
    [self presentModalViewController:asker animated:YES];
}

#pragma mark - UI adjustments for match/search state

- (IBAction)disconnect:(UIButton *)sender {
    [GKMatchHandler sharedHandler].match.delegate = nil;
    [GKMatchHandler sharedHandler].match = nil;
    
    [self.startButton toggleEnabled];
    //[self.askButton toggleDisabled];
    [self.disconnectButton toggleDisabled];
}
- (IBAction)cancel:(id)sender {
    [[GKMatchmaker sharedMatchmaker] cancel];
    self.navigationItem.leftBarButtonItem = nil;
    [self.spinner stopAnimating];
    
    [self.startButton toggleEnabled];
    [self.disconnectButton toggleDisabled];
}
- (void)matchFound
{
    [self.startButton toggleDisabled];
    [self.askButton toggleEnabled];
    [self.disconnectButton toggleEnabled];
    
    self.navigationItem.leftBarButtonItem = nil;
    [self.spinner stopAnimating];
}
- (void)searchingForMatch
{
    [self.startButton toggleDisabled];
    //[self.askButton toggleDisabled];
    [self.disconnectButton toggleDisabled];
    
    self.navigationItem.leftBarButtonItem = self.cancelBarButtonItem;
    [self.spinner startAnimating];
}

#pragma mark - Getting the Match

- (void) authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            // Perform additional tasks for the authenticated player.
            self.topLabel.text = @"Welcome to CS193P.";
            NSLog(@"Player {%@} Authenticated!",localPlayer.alias);
            [self.startButton toggleEnabled];
        }
        
        else if(error.code != 7)
        {
            [[[UIAlertView alloc] initWithTitle:@"Gamecenter Required" message:@"Please log in to game center to connect to the class." delegate:nil cancelButtonTitle:@"OK. Ya, I'm an idiot." otherButtonTitles: nil] show];
            NSLog(@"Could not authenticate local player");
            NSLog(@"%@",error);
        }
    }];
}

- (IBAction)findProgrammaticMatch: (UIButton *) sender
{
    [self searchingForMatch];
    GKMatchRequest *request = [[GKMatchRequest alloc] init];
    request.minPlayers = 2;
    request.maxPlayers = 4;
    
    [[GKMatchmaker sharedMatchmaker] findMatchForRequest:request withCompletionHandler:^(GKMatch *match, NSError *error) {
        if (error)
        {
            // Process the error.
            //[[[UIAlertView alloc] initWithTitle:@"No classes." message:@"An open class could not be found." delegate:nil cancelButtonTitle:@"Awww man" otherButtonTitles: nil] show];
            [self.startButton toggleEnabled];
            
        }
        else if (match != nil)
        {
            
            [GKMatchHandler sharedHandler].match = match; // Use a retaining property to retain the match.
            match.delegate = [GKMatchHandler sharedHandler];
            if (![GKMatchHandler sharedHandler].matchStarted && match.expectedPlayerCount == 0)
            {
                [GKMatchHandler sharedHandler].matchStarted = YES;
                // Insert application-specific code to begin the match.
                [[[UIAlertView alloc] initWithTitle:@"Welcome" message:@"Welcome to CS193P." delegate:nil cancelButtonTitle:@"Cool" otherButtonTitles: nil] show];
            }
            [self matchFound];
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
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.spinner];
    self.navigationItem.leftBarButtonItem = nil;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if(![GKLocalPlayer localPlayer].isAuthenticated){
        self.topLabel.text = @"Please log into game center.";
        [self authenticateLocalPlayer];
    }
    GKMatch *match = [GKMatchHandler sharedHandler].match;
    
    
    //Configure Buttons
    BOOL startButtonShouldBeEnabled = (!match || match.expectedPlayerCount)  && [GKLocalPlayer localPlayer].isAuthenticated;
    BOOL askButtonShouldBeEnabled = [GKMatchHandler sharedHandler].userMode == UserModeInstructor;
    BOOL disconnectButtonShouldBeEnabled = (BOOL)match;

    
    startButtonShouldBeEnabled ? [self.startButton toggleEnabled] : [self.startButton toggleDisabled];
    
    askButtonShouldBeEnabled ? [self.askButton toggleEnabled] : [self.askButton toggleDisabled];
    
    disconnectButtonShouldBeEnabled ? [self.disconnectButton toggleEnabled] : [self.disconnectButton toggleDisabled];
    
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
    [self setCancelBarButtonItem:nil];
    [super viewDidUnload];
}
@end
