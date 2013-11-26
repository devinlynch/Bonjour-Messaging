//
//  Message.m
//  BonjourClientServer
//
//  Created by Devin Lynch on 2013-03-23.
//  Copyright (c) 2013 Devin Lynch. All rights reserved.
//

#import "Message.h"

@implementation Message
@synthesize head, body;


-(NSString*) toSring{
    return [NSString stringWithFormat:@"%@\n%@", head, body];
}


- (id)initHeadAndBody
{
    self = [super init];
    if (self){
        self.head = [[NSMutableDictionary alloc] init];
        self.body = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)getMessage:(NSData *)responseData {
    //parse out the json data
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:responseData
                          options:kNilOptions
                          error:&error];
    head = [NSMutableDictionary dictionaryWithDictionary:[json objectForKey:@"head"]];
    body = [NSMutableDictionary dictionaryWithDictionary:[json objectForKey:@"body"]];
}


+(Message*)initFromJSON: (NSData*)data {
    Message *msg = [[Message alloc] init];
    NSError* error;
    NSDictionary* json = [NSJSONSerialization
                          JSONObjectWithData:data
                          options:kNilOptions
                          error:&error];
    msg.head = [NSMutableDictionary dictionaryWithDictionary:[json objectForKey:@"head"]];
    msg.body = [NSMutableDictionary dictionaryWithDictionary:[json objectForKey:@"body"]];
    return msg; 
}

-(NSData *)toJSON {
    NSDictionary *msg =
    [NSDictionary dictionaryWithObjectsAndKeys:
     head, @"head",
     body, @"body",
     nil];
    NSError *error;
    NSData *data =
    [NSJSONSerialization dataWithJSONObject: msg
                                    options: NSJSONWritingPrettyPrinted
                                      error: &error];
    return data;
}

-(void) encodeWithCoder: (NSCoder *) encoder
{
    [encoder encodeObject: head];
    [encoder encodeObject: body];
}

-(id) initWithCoder: (NSCoder *) decoder
{
    head = [decoder decodeObject];
    body = [decoder decodeObject];
    return self;
}


@end
