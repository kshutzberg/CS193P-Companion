//
//  QuestionInfoViewController.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/30/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"

@interface QuestionInfoViewController : UITableViewController

@property (nonatomic, strong) Question *question;

@end
