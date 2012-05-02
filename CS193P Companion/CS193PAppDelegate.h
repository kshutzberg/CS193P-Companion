//
//  CS193PAppDelegate.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/28/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CS193PAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (void)displayQuestionWithInfo:(NSDictionary *)info;

- (void)returnHome;

@end
