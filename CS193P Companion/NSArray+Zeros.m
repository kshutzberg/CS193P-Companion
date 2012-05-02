//
//  NSArray+Zeros.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/11/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "NSArray+Zeros.h"

@implementation NSArray (Zeros)

+ (NSArray *)arrayWithZeros:(NSUInteger)numZeros
{
    NSArray *retVal = [NSArray array];
    for (int i = 0; i < numZeros ; i++) {
        retVal = [retVal arrayByAddingObject:[NSNumber numberWithInt:0]];
    }
    return retVal;
}

@end
