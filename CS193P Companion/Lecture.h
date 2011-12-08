//
//  Lecture.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Question;

@interface Lecture : NSManagedObject

@property (nonatomic) NSTimeInterval date;
@property (nonatomic, retain) NSString * lectureName;
@property (nonatomic) int32_t lectureNumber;
@property (nonatomic, retain) NSSet *questions;
@end

@interface Lecture (CoreDataGeneratedAccessors)

- (void)addQuestionsObject:(Question *)value;
- (void)removeQuestionsObject:(Question *)value;
- (void)addQuestions:(NSSet *)values;
- (void)removeQuestions:(NSSet *)values;

@end
