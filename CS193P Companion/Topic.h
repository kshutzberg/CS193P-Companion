//
//  Topic.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface Topic : NSManagedObject

@property (nonatomic) int32_t numQuestions;
@property (nonatomic, retain) NSString * topicName;
@property (nonatomic, retain) NSSet *questions;
@end

@interface Topic (CoreDataGeneratedAccessors)

- (void)addQuestionsObject:(Question *)value;
- (void)removeQuestionsObject:(Question *)value;
- (void)addQuestions:(NSSet *)values;
- (void)removeQuestions:(NSSet *)values;

@end
