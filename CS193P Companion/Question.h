//
//  Question.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/2/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Answer, Lecture, Topic;

@interface Question : NSManagedObject

@property (nonatomic) float order;
@property (nonatomic, retain) NSString * prompt;
@property (nonatomic, retain) NSString * questionName;
@property (nonatomic) NSTimeInterval time;
@property (nonatomic) int32_t correctIndex;
@property (nonatomic, retain) NSOrderedSet *answers;
@property (nonatomic, retain) Lecture *lecture;
@property (nonatomic, retain) NSSet *topics;
@end

@interface Question (CoreDataGeneratedAccessors)

- (void)insertObject:(Answer *)value inAnswersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromAnswersAtIndex:(NSUInteger)idx;
- (void)insertAnswers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeAnswersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInAnswersAtIndex:(NSUInteger)idx withObject:(Answer *)value;
- (void)replaceAnswersAtIndexes:(NSIndexSet *)indexes withAnswers:(NSArray *)values;
- (void)addAnswersObject:(Answer *)value;
- (void)removeAnswersObject:(Answer *)value;
- (void)addAnswers:(NSOrderedSet *)values;
- (void)removeAnswers:(NSOrderedSet *)values;
- (void)addTopicsObject:(Topic *)value;
- (void)removeTopicsObject:(Topic *)value;
- (void)addTopics:(NSSet *)values;
- (void)removeTopics:(NSSet *)values;

@end
