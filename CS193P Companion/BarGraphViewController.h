//
//  BarGraphViewController.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/2/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BarGraphView.h"
#import "Question.h"

@interface BarGraphViewController : UIViewController
@property (nonatomic, weak) IBOutlet BarGraphView *graphView;
@property (nonatomic, strong) Question *question;
@end
