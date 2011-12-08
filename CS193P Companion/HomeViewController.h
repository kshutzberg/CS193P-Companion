//
//  HomeViewController.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/2/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UserMode.h"

@interface HomeViewController : UIViewController

- (void)setUpGameWithMode:(UserMode)mode;

@end
