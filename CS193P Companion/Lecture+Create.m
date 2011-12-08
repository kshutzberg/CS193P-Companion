//
//  Lecture+Create.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Entities+Create.h"

@implementation Lecture (Create)

//#warning Lectures MUST be uniquely named.  This must be enforced by the UI


+ (Lecture *)nextLectureInContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_LECTURE];
    NSUInteger count = [context countForFetchRequest:request error:NULL];
    
    NSString *lectureName;
    while (true) {
        lectureName = [NSString stringWithFormat:@"Lecture %d",count + 1];
        request.predicate = [NSPredicate predicateWithFormat:@"lectureName = %@",lectureName];
        Lecture * lecture = [[context executeFetchRequest:request error:NULL] lastObject];
        if(!lecture)break;
        count++;
    }
    
    return [Lecture lectureWithName:lectureName andNumber:count inContext:context];
    
}
+ (Lecture *)lectureWithName:(NSString *)lectureName andNumber:(int32_t)number inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_LECTURE];
    request.predicate = [NSPredicate predicateWithFormat:@"lectureName = %@",lectureName];
    Lecture * lecture = [[context executeFetchRequest:request error:NULL] lastObject];
    
    if(lecture){
        NSLog(@"Lecture: {%@} already exists",lectureName);
        return lecture;
    }
    else{
        //If the lecture doesn't exist, create a new one
        lecture = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_LECTURE inManagedObjectContext:context];
        
        //Initialize attributes:
        lecture.lectureName = lectureName;
        lecture.lectureNumber = number;
        
        return lecture;
    }
}

@end
