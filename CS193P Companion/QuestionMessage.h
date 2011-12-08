//
//  QuestionMessage.h
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "DataMessage.h"

@interface QuestionMessage : DataMessage

@property (nonatomic, copy) NSString *questionName;
@property (nonatomic, copy) NSString *prompt;
@property (nonatomic, strong) NSDate *time;
@property (nonatomic, copy) NSArray *answers;

+ (QuestionMessage *)messageWithQuestion:(Question *)question;

//I was doing some crazy stuff with the runtime environment in this class (and Data Message), but I ran out of time to get it working so I am just going to use a lame dictionary and value for key :(

+ (NSData *)dataWithQuestion:(Question *)question;
+ (NSData *)dataWithAnswerIndex:(NSUInteger)index;

+ (void)updateQuestion:(Question *)question withAnswerMessage:(NSDictionary *)message;
@end
