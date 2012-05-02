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
#import "DataMessage.h"
#import "HomeViewController.h"
#import "GKMatchHandler.h"

@implementation CS193PAppDelegate

@synthesize window = _window;

- (void)returnHome{
    UIViewController *visableVC = [(UINavigationController *)self.window.rootViewController visibleViewController];
                                   
    self.window.rootViewController = [visableVC.storyboard instantiateInitialViewController];
}

- (void)displayQuestionWithInfo:(NSDictionary *)info
{
    UIViewController *visableVC = [(UINavigationController *)self.window.rootViewController visibleViewController];
    
    //If a question has just been asked, cancel it before displaying this one
    if([visableVC isKindOfClass:[AskerViewController class]])
        visableVC = visableVC.presentingViewController;
        [visableVC dismissModalViewControllerAnimated:NO];
    
    AskerViewController *asker = [visableVC.storyboard instantiateViewControllerWithIdentifier:@"asker"];
    asker.answers = [info valueForKey:ANSWERS];
    asker.prompt = [info valueForKey:PROMPT];
    asker.questionTitle = [info valueForKey:QUESTION_NAME];
    asker.timeLeft = [(NSDate *)[info valueForKey:TIME] timeIntervalSinceReferenceDate];
    [visableVC presentModalViewController: asker animated:YES];
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
    exit(0); //Sadly, I did not have enough time to support backgrounding because of the fact that the user can change their mode, and apparently my view is not loaded enough to reinitialize itself... Plus, the GameKitMatch will be lost anyway so not much of a point in stayinga active for now (I would probably implement this later if I had time).
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
    UIViewController *viewcontroller = [(UINavigationController *)self.window.rootViewController visibleViewController];
    if([viewcontroller isKindOfClass:[HomeViewController class]])
    {
        [(HomeViewController *)viewcontroller setUpGameWithMode:[GKMatchHandler sharedHandler].userMode]; //No idea why this doesnt always work.  I shouldnt have to do anything here because I take care of everyting in viewWillAppear and viewDidAppear.  Sorry if I don't compeletely support backgrounding with mode changes in between... its a work in progress :)
    }
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
