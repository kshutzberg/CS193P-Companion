//
//  Photo+Create.h
//  Top Places
//
//  Created by Kevin Shutzberg on 11/16/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Question.h"
#import "Lecture.h"
#import "Topic.h"
#import "Answer.h"


#define ENTITY_QUESTION NSStringFromClass([Question class])
#define ENTITY_LECTURE NSStringFromClass([Lecture class])
#define ENTITY_TOPIC NSStringFromClass([Topic class])
#define ENTITY_ANSWER NSStringFromClass([Answer class])


@interface Question (Create)

+ (Question *)nextQuestionForLecture:(Lecture *)lecture;

+ (Question *)questionWithName:(NSString *)name
                    andPrompt:(NSString *)prompt
                      andTime:(NSTimeInterval)time
                   andAnswers:(NSArray *)answers
                   forLecture:(Lecture *)lecture
                   withTopics:(NSArray *)topics
       inManagedObjectContext:(NSManagedObjectContext *)context;


@property (readonly) NSArray *numberAnswers;
@property (readonly) NSArray *stringAnswers;

-(void)prepareForDeletion;

@end


@interface Lecture (Create)

+ (Lecture *)nextLectureInContext:(NSManagedObjectContext *)context;

+ (Lecture *)lectureWithName:(NSString *)lectureName andNumber:(int32_t)number inContext:(NSManagedObjectContext *)context;
@end


@interface Topic (Create)

+ (Topic *)topicWithString:(NSString *)topicName inContext:(NSManagedObjectContext *)context;
+ (NSArray *)topicsFromStrings:(NSArray *)topics inContext:(NSManagedObjectContext *)context;

@end

@interface Answer (Create)

+ (Answer *)nextAnswerForQuestion:(Question *)question;

+ (Answer *)answerWithString:(NSString *)text inContext:(NSManagedObjectContext *)context;
+ (NSArray *)answersFromStrings:(NSArray *)answers inContext:(NSManagedObjectContext *)context;

@property (readonly) NSNumber *order;

@end