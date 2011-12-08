//
//  DataMessage.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreFoundation/CoreFoundation.h>
#import "Question.h"

@interface DataMessage : NSDictionary

+ (id)message; //Returns a concrete instance of DataMessage, or the subclass that called it

//Converting Between Message and Data
+ (NSData *)dataWithMessage:(DataMessage *)message;
+ (NSDictionary *)messageWithData:(NSData *)data;

@end

@interface DataPacket : NSObject

@property (nonatomic, strong) Class type;
@property (nonatomic, strong) NSDictionary *message;

+ (DataPacket *)packet;

#define OBJECT_TYPE @"object_type"

//Types
#define TYPE_QUESTION @"questionType"
#define TYPE_ANSWER @"answerType"

//Question Constants
#define QUESTION_NAME @"questionName"
#define PROMPT @"prompt"
#define TIME @"time"
#define ANSWERS @"answers"

//Answer constants
#define ANSWER_INDEX @"answerIndex"

+ (NSData *)DatatForMessage:(NSDictionary *)message withType:(NSString *)type;

@end
