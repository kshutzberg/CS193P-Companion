//
//  Answer.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/1/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface Answer : NSManagedObject

@property (nonatomic, retain) NSString * answerText;
@property (nonatomic) int32_t numPeople;
@property (nonatomic, retain) Question *question;

@end
