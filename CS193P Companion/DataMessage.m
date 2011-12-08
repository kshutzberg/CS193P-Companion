//
//  DataMessage.m
//  CS193P Companion
//
//  Created by Kevin Shutzberg on 12/6/11.
//  Copyright (c) 2011 Stanford University. All rights reserved.
//

#import "DataMessage.h"
@interface DataMessage()
@end

@implementation DataMessage


+ (id)message
{
    DataMessage *message = (DataMessage *)[[NSManagedObject alloc] init];

    //class->super_class = (__bridge_transfer Class)[NSManagedObject class]);
    
    return message;
}



+ (NSData *)dataWithMessage:(DataMessage *)message
{
    DataPacket *packet = [DataPacket packet];
    packet.type = [message class];
    packet.message = message;
    return [NSPropertyListSerialization dataWithPropertyList:packet format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
}

+ (DataMessage *)messageWithData:(NSData *)data
{
    DataPacket *packet = [NSPropertyListSerialization propertyListFromData:data
                                                          mutabilityOption:NSPropertyListMutableContainersAndLeaves
                                                                    format:NULL
                                                          errorDescription:NULL];
    packet.message->isa = packet.type;
    return (id)packet.message;
}
@end


@interface DataPacket(){
    NSString *_messageType;
}
//@property (nonatomic, strong) NSString *stringMessageType;
@end

@implementation DataPacket
//@synthesize stringMessageType = _messageType;

@dynamic message;

- (Class)type { return NSClassFromString(_messageType); }
- (void)setType:(Class)messageType{_messageType = NSStringFromClass(messageType); }

+ (DataPacket *)packet{ return [[self alloc] init]; }

+ (NSData *)DatatForMessage:(NSDictionary *)message withType:(NSString *)type
{
    //NSDictionary *dic = [[NSDictionary alloc] initWithObjectsAndKeys:type, OBJECT_TYPE, MESSAGE, message, nil];
    
    //return [NSPropertyListSerialization dataWithPropertyList:dic format:NSPropertyListBinaryFormat_v1_0 options:0 error:NULL];
    return nil;
}

@end