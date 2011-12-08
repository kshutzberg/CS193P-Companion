//
//  QuestionCell.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *iconView;
@property (nonatomic, strong) IBOutlet UILabel *textLabel;
@property (nonatomic, strong) IBOutlet UILabel *detailTextLabel;
@end
