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

@end
