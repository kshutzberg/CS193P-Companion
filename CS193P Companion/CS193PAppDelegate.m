//
//  CS193PAppDelegate.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/28/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "CS193PAppDelegate.h"
#import <GameKit/GameKit.h>
#import "AskerViewController.h"
#import "QuestionMessage.h"

@implementation CS193PAppDelegate

@synthesize window = _window;

- (void) authenticateLocalPlayer
{
    GKLocalPlayer *localPlayer = [GKLocalPlayer localPlayer];
    [localPlayer authenticateWithCompletionHandler:^(NSError *error) {
        if (localPlayer.isAuthenticated)
        {
            // Perform additional tasks for the authenticated player.
            NSLog(@"Player {%@} Authenticated!",localPlayer.alias);
        }
        
        else
        {
            [[[UIAlertView alloc] initWithTitle:@"Gamecenter Required" message:@"Please log in to game center to connect to the class." delegate:nil cancelButtonTitle:@"OK. Ya, I'm an idiot." otherButtonTitles: nil] show];
            NSLog(@"Could not authenticate local player");
            NSLog(@"%@",error);
        }
    }];
}

- (void)displayQuestionWithInfo:(NSDictionary *)info
{
    UIViewController *root = self.window.rootViewController;
    if(root.presentedViewController)
        [root dismissModalViewControllerAnimated:NO];
    
    AskerViewController *asker = [root.storyboard instantiateViewControllerWithIdentifier:@"asker"];
    asker.answers = [info valueForKey:ANSWERS];
    asker.promptLabel.text = [info valueForKey:PROMPT];
    asker.titleLabel.text = [info valueForKey:QUESTION_NAME]; 
    [root presentModalViewController: asker animated:YES];
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    //[self authenticateLocalPlayer];
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
