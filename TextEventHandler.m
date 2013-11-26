//
//  TextEventHandler.m
//  COMP2601iPhoneAssignment3
//
//  Created by Devin Lynch on 2013-04-07.
//  Copyright (c) 2013 Carleton. All rights reserved.
//

#import "TextEventHandler.h"

@implementation TextEventHandler
-(void) handleEvent: (Event *) event {
    NSLog(@"Text handler: %@", event);
}

-(void) handleTheEvent: (Event *) event {
    NSLog(@"Text handler handleTheEvent: %@", event);
    
    // Message received
    Message *recMsg = event.message;
    NSDictionary *body = [recMsg body];
    NSString *sender = [body objectForKey:@"sender"];
    NSString *receiver = [body objectForKey:@"receiver"];
    NSString *message = [body objectForKey:@"message"];
    NSLog(@"Sender: %@", body);
    
    NSLog(@"Users: %@", event.users);

    // Message to send
    Message *msg = [[Message alloc] initHeadAndBody];
    [[msg head] setValue:@"TEXT" forKey:@"type"];
    [[msg body] setValue:sender forKey:@"sender"];
    [[msg body] setValue:receiver forKey:@"receiver"];
    [[msg body] setValue:message forKey:@"message"];
    NSArray *users = [[NSArray alloc] initWithArray:[event.users allKeys]];
    [[msg body] setValue:users forKey:@"users"];
    
    // Sends new message
    NSData* data = [[NSData alloc] initWithData: [msg toJSON]];
    Message* msg2 = [Message initFromJSON:data];
   
    // Sends to correct user
    GCDAsyncSocket *recSock = [event.users objectForKey:receiver];
    NSLog(@"Sent DATA in server: %@", msg2.head);
    [recSock writeData:data withTimeout:-1 tag:-1];
    [recSock writeData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:-1];
    
    
}
@end
