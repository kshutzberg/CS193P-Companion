//
//  Topic+Create.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 11/29/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "Entities+Create.h"

@implementation Topic (Create)

+ (Topic *)topicWithString:(NSString *)topicName inContext:(NSManagedObjectContext *)context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:ENTITY_TOPIC];
    request.predicate = [NSPredicate predicateWithFormat:@"topicName = %@",topicName];
    Topic * topic = [[context executeFetchRequest:request error:NULL] lastObject];
    
    if(topic){
        NSLog(@"Topic: {%@} already exists",topicName);
        return topic;
    }
    else{
        //If the lecture doesn't exist, create a new one
        topic = [NSEntityDescription insertNewObjectForEntityForName:ENTITY_TOPIC inManagedObjectContext:context];
        
        //Initialize attributes:
        topic.topicName = topicName;
        
        return topic;
    }
}

+ (NSArray *)topicsFromStrings:(NSArray *)topics inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *retval = [[NSMutableArray alloc] init];
    for (NSString *topic in topics) {
        [retval addObject:[self topicWithString:topic inContext:context]];
    }
    
    return retval;
}

@end
