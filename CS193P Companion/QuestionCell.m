//
//  QuestionCell.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "QuestionCell.h"

@implementation QuestionCell
@synthesize iconView = _iconView;
@synthesize textLabel = __textLabel, detailTextLabel = __detailTextLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
