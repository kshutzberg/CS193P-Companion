//
//  QuestionsTableViewController.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/30/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "CoreDataTableViewController.h"
#import "Lecture.h"
#import "Topic.h"

@interface QuestionsTableViewController : CoreDataTableViewController
@property (nonatomic, strong) Lecture *currentLecture;
@property (nonatomic, strong) Topic *currentTopic;

@end
