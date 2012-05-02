//
//  Question+Create.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Entities+Create.h"

@implementation Question (Create)

+ (Question *)nextQuestionForLecture:(Lecture *)lecture;
{
    NSManagedObjectContext *context = lecture.managedObjectContext;
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_QUESTION];
    request.predicate = [NSPredicate predicateWithFormat:@"lecture.lectureName = %@",lecture.lectureName];
    NSUInteger count = [context countForFetchRequest:request error:NULL];
    NSString *questionName = [NSString stringWithFormat:@"Question %d",count + 1];
    return [Question questionWithName:questionName andPrompt:@"Please choose an answer." andTime:30 andAnswers:nil forLecture:lecture withTopics:nil inManagedObjectContext:context];
}

+ (Question *)questionWithName:(NSString *)name
                       andPrompt:(NSString *)prompt
                        andTime:(NSTimeInterval)time
               andAnswers:(NSArray *)answers
                     forLecture:(Lecture *)lecture
                     withTopics:(NSArray *)topics
         inManagedObjectContext:(NSManagedObjectContext *)context
{
    //Figure out how many questions are already in the lecture:
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_QUESTION];
    request.predicate = [NSPredicate predicateWithFormat:@"lecture.lectureName = %@",lecture.lectureName];
    
    //Insert a new question into the managedObjectContext
    Question *question = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_QUESTION inManagedObjectContext:context];
    
    //Initialize Attributes
    question.questionName = name;
    question.prompt = prompt;
    question.time = time;
    question.order = [context countForFetchRequest:request error:NULL];
    
    //Set up Relationships
    question.lecture = lecture;
    
    //Topics
    NSSet *topicSet = [NSSet setWithArray:topics];
    [question addTopics:topicSet];
    for (Topic *topic in question.topics) {
        topic.numQuestions = [topic.questions count];
    }
    
    NSOrderedSet *answerSet = [NSOrderedSet orderedSetWithArray:answers];
    question.answers = answerSet;
    
    return question;
}

-(NSArray *)stringAnswers
{
    NSMutableArray *answers = [NSMutableArray array];
    for (Answer *answer in self.answers) {
        [answers addObject:answer.answerText];
    }
    return [answers copy];
}

-(NSArray *)numberAnswers
{
    NSMutableArray *answers = [NSMutableArray array];
    for (Answer *answer in self.answers) {
        [answers addObject:[NSNumber numberWithInt:answer.numPeople]];
    }
    return [answers copy];
}

- (void)prepareForDeletion
{
    //Check to see if there are any topics left that don't have any questions
    for (Topic *topic in self.topics) {
        topic.numQuestions--;
        if(!topic.numQuestions)
            [self.managedObjectContext deleteObject:topic];
        
    }
}

@end
