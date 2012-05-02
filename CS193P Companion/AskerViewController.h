//
//  AskerViewController.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Question.h"

@interface AskerViewController : UIViewController
@property (nonatomic, strong) NSArray *answers;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *promptLabel;
@property (weak, nonatomic) IBOutlet UILabel *countdownLabel;

@property (weak, nonatomic) IBOutlet UIButton *answerButton;

@property (nonatomic, strong) NSString *questionTitle;
@property (nonatomic, strong) NSString *prompt;
@property (nonatomic, strong) NSDate *completionDate;

@property (nonatomic) NSTimeInterval timeLeft;

@end
