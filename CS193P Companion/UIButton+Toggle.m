//
//  UIButton+Toggle.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/7/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "UIButton+Toggle.h"

@implementation UIButton (Toggle)

- (void)toggleEnabled
{
    self.enabled = YES;
    self.alpha = 1;
}


-(void)toggleDisabled
{
    self.enabled = NO;
    self.alpha = .5;
}

@end
