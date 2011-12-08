//
//  QuestionSearchTableViewController.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/4/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QuestionSearchTableViewControllerDelegate <NSObject>

- (void)userDidCancel;

@end

@interface QuestionSearchTableViewController : UITableViewController

@property (nonatomic, weak) id<QuestionSearchTableViewControllerDelegate> delegate;

@end
